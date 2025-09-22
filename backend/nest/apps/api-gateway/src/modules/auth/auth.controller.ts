import { 
  Controller, 
  Post, 
  Body, 
  Get, 
  UseGuards, 
  Request,
  Ip,
  HttpCode,
  HttpStatus,
  Patch,
  Param,
  ParseIntPipe
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth, ApiParam } from '@nestjs/swagger';
import { AuthService } from './auth.service';
import { JwtAuthGuard } from './jwt.guard';
import { RolesGuard, Roles } from './roles.guard';
import { 
  LoginDto, 
  RegisterDto, 
  ChangePasswordDto,
  UpdateKycDto,
  UpdateUserStatusDto,
  LoginResponseDto,
  UserResponseDto
} from './dto';
import { UserRole, UserEntity } from '../users/user.entity';

@ApiTags('Authentication')
@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Post('register')
  @ApiOperation({ summary: 'Register a new user' })
  @ApiResponse({ status: 201, type: LoginResponseDto })
  @HttpCode(HttpStatus.CREATED)
  async register(@Body() dto: RegisterDto): Promise<LoginResponseDto> {
    const { user, token } = await this.authService.register(dto);
    return {
      token,
      user: new UserResponseDto(user),
      expiresIn: '24h'
    };
  }

  @Post('login')
  @ApiOperation({ summary: 'User login' })
  @ApiResponse({ status: 200, type: LoginResponseDto })
  @HttpCode(HttpStatus.OK)
  async login(
    @Body() dto: LoginDto,
    @Ip() clientIp: string
  ): Promise<LoginResponseDto> {
    const { user, token } = await this.authService.login(dto, clientIp);
    return {
      token,
      user: new UserResponseDto(user),
      expiresIn: '24h'
    };
  }

  @Post('admin/login')
  @ApiOperation({ summary: 'Admin login with role validation' })
  @ApiResponse({ status: 200, type: LoginResponseDto })
  @HttpCode(HttpStatus.OK)
  async adminLogin(
    @Body() dto: LoginDto,
    @Ip() clientIp: string
  ): Promise<LoginResponseDto> {
    const { user, token } = await this.authService.adminLogin(dto, clientIp);
    return {
      token,
      user: new UserResponseDto(user),
      expiresIn: '24h'
    };
  }

  @Get('me')
  @ApiOperation({ summary: 'Get current user profile' })
  @ApiResponse({ status: 200, type: UserResponseDto })
  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard)
  async getProfile(@Request() req: any): Promise<UserResponseDto> {
    const user = await this.authService.findUserById(req.user.sub);
    if (!user) {
      throw new Error('User not found');
    }
    return new UserResponseDto(user);
  }

  @Patch('change-password')
  @ApiOperation({ summary: 'Change user password' })
  @ApiResponse({ status: 200, description: 'Password changed successfully' })
  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard)
  async changePassword(
    @Request() req: any,
    @Body() dto: ChangePasswordDto
  ): Promise<{ message: string }> {
    await this.authService.changePassword(req.user.sub, dto.currentPassword, dto.newPassword);
    return { message: 'Password changed successfully' };
  }

  // Admin-only endpoints
  @Patch('users/:id/kyc')
  @ApiOperation({ summary: 'Update user KYC status (Admin only)' })
  @ApiParam({ name: 'id', type: 'string' })
  @ApiResponse({ status: 200, type: UserResponseDto })
  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.admin)
  async updateUserKyc(
    @Param('id') userId: string,
    @Body() dto: UpdateKycDto
  ): Promise<UserResponseDto> {
    const user = await this.authService.updateUserKyc(userId, dto.kycStatus, dto.notes);
    return new UserResponseDto(user);
  }

  @Patch('users/:id/status')
  @ApiOperation({ summary: 'Update user status (Admin only)' })
  @ApiParam({ name: 'id', type: 'string' })
  @ApiResponse({ status: 200, type: UserResponseDto })
  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.admin)
  async updateUserStatus(
    @Param('id') userId: string,
    @Body() dto: UpdateUserStatusDto
  ): Promise<UserResponseDto> {
    const user = await this.authService.updateUserStatus(userId, dto.status);
    return new UserResponseDto(user);
  }

  // Legacy endpoints for backwards compatibility
  @Post('signup')
  @ApiOperation({ summary: 'Register (legacy endpoint)' })
  async signup(@Body() dto: RegisterDto): Promise<{ access_token: string }> {
    const { token } = await this.authService.register(dto);
    return { access_token: token };
  }

  @Post('2fa/verify')
  @ApiOperation({ summary: 'Verify 2FA (placeholder)' })
  twofa(@Body() body: any) {
    return { ok: true, action: '2fa' };
  }

  @Post('kyc/submit')
  @ApiOperation({ summary: 'Submit KYC documents (placeholder)' })
  kycSubmit(@Body() body: any) {
    return { ok: true, action: 'kyc_submit' };
  }

  @Get('kyc/status')
  @ApiOperation({ summary: 'Get KYC status' })
  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard)
  async kycStatus(@Request() req: any) {
    const user = await this.authService.findUserById(req.user.sub);
    return { 
      status: user?.kycStatus || 'pending',
      notes: user?.kycNotes 
    };
  }
}



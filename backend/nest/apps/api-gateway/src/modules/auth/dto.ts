import { IsEmail, IsString, MinLength, IsOptional, IsEnum, IsPhoneNumber, MaxLength, Matches } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { UserRole, UserStatus, KycStatus } from '../users/user.entity';

export class LoginDto {
  @ApiProperty({ example: 'admin@rwa-platform.com' })
  @IsEmail()
  email!: string;

  @ApiProperty({ example: 'admin123', minLength: 6 })
  @IsString()
  @MinLength(6)
  password!: string;
}

export class RegisterDto {
  @ApiProperty({ example: 'john.doe@example.com' })
  @IsEmail()
  email!: string;

  @ApiProperty({ example: 'SecurePassword123!', minLength: 8 })
  @IsString()
  @MinLength(8)
  @Matches(/((?=.*\d)|(?=.*\W+))(?![.\n])(?=.*[A-Z])(?=.*[a-z]).*$/, {
    message: 'Password must contain uppercase, lowercase, number or special character'
  })
  password!: string;

  @ApiPropertyOptional({ example: 'John' })
  @IsOptional()
  @IsString()
  @MaxLength(50)
  firstName?: string;

  @ApiPropertyOptional({ example: 'Doe' })
  @IsOptional()
  @IsString()
  @MaxLength(50)
  lastName?: string;

  @ApiPropertyOptional({ example: '+1234567890' })
  @IsOptional()
  @IsPhoneNumber()
  phone?: string;

  @ApiPropertyOptional({ enum: UserRole, example: UserRole.user })
  @IsOptional()
  @IsEnum(UserRole)
  role?: UserRole;

  @ApiPropertyOptional({ example: 'US' })
  @IsOptional()
  @IsString()
  @MaxLength(3)
  residency?: string;
}

export class ChangePasswordDto {
  @ApiProperty()
  @IsString()
  @MinLength(6)
  currentPassword!: string;

  @ApiProperty({ minLength: 8 })
  @IsString()
  @MinLength(8)
  @Matches(/((?=.*\d)|(?=.*\W+))(?![.\n])(?=.*[A-Z])(?=.*[a-z]).*$/, {
    message: 'Password must contain uppercase, lowercase, number or special character'
  })
  newPassword!: string;
}

export class UpdateKycDto {
  @ApiProperty({ enum: KycStatus })
  @IsEnum(KycStatus)
  kycStatus!: KycStatus;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  @MaxLength(500)
  notes?: string;
}

export class UpdateUserStatusDto {
  @ApiProperty({ enum: UserStatus })
  @IsEnum(UserStatus)
  status!: UserStatus;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  @MaxLength(500)
  reason?: string;
}

// Response DTOs
export class UserResponseDto {
  @ApiProperty()
  id!: string;

  @ApiProperty()
  email!: string;

  @ApiPropertyOptional()
  firstName?: string;

  @ApiPropertyOptional()
  lastName?: string;

  @ApiPropertyOptional()
  phone?: string;

  @ApiProperty({ enum: UserRole })
  role!: UserRole;

  @ApiProperty({ enum: UserStatus })
  status!: UserStatus;

  @ApiProperty({ enum: KycStatus })
  kycStatus!: KycStatus;

  @ApiPropertyOptional()
  residency?: string;

  @ApiPropertyOptional()
  lastLoginAt?: Date;

  @ApiProperty()
  createdAt!: Date;

  @ApiProperty()
  updatedAt!: Date;

  constructor(user: Partial<UserResponseDto>) {
    Object.assign(this, user);
  }
}

export class LoginResponseDto {
  @ApiProperty()
  token!: string;

  @ApiProperty({ type: UserResponseDto })
  user!: UserResponseDto;

  @ApiProperty()
  expiresIn!: string;
}

export interface TokenPayload {
  sub: string;
  email: string;
  role: UserRole;
  status: UserStatus;
  kycStatus: KycStatus;
  iat: number;
}

// Admin-specific DTOs
export class AdminStatsDto {
  @ApiProperty()
  totalUsers!: number;

  @ApiProperty()
  activeUsers!: number;

  @ApiProperty()
  pendingKyc!: number;

  @ApiProperty()
  totalAssets!: number;

  @ApiProperty()
  activeAssets!: number;

  @ApiProperty()
  pendingAssets!: number;

  @ApiProperty()
  totalAgents!: number;

  @ApiProperty()
  approvedAgents!: number;

  @ApiProperty()
  pendingAgents!: number;

  @ApiProperty()
  totalPortfolioValue!: number;

  @ApiProperty()
  monthlyPayouts!: number;
}

export class AdminActivityDto {
  @ApiProperty()
  id!: string;

  @ApiProperty()
  type!: string;

  @ApiProperty()
  title!: string;

  @ApiProperty()
  description!: string;

  @ApiProperty()
  userId?: string;

  @ApiProperty()
  userName?: string;

  @ApiProperty()
  createdAt!: Date;

  @ApiProperty()
  metadata?: Record<string, any>;
}

// Legacy - keeping for backwards compatibility
export class SignupDto extends RegisterDto {}






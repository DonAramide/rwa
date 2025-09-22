import { Injectable, UnauthorizedException, BadRequestException, ConflictException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcryptjs';
import { UserEntity, UserRole, UserStatus, KycStatus } from '../users/user.entity';
import { LoginDto, RegisterDto, TokenPayload } from './dto';

@Injectable()
export class AuthService {
  constructor(
    @InjectRepository(UserEntity)
    private readonly userRepository: Repository<UserEntity>,
    private readonly jwt: JwtService
  ) {}

  async hashPassword(password: string): Promise<string> {
    const salt = await bcrypt.genSalt(12);
    return bcrypt.hash(password, salt);
  }

  async comparePassword(password: string, hash: string): Promise<boolean> {
    return bcrypt.compare(password, hash);
  }

  async register(dto: RegisterDto): Promise<{ user: UserEntity; token: string }> {
    // Check if user already exists
    const existingUser = await this.userRepository.findOne({
      where: { email: dto.email.toLowerCase() }
    });

    if (existingUser) {
      throw new ConflictException('User with this email already exists');
    }

    // Create new user
    const passwordHash = await this.hashPassword(dto.password);
    const user = this.userRepository.create({
      email: dto.email.toLowerCase(),
      firstName: dto.firstName,
      lastName: dto.lastName,
      phone: dto.phone,
      passwordHash,
      role: dto.role || UserRole.user,
      status: UserStatus.active,
      kycStatus: KycStatus.pending,
      residency: dto.residency,
    });

    await this.userRepository.save(user);

    // Generate token
    const token = this.generateToken(user);

    return { user, token };
  }

  async login(dto: LoginDto, clientIp?: string): Promise<{ user: UserEntity; token: string }> {
    const user = await this.userRepository.findOne({
      where: { email: dto.email.toLowerCase() }
    });

    if (!user) {
      throw new UnauthorizedException('Invalid credentials');
    }

    // Check if user is active
    if (user.status !== UserStatus.active) {
      throw new UnauthorizedException('Account is suspended or inactive');
    }

    // Verify password
    const isValidPassword = await this.comparePassword(dto.password, user.passwordHash);
    if (!isValidPassword) {
      throw new UnauthorizedException('Invalid credentials');
    }

    // Update last login info
    user.lastLoginAt = new Date();
    if (clientIp) {
      user.lastLoginIp = clientIp;
    }
    await this.userRepository.save(user);

    // Generate token
    const token = this.generateToken(user);

    return { user, token };
  }

  async adminLogin(dto: LoginDto, clientIp?: string): Promise<{ user: UserEntity; token: string }> {
    const result = await this.login(dto, clientIp);
    
    // Ensure user is admin
    if (result.user.role !== UserRole.admin) {
      throw new UnauthorizedException('Admin access required');
    }

    return result;
  }

  generateToken(user: UserEntity): string {
    const payload: TokenPayload = {
      sub: user.id,
      email: user.email,
      role: user.role,
      status: user.status,
      kycStatus: user.kycStatus,
      iat: Math.floor(Date.now() / 1000),
    };

    return this.jwt.sign(payload, { expiresIn: '24h' });
  }

  async validateUser(userId: string): Promise<UserEntity | null> {
    return this.userRepository.findOne({
      where: { id: userId, status: UserStatus.active }
    });
  }

  async findUserById(id: string): Promise<UserEntity | null> {
    return this.userRepository.findOne({ where: { id } });
  }

  async findUserByEmail(email: string): Promise<UserEntity | null> {
    return this.userRepository.findOne({ where: { email: email.toLowerCase() } });
  }

  async updateUserKyc(userId: string, kycStatus: KycStatus, notes?: string): Promise<UserEntity> {
    const user = await this.findUserById(userId);
    if (!user) {
      throw new BadRequestException('User not found');
    }

    user.kycStatus = kycStatus;
    if (notes) {
      user.kycNotes = notes;
    }

    return this.userRepository.save(user);
  }

  async updateUserStatus(userId: string, status: UserStatus): Promise<UserEntity> {
    const user = await this.findUserById(userId);
    if (!user) {
      throw new BadRequestException('User not found');
    }

    user.status = status;
    return this.userRepository.save(user);
  }

  async changePassword(userId: string, currentPassword: string, newPassword: string): Promise<void> {
    const user = await this.findUserById(userId);
    if (!user) {
      throw new BadRequestException('User not found');
    }

    // Verify current password
    const isValidPassword = await this.comparePassword(currentPassword, user.passwordHash);
    if (!isValidPassword) {
      throw new UnauthorizedException('Current password is incorrect');
    }

    // Update password
    user.passwordHash = await this.hashPassword(newPassword);
    await this.userRepository.save(user);
  }

  // Create default admin user if it doesn't exist
  async ensureAdminUser(): Promise<void> {
    const adminExists = await this.userRepository.findOne({
      where: { role: UserRole.admin }
    });

    if (!adminExists) {
      const admin = this.userRepository.create({
        email: 'admin@rwa-platform.com',
        firstName: 'Admin',
        lastName: 'User',
        passwordHash: await this.hashPassword('admin123'),
        role: UserRole.admin,
        status: UserStatus.active,
        kycStatus: KycStatus.approved,
      });

      await this.userRepository.save(admin);
      console.log('✅ Default admin user created: admin@rwa-platform.com / admin123');
    }
  }
}
























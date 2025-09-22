import { Column, CreateDateColumn, Entity, PrimaryGeneratedColumn, UpdateDateColumn, Index } from 'typeorm';

export enum KycStatus { 
  pending = 'pending', 
  submitted = 'submitted', 
  approved = 'approved', 
  rejected = 'rejected' 
}

export enum UserRole {
  // Master Admin Level
  master_admin = 'master_admin',
  // Bank Admin Level
  bank_admin = 'bank_admin',
  bank_operations = 'bank_operations',
  // End Users
  admin = 'admin',
  investor = 'investor',
  investor_agent = 'investor_agent',
  professional_agent = 'professional_agent',
  verifier = 'verifier',
  asset_owner = 'asset_owner',
  // Legacy roles for compatibility
  user = 'user',
  agent = 'agent',
  issuer = 'issuer'
}

export enum UserStatus {
  active = 'active',
  suspended = 'suspended',
  inactive = 'inactive'
}

@Entity('users')
@Index(['email'], { unique: true })
@Index(['role', 'status'])
export class UserEntity {
  @PrimaryGeneratedColumn('uuid')
  id!: string;

  @Column({ unique: true })
  email!: string;

  @Column({ nullable: true })
  phone?: string;

  @Column({ name: 'first_name', nullable: true })
  firstName?: string;

  @Column({ name: 'last_name', nullable: true })
  lastName?: string;

  @Column({ name: 'password_hash' })
  passwordHash!: string;

  @Column({ 
    type: 'enum', 
    enum: UserRole, 
    default: UserRole.user 
  })
  role!: UserRole;

  @Column({ 
    type: 'enum', 
    enum: UserStatus, 
    default: UserStatus.active 
  })
  status!: UserStatus;

  @Column({ 
    type: 'enum', 
    enum: KycStatus, 
    default: KycStatus.pending, 
    name: 'kyc_status' 
  })
  kycStatus!: KycStatus;

  @Column({ nullable: true })
  residency?: string;

  @Column({ type: 'text', nullable: true, name: 'kyc_notes' })
  kycNotes?: string;

  @Column({ type: 'jsonb', nullable: true, name: 'risk_flags' })
  riskFlags?: Record<string, any>;

  @Column({ type: 'timestamp', nullable: true, name: 'last_login_at' })
  lastLoginAt?: Date;

  @Column({ type: 'inet', nullable: true, name: 'last_login_ip' })
  lastLoginIp?: string;

  @Column({ type: 'boolean', default: false, name: 'two_factor_enabled' })
  twoFactorEnabled!: boolean;

  @Column({ type: 'text', nullable: true, name: 'two_factor_secret' })
  twoFactorSecret?: string;

  // Banking partnership fields
  @Column({ type: 'uuid', nullable: true, name: 'bank_id' })
  bankId?: string;

  @Column({
    type: 'enum',
    enum: UserRole,
    default: UserRole.user,
    name: 'user_type'
  })
  userType!: UserRole;

  // Investor-Agent fields - temporarily commented out due to column mapping issue
  // @Column({ type: 'boolean', default: false, name: 'isinvestoragent' })
  // isInvestorAgent!: boolean;

  // @Column({ type: 'timestamp', nullable: true, name: 'investor_agent_since' })
  // investorAgentSince?: Date;

  // @Column({ type: 'integer', default: 0, name: 'reputation_score' })
  // reputationScore!: number;

  // @Column({ type: 'integer', default: 0, name: 'total_flags_submitted' })
  // totalFlagsSubmitted!: number;

  // @Column({ type: 'integer', default: 0, name: 'total_flags_resolved' })
  // totalFlagsResolved!: number;

  @CreateDateColumn({ name: 'created_at' })
  createdAt!: Date;

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt!: Date;

  // Helper methods
  get fullName(): string {
    return [this.firstName, this.lastName].filter(Boolean).join(' ') || this.email;
  }

  get isAdmin(): boolean {
    return this.role === UserRole.admin;
  }

  get isActive(): boolean {
    return this.status === UserStatus.active;
  }

  get isKycApproved(): boolean {
    return this.kycStatus === KycStatus.approved;
  }

  get canFlag(): boolean {
    return ['investor', 'investor_agent'].includes(this.role) && this.isActive && this.isKycApproved;
  }

  // Banking partnership helper methods
  get isMasterAdmin(): boolean {
    return this.userType === UserRole.master_admin;
  }

  get isBankAdmin(): boolean {
    return this.userType === UserRole.bank_admin;
  }

  get isBankOperations(): boolean {
    return this.userType === UserRole.bank_operations;
  }

  get isBankUser(): boolean {
    return this.bankId !== null && this.bankId !== undefined;
  }

  get canManageBanks(): boolean {
    return this.isMasterAdmin;
  }

  get canManageBankUsers(): boolean {
    return this.isBankAdmin || this.isMasterAdmin;
  }

  get canApproveAssets(): boolean {
    return this.isMasterAdmin;
  }

  get canProposalAssets(): boolean {
    return this.isBankAdmin || this.isBankOperations ||
           ['professional_agent', 'verifier', 'investor'].includes(this.userType);
  }

  // get accuracyRate(): number {
  //   return this.totalFlagsSubmitted > 0 ? this.totalFlagsResolved / this.totalFlagsSubmitted : 0;
  // }
}
























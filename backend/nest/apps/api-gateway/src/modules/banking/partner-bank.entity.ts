import { Column, CreateDateColumn, Entity, PrimaryGeneratedColumn, UpdateDateColumn, Index, OneToMany } from 'typeorm';

export enum BankStatus {
  pending = 'pending',
  active = 'active',
  suspended = 'suspended',
  terminated = 'terminated'
}

@Entity('partner_banks')
@Index(['status'])
@Index(['country'])
@Index(['domain'], { unique: true })
export class PartnerBankEntity {
  @PrimaryGeneratedColumn('uuid')
  id!: string;

  @Column()
  name!: string;

  @Column({ name: 'legal_name' })
  legalName!: string;

  @Column({ name: 'registration_number' })
  registrationNumber!: string;

  @Column()
  country!: string;

  @Column({ unique: true })
  domain!: string;

  @Column({ nullable: true })
  subdomain?: string;

  @Column({
    type: 'enum',
    enum: BankStatus,
    default: BankStatus.pending
  })
  status!: BankStatus;

  @Column({ type: 'integer', name: 'commission_rate_bps', default: 100 })
  commissionRateBps!: number; // basis points (100 bps = 1%)

  @Column({ type: 'integer', name: 'revenue_share_bps', default: 5000 })
  revenueShareBps!: number; // basis points (5000 bps = 50%)

  @Column({ type: 'timestamp', name: 'contract_start_date' })
  contractStartDate!: Date;

  @Column({ type: 'timestamp', nullable: true, name: 'contract_end_date' })
  contractEndDate?: Date;

  @Column({ type: 'text', nullable: true })
  description?: string;

  @Column({ type: 'jsonb', nullable: true, name: 'contact_info' })
  contactInfo?: {
    primaryContact: string;
    email: string;
    phone: string;
    address: string;
  };

  @Column({ type: 'jsonb', nullable: true, name: 'compliance_docs' })
  complianceDocs?: {
    license?: string;
    registration?: string;
    insurance?: string;
  };

  @CreateDateColumn({ name: 'created_at' })
  createdAt!: Date;

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt!: Date;

  // Helper methods
  get isActive(): boolean {
    return this.status === BankStatus.active;
  }

  get commissionRate(): number {
    return this.commissionRateBps / 10000; // Convert basis points to decimal
  }

  get revenueShare(): number {
    return this.revenueShareBps / 10000; // Convert basis points to decimal
  }

  get isContractValid(): boolean {
    const now = new Date();
    return now >= this.contractStartDate &&
           (this.contractEndDate === null || now <= this.contractEndDate);
  }
}
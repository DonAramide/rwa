import { Column, CreateDateColumn, Entity, PrimaryGeneratedColumn, UpdateDateColumn, ManyToOne, JoinColumn, Index } from 'typeorm';
import { PartnerBankEntity } from './partner-bank.entity';

export enum SettlementStatus {
  pending = 'pending',
  processed = 'processed',
  paid = 'paid',
  failed = 'failed'
}

@Entity('bank_settlements')
@Index(['bankId'])
@Index(['status'])
@Index(['periodStart', 'periodEnd'])
export class BankSettlementEntity {
  @PrimaryGeneratedColumn('uuid')
  id!: string;

  @Column({ type: 'uuid', name: 'bank_id' })
  bankId!: string;

  @ManyToOne(() => PartnerBankEntity)
  @JoinColumn({ name: 'bank_id' })
  bank!: PartnerBankEntity;

  @Column({ type: 'timestamp', name: 'period_start' })
  periodStart!: Date;

  @Column({ type: 'timestamp', name: 'period_end' })
  periodEnd!: Date;

  @Column({ type: 'decimal', precision: 20, scale: 8, name: 'total_volume' })
  totalVolume!: number;

  @Column({ type: 'decimal', precision: 20, scale: 8, name: 'commission_earned' })
  commissionEarned!: number;

  @Column({ type: 'decimal', precision: 20, scale: 8, name: 'revenue_share' })
  revenueShare!: number;

  @Column({ type: 'decimal', precision: 20, scale: 8, name: 'platform_fees' })
  platformFees!: number;

  @Column({ type: 'decimal', precision: 20, scale: 8, name: 'net_payout' })
  netPayout!: number;

  @Column({
    type: 'enum',
    enum: SettlementStatus,
    default: SettlementStatus.pending
  })
  status!: SettlementStatus;

  @Column({ type: 'timestamp', nullable: true, name: 'settlement_date' })
  settlementDate?: Date;

  @Column({ nullable: true, name: 'tx_hash' })
  txHash?: string;

  @Column({ nullable: true })
  currency!: string;

  @Column({ type: 'jsonb', nullable: true, name: 'breakdown' })
  breakdown?: {
    transactions: {
      investments: { count: number; volume: number; commission: number };
      trades: { count: number; volume: number; commission: number };
      withdrawals: { count: number; volume: number; commission: number };
    };
    fees: {
      managementFees: number;
      performanceFees: number;
      transactionFees: number;
    };
    adjustments?: {
      reason: string;
      amount: number;
    }[];
  };

  @Column({ type: 'text', nullable: true })
  notes?: string;

  @Column({ type: 'uuid', nullable: true, name: 'processed_by' })
  processedBy?: string;

  @Column({ type: 'timestamp', nullable: true, name: 'processed_at' })
  processedAt?: Date;

  @CreateDateColumn({ name: 'created_at' })
  createdAt!: Date;

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt!: Date;

  // Helper methods
  get isPending(): boolean {
    return this.status === SettlementStatus.pending;
  }

  get isProcessed(): boolean {
    return this.status === SettlementStatus.processed;
  }

  get isPaid(): boolean {
    return this.status === SettlementStatus.paid;
  }

  get isFailed(): boolean {
    return this.status === SettlementStatus.failed;
  }

  get periodDays(): number {
    const diffTime = Math.abs(this.periodEnd.getTime() - this.periodStart.getTime());
    return Math.ceil(diffTime / (1000 * 60 * 60 * 24));
  }

  get averageDailyVolume(): number {
    return this.totalVolume / this.periodDays;
  }

  get commissionRate(): number {
    return this.totalVolume > 0 ? this.commissionEarned / this.totalVolume : 0;
  }

  get totalTransactions(): number {
    if (!this.breakdown?.transactions) return 0;
    const { investments, trades, withdrawals } = this.breakdown.transactions;
    return investments.count + trades.count + withdrawals.count;
  }
}
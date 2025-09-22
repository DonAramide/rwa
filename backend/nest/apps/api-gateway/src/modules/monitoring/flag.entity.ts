import { Column, CreateDateColumn, Entity, JoinColumn, ManyToOne, PrimaryGeneratedColumn, UpdateDateColumn } from 'typeorm';
import { AssetEntity } from '../assets/asset.entity';
import { UserEntity } from '../users/user.entity';

export enum FlagType {
  SUSPICIOUS_ACTIVITY = 'suspicious_activity',
  DOCUMENT_DISCREPANCY = 'document_discrepancy',
  FINANCIAL_IRREGULARITY = 'financial_irregularity',
  MILESTONE_DELAY = 'milestone_delay',
  COMMUNICATION_ISSUE = 'communication_issue',
  LEGAL_CONCERN = 'legal_concern',
  OTHER = 'other'
}

export enum FlagStatus {
  PENDING = 'pending',
  UNDER_REVIEW = 'under_review',
  RESOLVED = 'resolved',
  DISMISSED = 'dismissed',
  ESCALATED = 'escalated'
}

export enum FlagSeverity {
  LOW = 'low',
  MEDIUM = 'medium',
  HIGH = 'high',
  CRITICAL = 'critical'
}

@Entity('flags')
export class FlagEntity {
  @PrimaryGeneratedColumn('increment')
  id!: number;

  @Column({ type: 'enum', enum: FlagType })
  type!: FlagType;

  @Column({ type: 'enum', enum: FlagStatus, default: FlagStatus.PENDING })
  status!: FlagStatus;

  @Column({ type: 'enum', enum: FlagSeverity, default: FlagSeverity.MEDIUM })
  severity!: FlagSeverity;

  @Column()
  title!: string;

  @Column({ type: 'text' })
  description!: string;

  @Column({ type: 'json', nullable: true })
  evidence?: any; // Photos, documents, URLs, etc.

  @Column({ type: 'text', nullable: true })
  admin_notes?: string;

  @Column({ type: 'text', nullable: true })
  resolution_notes?: string;

  @Column({ type: 'boolean', default: false })
  is_anonymous!: boolean;

  @Column({ type: 'integer', default: 0 })
  upvotes!: number;

  @Column({ type: 'integer', default: 0 })
  downvotes!: number;

  // Relations
  @ManyToOne(() => AssetEntity, { eager: true })
  @JoinColumn({ name: 'asset_id' })
  asset!: AssetEntity;

  @Column({ name: 'asset_id' })
  asset_id!: number;

  @ManyToOne(() => UserEntity, { eager: true })
  @JoinColumn({ name: 'flagger_id' })
  flagger!: UserEntity;

  @Column({ name: 'flagger_id' })
  flagger_id!: string;

  @ManyToOne(() => UserEntity, { nullable: true })
  @JoinColumn({ name: 'assigned_admin_id' })
  assigned_admin?: UserEntity;

  @Column({ name: 'assigned_admin_id', nullable: true })
  assigned_admin_id?: string;

  @CreateDateColumn({ name: 'created_at' })
  createdAt!: Date;

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt!: Date;
}
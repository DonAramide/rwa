import { Column, CreateDateColumn, Entity, JoinColumn, ManyToOne, PrimaryGeneratedColumn, UpdateDateColumn } from 'typeorm';
import { AssetEntity } from '../assets/asset.entity';
import { UserEntity } from '../users/user.entity';

export enum VerificationRequestType {
  ASSET_INSPECTION = 'asset_inspection',
  DOCUMENT_VERIFICATION = 'document_verification',
  FINANCIAL_AUDIT = 'financial_audit',
  COMPLIANCE_CHECK = 'compliance_check',
  SITE_VISIT = 'site_visit',
  CONDITION_ASSESSMENT = 'condition_assessment',
  OWNERSHIP_VERIFICATION = 'ownership_verification',
  VALUATION_CHECK = 'valuation_check'
}

export enum VerificationRequestStatus {
  PENDING = 'pending',
  ASSIGNED = 'assigned',
  IN_PROGRESS = 'in_progress',
  SUBMITTED = 'submitted',
  APPROVED = 'approved',
  REJECTED = 'rejected',
  CANCELLED = 'cancelled',
  DISPUTED = 'disputed'
}

export enum VerificationRequestUrgency {
  LOW = 'low',
  MEDIUM = 'medium',
  HIGH = 'high',
  URGENT = 'urgent'
}

@Entity('verification_requests')
export class VerificationRequestEntity {
  @PrimaryGeneratedColumn('increment')
  id!: number;

  @Column({ type: 'enum', enum: VerificationRequestType })
  type!: VerificationRequestType;

  @Column({ type: 'enum', enum: VerificationRequestStatus, default: VerificationRequestStatus.PENDING })
  status!: VerificationRequestStatus;

  @Column({ type: 'enum', enum: VerificationRequestUrgency, default: VerificationRequestUrgency.MEDIUM })
  urgency!: VerificationRequestUrgency;

  @Column()
  title!: string;

  @Column({ type: 'text' })
  description!: string;

  @Column({ type: 'json', nullable: true })
  requirements?: any; // Specific requirements for the verification

  @Column({ type: 'json', nullable: true })
  location?: any; // GPS coordinates, address, etc.

  @Column({ type: 'numeric', precision: 10, scale: 2 })
  budget!: string; // Maximum amount willing to pay

  @Column({ default: 'USD' })
  currency!: string;

  @Column({ type: 'timestamp', nullable: true })
  deadline?: Date;

  @Column({ type: 'json', nullable: true })
  deliverables?: any; // What the requester expects to receive

  @Column({ type: 'text', nullable: true })
  notes?: string;

  // Relations
  @ManyToOne(() => AssetEntity, { eager: true })
  @JoinColumn({ name: 'asset_id' })
  asset!: AssetEntity;

  @Column({ name: 'asset_id' })
  asset_id!: number;

  @ManyToOne(() => UserEntity, { eager: true })
  @JoinColumn({ name: 'requester_id' })
  requester!: UserEntity;

  @Column({ name: 'requester_id' })
  requester_id!: number;

  @ManyToOne(() => UserEntity, { nullable: true })
  @JoinColumn({ name: 'assigned_verifier_id' })
  assigned_verifier?: UserEntity;

  @Column({ name: 'assigned_verifier_id', nullable: true })
  assigned_verifier_id?: number;

  @CreateDateColumn({ name: 'created_at' })
  createdAt!: Date;

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt!: Date;
}

@Entity('verification_proposals')
export class VerificationProposalEntity {
  @PrimaryGeneratedColumn('increment')
  id!: number;

  @Column({ type: 'numeric', precision: 10, scale: 2 })
  proposed_price!: string;

  @Column({ default: 'USD' })
  currency!: string;

  @Column({ type: 'text' })
  proposal_message!: string;

  @Column({ type: 'timestamp' })
  estimated_completion!: Date;

  @Column({ type: 'json', nullable: true })
  methodology?: any; // How the verifier plans to conduct the verification

  @Column({ type: 'boolean', default: false })
  is_accepted!: boolean;

  // Relations
  @ManyToOne(() => VerificationRequestEntity, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'request_id' })
  request!: VerificationRequestEntity;

  @Column({ name: 'request_id' })
  request_id!: number;

  @ManyToOne(() => UserEntity, { eager: true })
  @JoinColumn({ name: 'verifier_id' })
  verifier!: UserEntity;

  @Column({ name: 'verifier_id' })
  verifier_id!: number;

  @CreateDateColumn({ name: 'created_at' })
  createdAt!: Date;

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt!: Date;
}

@Entity('verification_reports')
export class VerificationReportEntity {
  @PrimaryGeneratedColumn('increment')
  id!: number;

  @Column()
  title!: string;

  @Column({ type: 'text' })
  summary!: string;

  @Column({ type: 'json' })
  findings!: any; // Detailed findings from the verification

  @Column({ type: 'json', nullable: true })
  photos?: any; // URLs to photos taken during verification

  @Column({ type: 'json', nullable: true })
  documents?: any; // URLs to supporting documents

  @Column({ type: 'json', nullable: true })
  gps_data?: any; // GPS coordinates and path during verification

  @Column({ type: 'boolean', default: false })
  is_approved!: boolean;

  @Column({ type: 'text', nullable: true })
  reviewer_notes?: string;

  @Column({ type: 'timestamp', nullable: true })
  reviewed_at?: Date;

  // Relations
  @ManyToOne(() => VerificationRequestEntity, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'request_id' })
  request!: VerificationRequestEntity;

  @Column({ name: 'request_id' })
  request_id!: number;

  @ManyToOne(() => UserEntity, { eager: true })
  @JoinColumn({ name: 'verifier_id' })
  verifier!: UserEntity;

  @Column({ name: 'verifier_id' })
  verifier_id!: number;

  @ManyToOne(() => UserEntity, { nullable: true })
  @JoinColumn({ name: 'reviewer_id' })
  reviewer?: UserEntity;

  @Column({ name: 'reviewer_id', nullable: true })
  reviewer_id?: number;

  @CreateDateColumn({ name: 'created_at' })
  createdAt!: Date;

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt!: Date;
}
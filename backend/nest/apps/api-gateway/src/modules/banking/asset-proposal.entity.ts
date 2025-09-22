import { Column, CreateDateColumn, Entity, PrimaryGeneratedColumn, UpdateDateColumn, ManyToOne, JoinColumn, Index } from 'typeorm';
import { PartnerBankEntity } from './partner-bank.entity';
import { AssetEntity } from '../assets/asset.entity';

export enum ProposerType {
  bank = 'bank',
  investor = 'investor',
  agent = 'agent',
  verifier = 'verifier'
}

export enum ProposalStatus {
  pending = 'pending',
  under_review = 'under_review',
  approved = 'approved',
  rejected = 'rejected'
}

@Entity('asset_proposals')
@Index(['proposerType', 'proposerId'])
@Index(['status'])
@Index(['bankId'])
export class AssetProposalEntity {
  @PrimaryGeneratedColumn('uuid')
  id!: string;

  @Column({
    type: 'enum',
    enum: ProposerType,
    name: 'proposer_type'
  })
  proposerType!: ProposerType;

  @Column({ type: 'uuid', name: 'proposer_id' })
  proposerId!: string;

  @Column({ type: 'uuid', name: 'bank_id' })
  bankId!: string;

  @ManyToOne(() => PartnerBankEntity)
  @JoinColumn({ name: 'bank_id' })
  bank!: PartnerBankEntity;

  @Column({ type: 'jsonb', name: 'asset_details' })
  assetDetails!: {
    type: 'land' | 'truck' | 'hotel' | 'house' | 'real_estate' | 'other';
    title: string;
    description: string;
    location: {
      address: string;
      coordinates?: {
        lat: number;
        lng: number;
      };
      country: string;
      state?: string;
      city?: string;
    };
    financials: {
      estimatedValue: number;
      currency: string;
      expectedAnnualReturn?: number;
      initialInvestmentTarget: number;
    };
    legal: {
      ownershipType: string;
      registrationNumber?: string;
      legalDocuments: string[];
    };
    verification: {
      selfVerified: boolean;
      professionalVerificationRequired: boolean;
      thirdPartyVerificationRequired: boolean;
    };
    additional?: Record<string, any>;
  };

  @Column({ type: 'text', array: true, default: [] })
  documents!: string[];

  @Column({
    type: 'enum',
    enum: ProposalStatus,
    default: ProposalStatus.pending
  })
  status!: ProposalStatus;

  @Column({ type: 'text', nullable: true, name: 'master_admin_notes' })
  masterAdminNotes?: string;

  @Column({ type: 'uuid', nullable: true, name: 'reviewed_by' })
  reviewedBy?: string;

  @Column({ type: 'timestamp', nullable: true, name: 'reviewed_at' })
  reviewedAt?: Date;

  @Column({ type: 'jsonb', nullable: true, name: 'rejection_reasons' })
  rejectionReasons?: {
    categories: string[];
    details: string;
    suggestedImprovements?: string[];
  };

  @Column({ type: 'jsonb', nullable: true, name: 'approval_conditions' })
  approvalConditions?: {
    verificationRequired: boolean;
    additionalDocuments?: string[];
    modifiedFinancials?: {
      maxInvestmentTarget?: number;
      minInvestmentAmount?: number;
    };
    specialTerms?: string[];
  };

  @Column({ type: 'integer', nullable: true, name: 'created_asset_id' })
  createdAssetId?: number;

  @ManyToOne(() => AssetEntity, { nullable: true })
  @JoinColumn({ name: 'created_asset_id' })
  createdAsset?: AssetEntity;

  @CreateDateColumn({ name: 'created_at' })
  createdAt!: Date;

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt!: Date;

  // Helper methods
  get isPending(): boolean {
    return this.status === ProposalStatus.pending;
  }

  get isUnderReview(): boolean {
    return this.status === ProposalStatus.under_review;
  }

  get isApproved(): boolean {
    return this.status === ProposalStatus.approved;
  }

  get isRejected(): boolean {
    return this.status === ProposalStatus.rejected;
  }

  get canBeEdited(): boolean {
    return this.status === ProposalStatus.pending || this.status === ProposalStatus.rejected;
  }

  get estimatedValue(): number {
    return this.assetDetails.financials.estimatedValue;
  }

  get assetType(): string {
    return this.assetDetails.type;
  }

  get requiresVerification(): boolean {
    return this.assetDetails.verification.professionalVerificationRequired ||
           this.assetDetails.verification.thirdPartyVerificationRequired;
  }
}
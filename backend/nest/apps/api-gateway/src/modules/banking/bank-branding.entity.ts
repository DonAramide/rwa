import { Column, CreateDateColumn, Entity, PrimaryGeneratedColumn, UpdateDateColumn, ManyToOne, JoinColumn, Index } from 'typeorm';
import { PartnerBankEntity } from './partner-bank.entity';

@Entity('bank_branding')
@Index(['bankId'])
export class BankBrandingEntity {
  @PrimaryGeneratedColumn('uuid')
  id!: string;

  @Column({ type: 'uuid', name: 'bank_id' })
  bankId!: string;

  @ManyToOne(() => PartnerBankEntity)
  @JoinColumn({ name: 'bank_id' })
  bank!: PartnerBankEntity;

  @Column({ nullable: true, name: 'logo_url' })
  logoUrl?: string;

  @Column({ nullable: true, name: 'favicon_url' })
  faviconUrl?: string;

  @Column({ nullable: true, name: 'primary_color' })
  primaryColor?: string;

  @Column({ nullable: true, name: 'secondary_color' })
  secondaryColor?: string;

  @Column({ type: 'jsonb', nullable: true, name: 'theme_config' })
  themeConfig?: {
    colors?: {
      accent?: string;
      success?: string;
      warning?: string;
      error?: string;
      background?: string;
      surface?: string;
      onPrimary?: string;
      onSecondary?: string;
    };
    typography?: {
      fontFamily?: string;
      headingFont?: string;
      bodyFont?: string;
    };
    layout?: {
      borderRadius?: string;
      spacing?: string;
      shadows?: boolean;
    };
    branding?: {
      showLogo?: boolean;
      logoPosition?: 'left' | 'center' | 'right';
      tagline?: string;
    };
  };

  @Column({ nullable: true, name: 'custom_domain' })
  customDomain?: string;

  @Column({ type: 'jsonb', nullable: true, name: 'custom_css' })
  customCss?: {
    variables?: Record<string, string>;
    rules?: string[];
  };

  @Column({ type: 'jsonb', nullable: true, name: 'email_templates' })
  emailTemplates?: {
    welcome?: string;
    kyc_approval?: string;
    investment_confirmation?: string;
    payout_notification?: string;
  };

  @CreateDateColumn({ name: 'created_at' })
  createdAt!: Date;

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt!: Date;

  // Helper methods
  get hasCustomTheme(): boolean {
    return this.themeConfig !== null && Object.keys(this.themeConfig || {}).length > 0;
  }

  get hasCustomDomain(): boolean {
    return !!this.customDomain;
  }

  get effectivePrimaryColor(): string {
    return this.primaryColor || this.themeConfig?.colors?.accent || '#1976d2';
  }

  get effectiveSecondaryColor(): string {
    return this.secondaryColor || this.themeConfig?.colors?.secondary || '#424242';
  }
}
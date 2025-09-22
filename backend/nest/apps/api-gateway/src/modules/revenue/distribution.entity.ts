import { Column, CreateDateColumn, Entity, PrimaryGeneratedColumn } from 'typeorm';

@Entity('distributions')
export class DistributionEntity {
  @PrimaryGeneratedColumn('increment')
  id!: number;

  @Column()
  asset_id!: number;

  @Column({ type: 'tstzrange', name: 'period' })
  period!: any;

  @Column({ type: 'numeric', precision: 18, scale: 2 })
  gross!: string;

  @Column({ type: 'int', default: 0, name: 'mgmt_fee_bps' })
  mgmtFeeBps!: number;

  @Column({ type: 'int', default: 0, name: 'carry_bps' })
  carryBps!: number;

  @Column({ type: 'numeric', precision: 18, scale: 2 })
  net!: string;

  @Column({ type: 'text', nullable: true, name: 'tx_hash' })
  txHash?: string;

  @CreateDateColumn({ name: 'created_at' })
  createdAt!: Date;
}















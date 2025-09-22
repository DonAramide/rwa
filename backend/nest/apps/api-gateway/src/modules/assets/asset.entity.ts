import { Column, CreateDateColumn, Entity, PrimaryGeneratedColumn } from 'typeorm';

export enum AssetType { land='land', truck='truck', hotel='hotel', house='house', other='other' }

@Entity('assets')
export class AssetEntity {
  @PrimaryGeneratedColumn('increment')
  id!: number;

  @Column({ type: 'enum', enum: AssetType })
  type!: AssetType;

  @Column()
  title!: string;

  @Column({ type: 'text', nullable: true })
  spv_id?: string;

  @Column({ type: 'text', nullable: true })
  status?: string;

  @Column({ type: 'numeric', precision: 18, scale: 2, nullable: true })
  nav?: string;

  @Column({ type: 'boolean', default: true })
  verification_required!: boolean;

  @CreateDateColumn({ name: 'created_at' })
  createdAt!: Date;
}
























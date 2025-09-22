import { Column, CreateDateColumn, Entity, PrimaryGeneratedColumn } from 'typeorm';

export enum OrderSide { buy='buy', sell='sell' }
export enum OrderStatus { open='open', partially_filled='partially_filled', filled='filled', cancelled='cancelled' }

@Entity('orders')
export class OrderEntity {
  @PrimaryGeneratedColumn('increment')
  id!: number;

  @Column()
  user_id!: number;

  @Column()
  asset_id!: number;

  @Column({ type: 'enum', enum: OrderSide })
  side!: OrderSide;

  @Column({ type: 'numeric', precision: 38, scale: 18 })
  qty!: string;

  @Column({ type: 'numeric', precision: 18, scale: 6 })
  price!: string;

  @Column({ type: 'enum', enum: OrderStatus, default: OrderStatus.open })
  status!: OrderStatus;

  @Column({ type: 'numeric', precision: 38, scale: 18, default: '0' })
  filled_qty!: string;

  @CreateDateColumn({ name: 'created_at' })
  createdAt!: Date;
}
























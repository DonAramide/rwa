import { Column, CreateDateColumn, Entity, PrimaryGeneratedColumn } from 'typeorm';

export enum AgentStatus { pending='pending', approved='approved', suspended='suspended' }

@Entity('agents')
export class AgentEntity {
  @PrimaryGeneratedColumn('increment')
  id!: number;

  @Column()
  user_id!: number;

  @Column({ type: 'enum', enum: AgentStatus, default: AgentStatus.pending })
  status!: AgentStatus;

  @Column('text', { array: true, nullable: true })
  regions?: string[];

  @Column('text', { array: true, nullable: true })
  skills?: string[];

  @Column({ type: 'text', nullable: true })
  bio?: string;

  @Column({ type: 'double precision', default: 0 })
  rating_avg!: number;

  @Column({ type: 'int', default: 0 })
  rating_count!: number;

  @CreateDateColumn({ name: 'created_at' })
  createdAt!: Date;
}















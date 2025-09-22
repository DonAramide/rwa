import { Column, CreateDateColumn, Entity, JoinColumn, ManyToOne, PrimaryGeneratedColumn, Unique } from 'typeorm';
import { FlagEntity } from './flag.entity';
import { UserEntity } from '../users/user.entity';

export enum VoteType {
  UPVOTE = 'upvote',
  DOWNVOTE = 'downvote'
}

@Entity('flag_votes')
@Unique(['flag_id', 'voter_id']) // Prevent duplicate votes
export class FlagVoteEntity {
  @PrimaryGeneratedColumn('increment')
  id!: number;

  @Column({ type: 'enum', enum: VoteType })
  vote_type!: VoteType;

  // Relations
  @ManyToOne(() => FlagEntity, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'flag_id' })
  flag!: FlagEntity;

  @Column({ name: 'flag_id' })
  flag_id!: number;

  @ManyToOne(() => UserEntity)
  @JoinColumn({ name: 'voter_id' })
  voter!: UserEntity;

  @Column({ name: 'voter_id' })
  voter_id!: number;

  @CreateDateColumn({ name: 'created_at' })
  createdAt!: Date;
}
import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AdminController } from './admin.controller';

// Import entities
import { UserEntity } from '../users/user.entity';
import { AssetEntity } from '../assets/asset.entity';
import { AgentEntity } from '../agents/agent.entity';
import { DistributionEntity } from '../revenue/distribution.entity';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      UserEntity,
      AssetEntity,
      AgentEntity,
      DistributionEntity,
    ]),
  ],
  controllers: [AdminController],
  providers: [],
  exports: [],
})
export class AdminModule {}
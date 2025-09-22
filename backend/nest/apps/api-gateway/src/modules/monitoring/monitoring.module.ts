import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { MonitoringController } from './monitoring.controller';
import { MonitoringService } from './monitoring.service';
import { FlagEntity } from './flag.entity';
import { FlagVoteEntity } from './flag-vote.entity';
import { UserEntity } from '../users/user.entity';
import { AssetEntity } from '../assets/asset.entity';
import { UsersModule } from '../users/users.module';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      FlagEntity,
      FlagVoteEntity,
      UserEntity,
      AssetEntity
    ]),
    UsersModule
  ],
  controllers: [MonitoringController],
  providers: [MonitoringService],
  exports: [MonitoringService]
})
export class MonitoringModule {}
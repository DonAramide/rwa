import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { VerificationRequestController } from './verification-request.controller';
import { VerificationRequestService } from './verification-request.service';
import {
  VerificationRequestEntity,
  VerificationProposalEntity,
  VerificationReportEntity
} from './verification-request.entity';
import { UserEntity } from '../users/user.entity';
import { AssetEntity } from '../assets/asset.entity';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      VerificationRequestEntity,
      VerificationProposalEntity,
      VerificationReportEntity,
      UserEntity,
      AssetEntity
    ])
  ],
  controllers: [VerificationRequestController],
  providers: [VerificationRequestService],
  exports: [VerificationRequestService]
})
export class VerificationRequestModule {}
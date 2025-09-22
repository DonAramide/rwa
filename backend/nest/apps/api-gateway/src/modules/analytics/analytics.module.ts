import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { PartnerBankEntity } from '../banking/partner-bank.entity';
import { AssetProposalEntity } from '../banking/asset-proposal.entity';
import { BankSettlementEntity } from '../banking/bank-settlement.entity';
import { AssetEntity } from '../assets/asset.entity';
import { AnalyticsService } from './analytics.service';
import { AnalyticsController } from './analytics.controller';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      PartnerBankEntity,
      AssetProposalEntity,
      BankSettlementEntity,
      AssetEntity,
    ]),
  ],
  controllers: [AnalyticsController],
  providers: [AnalyticsService],
  exports: [AnalyticsService, TypeOrmModule],
})
export class AnalyticsModule {}
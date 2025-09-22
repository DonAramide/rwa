import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { PartnerBankEntity } from './partner-bank.entity';
import { BankBrandingEntity } from './bank-branding.entity';
import { AssetProposalEntity } from './asset-proposal.entity';
import { BankSettlementEntity } from './bank-settlement.entity';
import { AssetEntity } from '../assets/asset.entity';
import { BankingService } from './banking.service';
import { BankingController } from './banking.controller';
import { MasterAdminController } from './master-admin.controller';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      PartnerBankEntity,
      BankBrandingEntity,
      AssetProposalEntity,
      BankSettlementEntity,
      AssetEntity,
    ]),
  ],
  controllers: [BankingController, MasterAdminController],
  providers: [BankingService],
  exports: [BankingService, TypeOrmModule],
})
export class BankingModule {}
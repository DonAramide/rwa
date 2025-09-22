import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { AuthModule } from './auth/auth.module';
import { AdminModule } from './admin/admin.module';
import { AssetsModule } from './assets/assets.module';
import { InvestModule } from './invest/invest.module';
import { MarketplaceModule } from './marketplace/marketplace.module';
import { RevenueModule } from './revenue/revenue.module';
import { IotModule } from './iot/iot.module';
import { AgentsModule } from './agents/agents.module';
import { NotificationsModule } from './notifications/notifications.module';
import { BankingModule } from './banking/banking.module';
import { AnalyticsModule } from './analytics/analytics.module';
// import { MonitoringModule } from './monitoring/monitoring.module';
// import { VerificationRequestModule } from './verification/verification-request.module';
import { DbModule } from './db/db.module';
import { HealthController } from './health.controller';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    DbModule,
    AuthModule,
    AdminModule,
    AssetsModule,
    InvestModule,
    MarketplaceModule,
    RevenueModule,
    IotModule,
    AgentsModule,
    NotificationsModule,
    BankingModule,
    AnalyticsModule,
    // MonitoringModule,
    // VerificationRequestModule,
  ],
  controllers: [HealthController],
})
export class AppModule {}



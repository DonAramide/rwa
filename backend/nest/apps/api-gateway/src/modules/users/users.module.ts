import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { UserEntity } from './user.entity';
import { UsersService } from './users.service';
// import { InvestorAgentService } from './investor-agent.service';

@Module({
  imports: [TypeOrmModule.forFeature([UserEntity])],
  providers: [UsersService], // InvestorAgentService - temporarily disabled
  exports: [UsersService], // InvestorAgentService - temporarily disabled
})
export class UsersModule {}
























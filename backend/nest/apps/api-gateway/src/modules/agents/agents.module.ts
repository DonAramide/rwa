import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AgentsController } from './agents.controller';
import { AgentsService } from './agents.service';
import { VerificationJobsService } from './verification-jobs.service';
import { AgentEntity } from './agent.entity';

@Module({
  imports: [TypeOrmModule.forFeature([AgentEntity])],
  controllers: [AgentsController],
  providers: [AgentsService, VerificationJobsService],
  exports: [AgentsService, VerificationJobsService],
})
export class AgentsModule {}



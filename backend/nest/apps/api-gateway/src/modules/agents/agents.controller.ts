import { Controller, Get, Post, Patch, Param, Body, UseGuards, Query } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt.guard';
import { AgentsService } from './agents.service';
import { VerificationJobsService } from './verification-jobs.service';

@Controller()
export class AgentsController {
  constructor(
    private readonly agents: AgentsService,
    private readonly jobs: VerificationJobsService,
  ) {}

  @Post('agents/apply')
  @UseGuards(JwtAuthGuard)
  apply(@Body() body: any) { 
    return this.agents.create(body);
  }

  @Get('agents/search')
  search(
    @Query('regions') regions?: string, 
    @Query('skills') skills?: string, 
    @Query('minRating') minRating?: string,
    @Query('limit') limit?: string,
    @Query('offset') offset?: string
  ) { 
    return this.agents.findAll({ 
      regions: regions ? regions.split(',') : undefined,
      skills: skills ? skills.split(',') : undefined,
      rating_gte: minRating ? Number(minRating) : undefined,
      limit: limit ? Number(limit) : 20,
      offset: offset ? Number(offset) : 0
    });
  }

  @Patch('admin/agents/:id')
  @UseGuards(JwtAuthGuard)
  update(@Param('id') id: string, @Body() body: any) { 
    return this.agents.update(Number(id), body);
  }

  @Post('verification/jobs')
  @UseGuards(JwtAuthGuard)
  createJob(@Body() body: any) { 
    return this.jobs.create(body);
  }

  @Get('verification/jobs/:id')
  getJob(@Param('id') id: string) { 
    return this.jobs.findOne(Number(id));
  }

  @Patch('verification/jobs/:id')
  @UseGuards(JwtAuthGuard)
  updateJob(@Param('id') id: string, @Body() body: any) { 
    return this.jobs.update(Number(id), body);
  }

  @Post('verification/jobs/:id/report')
  @UseGuards(JwtAuthGuard)
  submitReport(@Param('id') id: string, @Body() body: any) { 
    return this.jobs.update(Number(id), { status: 'submitted' });
  }

  @Post('verification/jobs/:id/accept')
  @UseGuards(JwtAuthGuard)
  accept(@Param('id') id: string) { 
    return this.jobs.update(Number(id), { status: 'accepted' });
  }

  @Post('verification/jobs/:id/reject')
  @UseGuards(JwtAuthGuard)
  reject(@Param('id') id: string, @Body() body: any) { 
    return this.jobs.update(Number(id), { status: 'rejected' });
  }

  @Post('agents/:id/reviews')
  @UseGuards(JwtAuthGuard)
  review(@Param('id') id: string, @Body() body: any) { 
    return { agent: id, created: true };
  }
}



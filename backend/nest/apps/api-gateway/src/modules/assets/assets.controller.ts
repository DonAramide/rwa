import { Controller, Get, Param, Post, Body, UseGuards, Query } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt.guard';
import { AssetsService } from './assets.service';
import { AssetType } from './asset.entity';

@Controller()
export class AssetsController {
  constructor(private readonly assets: AssetsService) {}
  @Get('assets')
  list(
    @Query('type') type?: AssetType, 
    @Query('status') status?: string,
    @Query('search') search?: string,
    @Query('limit') limit?: string,
    @Query('offset') offset?: string
  ) {
    return this.assets.findAll({ 
      type, 
      status,
      search,
      limit: limit ? Number(limit) : 20,
      offset: offset ? Number(offset) : 0
    });
  }

  @Get('assets/:id')
  get(@Param('id') id: string) {
    return this.assets.findOne(Number(id));
  }

  @Post('admin/assets')
  @UseGuards(JwtAuthGuard)
  create(@Body() body: any) {
    return this.assets.create(body);
  }

  @Post('admin/assets/:id/verify')
  @UseGuards(JwtAuthGuard)
  verify(@Param('id') id: string) {
    return this.assets.update(Number(id), { status: 'verified' });
  }
}



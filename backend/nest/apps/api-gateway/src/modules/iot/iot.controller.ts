import { Controller, Get, Param, Post, Body, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt.guard';

@Controller()
export class IotController {
  @Post('iot/telemetry')
  @UseGuards(JwtAuthGuard)
  ingest(@Body() body: any) { return { accepted: true }; }

  @Get('assets/:id/telemetry')
  recent(@Param('id') id: string) { return []; }
}



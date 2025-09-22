import { Body, Controller, Get, Post, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt.guard';
import { NotificationsService } from './notifications.service';

@Controller('notifications')
export class NotificationsController {
  constructor(private readonly notifications: NotificationsService) {}

  @Post('register')
  @UseGuards(JwtAuthGuard)
  register(@Body() body: { user_id: string; token: string }) {
    return this.notifications.registerToken(body.user_id, body.token);
  }

  @Post('test')
  @UseGuards(JwtAuthGuard)
  async test(@Body() body: { user_id: string; title?: string; body?: string }) {
    return this.notifications.sendTestPush(body.user_id, body.title, body.body);
  }

  @Get('tokens')
  list() {
    return this.notifications.getAllTokens();
  }
}



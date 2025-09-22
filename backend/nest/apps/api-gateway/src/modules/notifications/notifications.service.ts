import { Injectable } from '@nestjs/common';

@Injectable()
export class NotificationsService {
  // In-memory stub; replace with proper persistence
  private tokens: Record<string, string[]> = {};

  registerToken(userId: string, token: string) {
    if (!this.tokens[userId]) this.tokens[userId] = [];
    if (!this.tokens[userId].includes(token)) this.tokens[userId].push(token);
    return { ok: true, count: this.tokens[userId].length };
  }

  getTokens(userId: string) {
    return this.tokens[userId] || [];
  }

  getAllTokens() {
    return this.tokens;
  }

  async sendTestPush(userId: string, title?: string, body?: string) {
    const tokens = this.getTokens(userId);
    // TODO: Integrate with FCM server SDK
    return { ok: true, sent_to: tokens.length, message: 'Test push sent (stubbed)' };
  }
}













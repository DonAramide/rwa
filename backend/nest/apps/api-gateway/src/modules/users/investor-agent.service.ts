import { Injectable, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { UserEntity, UserRole } from './user.entity';

@Injectable()
export class InvestorAgentService {
  private readonly logger = new Logger(InvestorAgentService.name);

  constructor(
    @InjectRepository(UserEntity)
    private userRepository: Repository<UserEntity>,
  ) {}

  /**
   * Auto-upgrade investor to investor-agent after their first investment
   */
  async upgradeToInvestorAgent(userId: string): Promise<UserEntity> {
    const user = await this.userRepository.findOne({ where: { id: userId } });
    if (!user) {
      throw new Error('User not found');
    }

    // Only upgrade investors who aren't already investor-agents
    if (user.role !== UserRole.investor /* || user.isInvestorAgent*/) {
      return user;
    }

    this.logger.log(`Auto-upgrading user ${userId} to investor-agent`);

    user.role = UserRole.investor_agent;
    // user.isInvestorAgent = true;
    // user.investorAgentSince = new Date();

    return await this.userRepository.save(user);
  }

  /**
   * Update investor-agent statistics after flag resolution
   */
  async updateStats(userId: string, flagResolved: boolean): Promise<void> {
    const user = await this.userRepository.findOne({ where: { id: userId } });
    if (!user || user.role !== UserRole.investor_agent) {
      return;
    }

    // user.totalFlagsSubmitted++;
    // if (flagResolved) {
    //   user.totalFlagsResolved++;
    // }

    // // Update reputation score (0-100 based on accuracy)
    // user.reputationScore = Math.round(user.accuracyRate * 100);

    await this.userRepository.save(user);

    this.logger.log(
      `Updated stats for investor-agent ${userId}: stats tracking temporarily disabled`
    );
  }

  /**
   * Get investor-agent leaderboard
   */
  async getLeaderboard(limit: number = 10): Promise<UserEntity[]> {
    return await this.userRepository.find({
      where: { role: UserRole.investor_agent },
      order: { createdAt: 'DESC' },
      take: limit,
      select: [
        'id', 'firstName', 'lastName', 'email', 'createdAt'
      ]
    });
  }

  /**
   * Check if user has made investments (simplified check)
   */
  async hasInvestments(userId: number): Promise<boolean> {
    // This would normally check the investments/holdings table
    // For now, we'll implement a simple check
    // TODO: Integrate with actual investment tracking
    return true; // Placeholder
  }
}
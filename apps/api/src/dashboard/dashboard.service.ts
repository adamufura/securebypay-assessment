import { Injectable, UnauthorizedException } from '@nestjs/common';
import { UsersService } from '../users/users.service';

@Injectable()
export class DashboardService {
  constructor(private readonly usersService: UsersService) {}

  async getDashboard(userId: string) {
    const user = await this.usersService.findById(userId);
    if (!user) {
      throw new UnauthorizedException('Invalid token');
    }

    return {
      balance: user.walletBalance,
      currency: 'NGN',
      period: 'this_month',
      stats: {
        totalShipments: { value: 34, changePercent: 90, previous: 4 },
        totalExports: { value: 34, changePercent: 90, previous: 4 },
        totalImports: { value: 34, changePercent: 90, previous: 4 },
      },
      growth: {
        year: [0, 280, 320, 350, 360, 420, 340, 480, 500, 420, 180, 980],
        month: [120, 180, 160, 220, 260, 240, 300],
        week: [40, 80, 60, 90, 120, 100, 140],
      },
    };
  }
}

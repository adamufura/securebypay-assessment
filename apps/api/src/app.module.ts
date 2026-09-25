import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { AuthModule } from './auth/auth.module';
import { UsersModule } from './users/users.module';
import { ShipmentsModule } from './shipments/shipments.module';
import { DashboardModule } from './dashboard/dashboard.module';
import { HealthController } from './health/health.controller';
import { env } from './config/env';

@Module({
  imports: [
    MongooseModule.forRoot(env.mongodbUri),
    UsersModule,
    ShipmentsModule,
    AuthModule,
    DashboardModule,
  ],
  controllers: [HealthController],
})
export class AppModule {}

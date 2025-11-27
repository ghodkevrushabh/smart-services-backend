import { Module } from '@nestjs/common';
import { AuthService } from './auth.service';
import { AuthController } from './auth.controller';
import { UsersModule } from '../users/users.module';
import { JwtModule } from '@nestjs/jwt';

@Module({
  imports: [
    UsersModule,
    // This configures the "ID Card Machine"
    JwtModule.register({
      global: true,
      secret: 'MY_TEMPORARY_SECRET_KEY_123', // We will move this to .env later
      signOptions: { expiresIn: '60d' }, // Token lasts for 60 days
    }),
  ],
  providers: [AuthService],
  controllers: [AuthController],
})
export class AuthModule {}
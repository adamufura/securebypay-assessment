import {
  ConflictException,
  Injectable,
  Logger,
  UnauthorizedException,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcryptjs';
import { randomBytes } from 'crypto';
import { UsersService } from '../users/users.service';
import { ShipmentsService } from '../shipments/shipments.service';
import { RegisterDto } from './dto/register.dto';
import { LoginDto } from './dto/login.dto';

@Injectable()
export class AuthService {
  private readonly logger = new Logger(AuthService.name);

  constructor(
    private readonly usersService: UsersService,
    private readonly shipmentsService: ShipmentsService,
    private readonly jwtService: JwtService,
  ) {}

  async register(dto: RegisterDto) {
    const email = dto.email.trim().toLowerCase();
    const phoneNumber = dto.phoneNumber.replace(/\s+/g, '');

    const existingEmail = await this.usersService.findByEmail(email);
    if (existingEmail) {
      throw new ConflictException({
        message: 'Email is already registered',
        errors: [
          { field: 'email', message: 'Email is already registered' },
        ],
      });
    }

    const existingPhone = await this.usersService.findByPhone(
      dto.phoneCountryCode,
      phoneNumber,
    );
    if (existingPhone) {
      throw new ConflictException({
        message: 'Phone number is already registered',
        errors: [
          {
            field: 'phoneNumber',
            message: 'Phone number is already registered',
          },
        ],
      });
    }

    const passwordHash = await bcrypt.hash(dto.password, 10);
    const user = await this.usersService.create({
      firstName: dto.firstName.trim(),
      lastName: dto.lastName.trim(),
      email,
      phoneCountryCode: dto.phoneCountryCode,
      phoneNumber,
      passwordHash,
    });

    await this.shipmentsService.seedForUser(user._id);

    const accessToken = await this.signToken(user._id.toString(), user.email);
    return {
      user: this.usersService.toPublic(user),
      accessToken,
    };
  }

  async login(dto: LoginDto) {
    const email = dto.email.trim().toLowerCase();
    const user = await this.usersService.findByEmail(email);
    if (!user) {
      throw new UnauthorizedException('Invalid email or password');
    }

    const ok = await bcrypt.compare(dto.password, user.passwordHash);
    if (!ok) {
      throw new UnauthorizedException('Invalid email or password');
    }

    const accessToken = await this.signToken(user._id.toString(), user.email);
    return {
      user: this.usersService.toPublic(user),
      accessToken,
    };
  }

  async me(userId: string) {
    const user = await this.usersService.findById(userId);
    if (!user) {
      throw new UnauthorizedException('Invalid token');
    }
    return this.usersService.toPublic(user);
  }

  async forgotPassword(email: string) {
    const normalized = email.trim().toLowerCase();
    const user = await this.usersService.findByEmail(normalized);
    if (user) {
      const token = randomBytes(24).toString('hex');
      this.logger.log(
        `Password reset token for ${normalized}: ${token} (demo only, not emailed)`,
      );
    }
    return {
      success: true,
      message: 'If that email exists, a reset link has been sent.',
    };
  }

  private signToken(userId: string, email: string): Promise<string> {
    return this.jwtService.signAsync({ sub: userId, email });
  }
}

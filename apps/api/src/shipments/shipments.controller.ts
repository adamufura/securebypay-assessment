import { Controller, Get, Req, UseGuards } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { ShipmentsService } from './shipments.service';
import { Request } from 'express';

@Controller('shipments')
@UseGuards(AuthGuard('jwt'))
export class ShipmentsController {
  constructor(private readonly shipmentsService: ShipmentsService) {}

  @Get()
  async list(@Req() req: Request & { user: { userId: string } }) {
    const items = await this.shipmentsService.findByUser(req.user.userId);
    return {
      items: items.map((s) => this.shipmentsService.toPublic(s)),
    };
  }
}

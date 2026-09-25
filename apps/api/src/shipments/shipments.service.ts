import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import { Shipment, ShipmentDocument } from './shipment.schema';

const SEED_SHIPMENTS = [
  {
    trackingId: 'MAF-100-234-291',
    sender: 'Bunmi Tanny',
    receiver: 'Mercy',
    pickupFrom: 'Lagos, Nigeria',
    deliveryTo: 'Oyo Nigeria',
    amount: 3000,
    status: 'in_transit' as const,
    paymentStatus: 'paid' as const,
    processingHours: 10,
  },
  {
    trackingId: 'MAF-100-234-292',
    sender: 'Bunmi Tanny',
    receiver: 'Mercy',
    pickupFrom: 'Lagos, Nigeria',
    deliveryTo: 'Oyo Nigeria',
    amount: 3000,
    status: 'delayed' as const,
    paymentStatus: 'unpaid' as const,
    processingHours: 10,
  },
  {
    trackingId: 'MAF-100-234-293',
    sender: 'Ada Okafor',
    receiver: 'Chidi Bello',
    pickupFrom: 'Abuja, Nigeria',
    deliveryTo: 'Accra, Ghana',
    amount: 18500,
    status: 'in_transit' as const,
    paymentStatus: 'paid' as const,
    processingHours: 6,
  },
];

@Injectable()
export class ShipmentsService {
  constructor(
    @InjectModel(Shipment.name)
    private readonly shipmentModel: Model<ShipmentDocument>,
  ) {}

  async seedForUser(userId: Types.ObjectId | string): Promise<void> {
    const uid = typeof userId === 'string' ? new Types.ObjectId(userId) : userId;
    await this.shipmentModel.insertMany(
      SEED_SHIPMENTS.map((s) => ({ ...s, userId: uid })),
    );
  }

  async findByUser(userId: string): Promise<ShipmentDocument[]> {
    return this.shipmentModel
      .find({ userId: new Types.ObjectId(userId) })
      .sort({ createdAt: -1 })
      .exec();
  }

  toPublic(shipment: ShipmentDocument) {
    return {
      id: shipment._id.toString(),
      trackingId: shipment.trackingId,
      sender: shipment.sender,
      receiver: shipment.receiver,
      pickupFrom: shipment.pickupFrom,
      deliveryTo: shipment.deliveryTo,
      amount: shipment.amount,
      status: shipment.status,
      paymentStatus: shipment.paymentStatus,
      processingHours: shipment.processingHours,
    };
  }
}

import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { HydratedDocument, Types } from 'mongoose';

export type ShipmentDocument = HydratedDocument<Shipment>;

export type ShipmentStatus = 'in_transit' | 'delayed' | 'delivered';
export type PaymentStatus = 'paid' | 'unpaid';

@Schema({ timestamps: true })
export class Shipment {
  @Prop({ type: Types.ObjectId, ref: 'User', required: true, index: true })
  userId: Types.ObjectId;

  @Prop({ required: true })
  trackingId: string;

  @Prop({ required: true })
  sender: string;

  @Prop({ required: true })
  receiver: string;

  @Prop({ required: true })
  pickupFrom: string;

  @Prop({ required: true })
  deliveryTo: string;

  @Prop({ required: true })
  amount: number;

  @Prop({ required: true, enum: ['in_transit', 'delayed', 'delivered'] })
  status: ShipmentStatus;

  @Prop({ required: true, enum: ['paid', 'unpaid'] })
  paymentStatus: PaymentStatus;

  @Prop({ required: true })
  processingHours: number;
}

export const ShipmentSchema = SchemaFactory.createForClass(Shipment);

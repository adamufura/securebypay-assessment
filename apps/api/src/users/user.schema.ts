import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { HydratedDocument } from 'mongoose';

export type UserDocument = HydratedDocument<User>;

@Schema({ timestamps: true })
export class User {
  @Prop({ required: true, trim: true, minlength: 2, maxlength: 50 })
  firstName: string;

  @Prop({ required: true, trim: true, minlength: 2, maxlength: 50 })
  lastName: string;

  @Prop({ required: true, unique: true, lowercase: true, trim: true })
  email: string;

  @Prop({ required: true })
  phoneCountryCode: string;

  @Prop({ required: true })
  phoneNumber: string;

  @Prop({ required: true })
  passwordHash: string;

  @Prop({ required: true, default: 3000000.28 })
  walletBalance: number;
}

export const UserSchema = SchemaFactory.createForClass(User);

UserSchema.index(
  { phoneCountryCode: 1, phoneNumber: 1 },
  { unique: true },
);

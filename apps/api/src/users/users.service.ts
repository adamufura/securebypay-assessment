import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { User, UserDocument } from './user.schema';

@Injectable()
export class UsersService {
  constructor(
    @InjectModel(User.name) private readonly userModel: Model<UserDocument>,
  ) {}

  async findByEmail(email: string): Promise<UserDocument | null> {
    return this.userModel.findOne({ email: email.toLowerCase() }).exec();
  }

  async findById(id: string): Promise<UserDocument | null> {
    return this.userModel.findById(id).exec();
  }

  async findByPhone(
    phoneCountryCode: string,
    phoneNumber: string,
  ): Promise<UserDocument | null> {
    return this.userModel.findOne({ phoneCountryCode, phoneNumber }).exec();
  }

  async create(data: {
    firstName: string;
    lastName: string;
    email: string;
    phoneCountryCode: string;
    phoneNumber: string;
    passwordHash: string;
  }): Promise<UserDocument> {
    const user = new this.userModel({
      ...data,
      email: data.email.toLowerCase(),
      walletBalance: 3000000.28,
    });
    return user.save();
  }

  toPublic(user: UserDocument) {
    return {
      id: user._id.toString(),
      firstName: user.firstName,
      lastName: user.lastName,
      email: user.email,
      phoneCountryCode: user.phoneCountryCode,
      phoneNumber: user.phoneNumber,
    };
  }
}

import {
  IsEmail,
  IsString,
  Matches,
  MaxLength,
  MinLength,
} from 'class-validator';

export class RegisterDto {
  @IsString()
  @MinLength(2)
  @MaxLength(50)
  firstName: string;

  @IsString()
  @MinLength(2)
  @MaxLength(50)
  lastName: string;

  @IsEmail()
  email: string;

  @IsString()
  @Matches(/^\+\d{1,4}$/, {
    message: 'phoneCountryCode must be like +234',
  })
  phoneCountryCode: string;

  @IsString()
  @Matches(/^\d{7,15}$/, {
    message: 'phoneNumber must be 7-15 digits',
  })
  phoneNumber: string;

  @IsString()
  @MinLength(8)
  @Matches(/^(?=.*[A-Za-z])(?=.*\d).+$/, {
    message: 'password must contain at least one letter and one number',
  })
  password: string;
}

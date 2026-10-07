import {
  IsEmail,
  IsNotEmpty,
  IsString,
  MinLength,
  registerDecorator,
  ValidationOptions,
  ValidationArguments,
} from 'class-validator';

export function Match(property: string, validationOptions?: ValidationOptions) {
  return function (object: Object, propertyName: string) {
    registerDecorator({
      name: 'match',
      target: object.constructor,
      propertyName: propertyName,
      options: validationOptions,
      constraints: [property],
      validator: {
        validate(value: any, args: ValidationArguments) {
          const [relatedPropertyName] = args.constraints;
          const relatedValue = (args.object as any)[relatedPropertyName];
          return value === relatedValue;
        },
      },
    });
  };
}

export class ResetPasswordDto {
  @IsEmail({}, { message: 'Email không hợp lệ' })
  @IsNotEmpty({ message: 'Vui lòng nhập email' })
  email: string;

  @IsNotEmpty({ message: 'Vui lòng nhập mã OTP' })
  @IsString()
  otp: string;

  @IsNotEmpty({ message: 'Vui lòng nhập mật khẩu mới' })
  @IsString()
  newPassword: string;

  @IsNotEmpty({ message: 'Vui lòng nhập mật khẩu xác nhận' })
  @IsString()
  @Match('newPassword', { message: 'Mật khẩu xác nhận không khớp' })
  confirmPassword: string;
}

export class ChangePasswordDto {
  @IsNotEmpty({ message: 'Vui lòng nhập mật khẩu cũ' })
  @IsString({ message: 'Mật khẩu cũ phải là chuỗi ký tự' })
  oldPassword: string;

  @IsNotEmpty({ message: 'Vui lòng nhập mật khẩu mới' })
  @IsString({ message: 'Mật khẩu mới phải là chuỗi ký tự' })
  @MinLength(6, { message: 'Mật khẩu mới phải có ít nhất 6 ký tự' })
  newPassword: string;

  @IsNotEmpty({ message: 'Vui lòng xác nhận mật khẩu mới' })
  @IsString({ message: 'Mật khẩu xác nhận phải là chuỗi ký tự' })
  @Match('newPassword', { message: 'Mật khẩu xác nhận không khớp' })
  confirmPassword: string;
}


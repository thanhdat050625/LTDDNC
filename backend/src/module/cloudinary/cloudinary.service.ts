import { Injectable, InternalServerErrorException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { v2 as cloudinary, UploadApiResponse } from 'cloudinary';
import 'multer';
import * as streamifier from 'streamifier';
import { ENV_VARS } from 'src/constants/env.constants';

@Injectable()
export class CloudinaryService {
  private readonly folder: string;

  constructor(private readonly configService: ConfigService) {
    const cloudName = this.getRequiredEnv(ENV_VARS.CLOUDINARY_CLOUD_NAME);
    const apiKey = this.getRequiredEnv(ENV_VARS.CLOUDINARY_API_KEY);
    const apiSecret = this.getRequiredEnv(ENV_VARS.CLOUDINARY_API_SECRET);
    this.folder = this.getRequiredEnv(ENV_VARS.CLOUDINARY_FOLDER);

    cloudinary.config({
      cloud_name: cloudName,
      api_key: apiKey,
      api_secret: apiSecret,
    });
  }

  private getRequiredEnv(key: string): string {
    const value = this.configService.get<string>(key);
    if (!value) {
      throw new InternalServerErrorException(`Thiếu biến môi trường: ${key}`);
    }
    return value;
  }

  uploadImage(file: Express.Multer.File): Promise<UploadApiResponse> {
    if (!file.mimetype.startsWith('image/')) {
      throw new InternalServerErrorException('File upload phải là ảnh');
    }

    return new Promise((resolve, reject) => {
      const uploadStream = cloudinary.uploader.upload_stream(
        { folder: this.folder, resource_type: 'image' },
        (error, result) => {
          if (error || !result) {
            return reject(
              new InternalServerErrorException('Upload Cloudinary thất bại'),
            );
          }
          resolve(result);
        },
      );

      streamifier.createReadStream(file.buffer).pipe(uploadStream);
    });
  }
}

import { Module } from '@nestjs/common';
import { MailerModule } from '@nestjs-modules/mailer';
import { ConfigService } from '@nestjs/config';
import { ENV_VARS } from 'src/constants/env.constants';

@Module({
  imports: [
    MailerModule.forRootAsync({
      inject: [ConfigService],
      useFactory: (config: ConfigService) => {
        const host = config.get<string>(ENV_VARS.MAIL_HOST);
        const port = config.get<number>(ENV_VARS.MAIL_PORT);
        const user = config.get<string>(ENV_VARS.MAIL_USER);
        const pass = config.get<string>(ENV_VARS.MAIL_PASS);
        const from = config.get<string>(ENV_VARS.MAIL_FROM);

        if (!host || !port || !user || !pass || !from) {
          throw new Error('Thiếu biến môi trường cấu hình mail: MAIL_HOST, MAIL_PORT, MAIL_USER, MAIL_PASS, MAIL_FROM');
        }

        return {
          transport: {
            host,
            port,
            secure: port === 465,
            auth: {
              user,
              pass,
            },
          },
          defaults: {
            from,
          },
        };
      },
    }),
  ],
  exports: [MailerModule],
})
export class MailModule {}

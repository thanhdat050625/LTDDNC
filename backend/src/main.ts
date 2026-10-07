import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { ValidationPipe } from '@nestjs/common';
import { HttpExceptionFilter } from './core/common/filters/http-exception.filter';
import { LoggingInterceptor } from './core/common/interceptors/logging.interceptor';
import { NestExpressApplication } from '@nestjs/platform-express';
import { IoAdapter } from '@nestjs/platform-socket.io';
import cookieParser from 'cookie-parser';
import { spawn, execSync } from 'child_process';
import * as fs from 'fs';
import * as path from 'path';

function findNgrokExecutable(): string | null {
  const wingetPath = process.env.LOCALAPPDATA
    ? path.join(process.env.LOCALAPPDATA, 'Microsoft', 'WinGet', 'Links', 'ngrok.exe')
    : '';
  if (wingetPath && fs.existsSync(wingetPath)) {
    return wingetPath;
  }

  try {
    const checkCmd = process.platform === 'win32' ? 'where ngrok' : 'which ngrok';
    execSync(checkCmd, { stdio: 'ignore' });
    return 'ngrok';
  } catch {
    return null;
  }
}

async function startNgrokTunnel(port: string | number) {
  const ngrokUrl = process.env.NGROK_URL?.trim();
  if (!ngrokUrl) return;

  const exe = findNgrokExecutable();
  if (!exe) {
    console.warn(
      '[ngrok] NGROK_URL được cấu hình nhưng máy chưa cài ngrok. Vui lòng cài đặt (winget install Ngrok.Ngrok) để tự động bật tunnel.',
    );
    return;
  }

  try {
    const res = await fetch('http://127.0.0.1:4040/api/tunnels');
    if (res.ok) {
      console.log(`[ngrok] Tunnel is already running: ${ngrokUrl}`);
      return;
    }
  } catch {
    // ngrok is not running, proceed to spawn
  }

  try {
    const child = spawn(exe, ['http', String(port)], {
      detached: true,
      stdio: 'ignore',
    });
    child.unref();
    console.log(`[ngrok] Background tunnel started for port ${port} -> ${ngrokUrl}`);
  } catch (error: any) {
    console.warn(`[ngrok] Failed to start tunnel automatically: ${error?.message || error}`);
  }
}

async function bootstrap() {
  const app = await NestFactory.create<NestExpressApplication>(AppModule);

  app.use(cookieParser());

  app.set('trust proxy', 'loopback');

  const frontendUrl = process.env.FRONTEND_URL;
  if (!frontendUrl) {
    throw new Error('Thiếu biến môi trường: FRONTEND_URL');
  }

  app.enableCors({
    origin: true, // Allow all origins for Flutter Web random ports
    credentials: true,
  });

  // Sử dụng Socket.io adapter cho WebSocket Gateway
  app.useWebSocketAdapter(new IoAdapter(app));

  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      transform: true,
    }),
  );

  app.useGlobalFilters(new HttpExceptionFilter());
  app.useGlobalInterceptors(new LoggingInterceptor());

  const port = process.env.PORT;
  if (!port) {
    throw new Error('Thiếu biến môi trường: PORT');
  }
  await app.listen(port);
  await startNgrokTunnel(port);
}
bootstrap();

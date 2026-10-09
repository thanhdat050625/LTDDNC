import {
  Controller, Get, Post, Body, Param, ParseIntPipe,
  UseGuards, HttpCode, HttpStatus, Request, Req, Res, Query,
  InternalServerErrorException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { PaymentService } from './payment.service';
import { CreatePaymentUrlDto } from './dto/create-payment-url.dto';
import { JwtAuthGuard } from '../../core/security/jwt/jwt-auth.guard';
import { ENV_VARS } from 'src/constants/env.constants';

@Controller('payments')
export class PaymentController {
  constructor(
    private readonly paymentService: PaymentService,
    private readonly configService: ConfigService,
  ) {}

  private getFrontendUrl(): string {
    const frontendUrl = this.configService.get<string>(ENV_VARS.FRONTEND_URL);
    if (!frontendUrl) {
      throw new InternalServerErrorException(`Thiếu biến môi trường: ${ENV_VARS.FRONTEND_URL}`);
    }
    return frontendUrl.split(',')[0].trim();
  }

  // Lấy tóm tắt đơn hàng để hiển thị trên trang checkout
  @Get('prepare/:bookingId')
  @UseGuards(JwtAuthGuard)
  @HttpCode(HttpStatus.OK)
  async prepareCheckout(
    @Request() req,
    @Param('bookingId', ParseIntPipe) bookingId: number,
  ) {
    return this.paymentService.prepareCheckout(req.user.id, bookingId);
  }

  // Chuẩn bị thanh toán nháp (khi chưa tạo đơn hàng)
  @Post('prepare-draft')
  @UseGuards(JwtAuthGuard)
  @HttpCode(HttpStatus.OK)
  async prepareCheckoutDraft(@Request() req, @Body() dto: any) {
    return this.paymentService.prepareCheckoutDraft(req.user.id, dto);
  }

  // Tạo payUrl, trả về để frontend redirect
  @Post('checkout')
  @UseGuards(JwtAuthGuard)
  @HttpCode(HttpStatus.OK)
  async createPaymentUrl(@Request() req, @Req() rawReq: any, @Body() dto: CreatePaymentUrlDto) {
    const ipAddr = rawReq.headers['x-forwarded-for'] || rawReq.socket?.remoteAddress || rawReq.ip || '127.0.0.1';
    return this.paymentService.createPaymentUrl(req.user.id, dto, ipAddr);
  }

  // Frontend gọi để lấy trạng thái thanh toán sau khi quay về từ gateway
  @Get('status/:bookingId')
  @UseGuards(JwtAuthGuard)
  @HttpCode(HttpStatus.OK)
  async getPaymentStatus(
    @Request() req,
    @Param('bookingId', ParseIntPipe) bookingId: number,
  ) {
    return this.paymentService.getPaymentStatus(req.user.id, bookingId);
  }

  // Endpoint không cần JWT – dùng bookingCode từ returnUrl gateway
  @Get('status-by-code/:bookingCode')
  @HttpCode(HttpStatus.OK)
  async getPaymentStatusByCode(@Param('bookingCode') bookingCode: string) {
    return this.paymentService.getPaymentStatusByBookingCode(bookingCode);
  }


  // ─── IPN / Webhook endpoints (không cần JWT, cần verify signature) ───

  @Post('momo/ipn')
  @HttpCode(HttpStatus.NO_CONTENT)
  async handleMoMoIPN(@Body() ipnData: Record<string, any>) {
    await this.paymentService.processMoMoIPN(ipnData);
  }

  @Get('vnpay/ipn')
  async handleVnpayIPN(@Query() query: Record<string, any>) {
    return this.paymentService.processVnpayIPN(query);
  }

  private async renderReturnHtml(bookingCode: string, res: any) {
    let source = 'ONLINE';
    let bookingId: number | string = '';
    try {
      const statusRes = await this.paymentService.getPaymentStatusByBookingCode(bookingCode);
      if (statusRes?.data) {
        source = statusRes.data.source || 'ONLINE';
        bookingId = statusRes.data.bookingId || '';
      }
    } catch {
      // fallback default
    }

    const isStaff = source === 'OFFLINE';
    const targetBookingParam = bookingId || bookingCode;
    const appScheme = isStaff
      ? `cineplexstaff://pos?bookingCode=${bookingCode}&bookingId=${bookingId}`
      : `cineplex://payment-result/${targetBookingParam}?bookingCode=${bookingCode}`;
    const appName = isStaff ? 'Cineplex Staff' : 'Cineplex';
    const frontendUrl = this.getFrontendUrl();

    return res.send(`
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Thanh toán thành công</title>
        <style>
          body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; display: flex; flex-direction: column; align-items: center; justify-content: center; min-height: 100vh; margin: 0; background-color: #0f172a; color: #f8fafc; text-align: center; padding: 24px; box-sizing: border-box; }
          .card { background: #1e293b; padding: 32px 24px; border-radius: 16px; box-shadow: 0 10px 25px rgba(0,0,0,0.3); max-width: 400px; width: 100%; border: 1px solid #334155; }
          .icon { width: 64px; height: 64px; border-radius: 50%; background: rgba(34,197,94,0.15); color: #22c55e; display: flex; align-items: center; justify-content: center; font-size: 32px; margin: 0 auto 16px; font-weight: bold; }
          h2 { margin: 0 0 8px; font-size: 20px; color: #fff; }
          p { margin: 4px 0; color: #94a3b8; font-size: 14px; }
          .code { font-family: monospace; font-weight: bold; color: #38bdf8; font-size: 16px; }
          .btn { display: inline-block; margin-top: 20px; padding: 14px 24px; background: #e11d48; color: #fff; border-radius: 10px; text-decoration: none; font-weight: 600; font-size: 15px; width: 100%; box-sizing: border-box; }
          .btn-secondary { background: transparent; border: 1px solid #475569; color: #94a3b8; margin-top: 10px; }
          .hint { margin-top: 16px; font-size: 12px; color: #64748b; }
        </style>
      </head>
      <body>
        <div class="card">
          <div class="icon">✓</div>
          <h2>Thanh toán thành công!</h2>
          <p>Mã đơn hàng: <span class="code">${bookingCode || ''}</span></p>
          <p>Giao dịch đang được hệ thống xử lý qua IPN.</p>
          <a href="${appScheme}" class="btn" id="openAppBtn">Mở lại ứng dụng ${appName}</a>
          <a href="${frontendUrl}/booking/payment-result?bookingCode=${bookingCode}" class="btn btn-secondary">Xem kết quả trên Web</a>
          <p class="hint">Đang tự động mở lại ứng dụng...</p>
        </div>
        <script>
          // Tự động kích hoạt mở App sau 500ms
          setTimeout(function() {
            window.location.href = "${appScheme}";
          }, 500);
        </script>
      </body>
      </html>
    `);
  }

  // VNPay returnUrl – điều hướng quay về App (Client hoặc Staff)
  @Get('vnpay/return')
  async handleVnpayReturn(@Query('vnp_TxnRef') bookingCode: string, @Res() res: any) {
    return this.renderReturnHtml(bookingCode, res);
  }

  // MoMo returnUrl – điều hướng quay về App (Client hoặc Staff)
  @Get('momo/return')
  async handleMoMoReturn(@Query('orderId') bookingCode: string, @Res() res: any) {
    return this.renderReturnHtml(bookingCode, res);
  }

  // PayPal: user approve → BE capture → redirect về FE
  @Get('paypal/capture')
  async handlePayPalCapture(@Query('bookingCode') bookingCode: string, @Res() res: any) {
    await this.paymentService.capturePayPalOrder(bookingCode);
    const frontendUrl = this.getFrontendUrl();
    return res.redirect(`${frontendUrl}/booking/payment-result?bookingCode=${bookingCode}`);
  }

  @Get('paypal/cancel')
  async handlePayPalCancel(@Query('bookingCode') bookingCode: string, @Res() res: any) {
    await this.paymentService.cancelPayPalOrder(bookingCode);
    const frontendUrl = this.getFrontendUrl();
    return res.redirect(`${frontendUrl}/booking/payment-result?bookingCode=${bookingCode}`);
  }
}

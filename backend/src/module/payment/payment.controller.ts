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

  // VNPay / MoMo returnUrl – chỉ redirect về FE với bookingCode, KHÔNG xử lý thanh toán
  @Get('vnpay/return')
  async handleVnpayReturn(@Query('vnp_TxnRef') bookingCode: string, @Res() res: any) {
    const frontendUrl = this.getFrontendUrl();
    return res.redirect(`${frontendUrl}/booking/payment-result?bookingCode=${bookingCode}`);
  }

  @Get('momo/return')
  async handleMoMoReturn(@Query('orderId') bookingCode: string, @Res() res: any) {
    const frontendUrl = this.getFrontendUrl();
    return res.redirect(`${frontendUrl}/booking/payment-result?bookingCode=${bookingCode}`);
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

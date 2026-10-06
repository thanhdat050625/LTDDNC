export enum EPaymentStatus {
  PENDING = 'PENDING',
  PENDING_PAYMENT = 'PENDING_PAYMENT',
  SUCCESS = 'SUCCESS',
  FAILED = 'FAILED',
  REFUND_PENDING = 'REFUND_PENDING',
}

export enum EPaymentMethod {
  CASH = 'CASH',
  MOMO = 'MOMO',
  VNPAY = 'VNPAY',
  PAYPAL = 'PAYPAL',
}

export enum EPaymentChannel {
  ONLINE = 'ONLINE',
  COUNTER = 'COUNTER',
}

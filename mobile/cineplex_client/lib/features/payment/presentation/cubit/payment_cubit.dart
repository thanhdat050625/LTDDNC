import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/payment_model.dart';
import '../../data/repositories/payment_repository.dart';

abstract class PaymentState extends Equatable {
  const PaymentState();
  @override
  List<Object?> get props => [];
}

class PaymentInitial extends PaymentState {}

class PaymentLoading extends PaymentState {}

class CheckoutPrepared extends PaymentState {
  final CheckoutPrepareModel data;
  const CheckoutPrepared(this.data);
  @override
  List<Object?> get props => [data];
}

class PaymentUrlReady extends PaymentState {
  final String payUrl;
  const PaymentUrlReady(this.payUrl);
  @override
  List<Object?> get props => [payUrl];
}

class PaymentSuccess extends PaymentState {
  final PaymentStatusModel status;
  const PaymentSuccess(this.status);
  @override
  List<Object?> get props => [status];
}

class PaymentFailed extends PaymentState {
  final String message;
  const PaymentFailed(this.message);
  @override
  List<Object?> get props => [message];
}

class PaymentPolling extends PaymentState {}

class PaymentCubit extends Cubit<PaymentState> {
  final PaymentRepository repository;

  PaymentCubit(this.repository) : super(PaymentInitial());

  Future<void> prepareCheckout(String bookingId) async {
    emit(PaymentLoading());
    try {
      final data = await repository.prepareCheckout(bookingId);
      emit(CheckoutPrepared(data));
    } catch (e) {
      emit(PaymentFailed(e.toString()));
    }
  }

  Future<void> checkout(String bookingId, String method) async {
    emit(PaymentLoading());
    try {
      final data = await repository.checkout(bookingId, method);
      if (data.paymentRequired && data.payUrl.isNotEmpty) {
        emit(PaymentUrlReady(data.payUrl));
      } else {
        checkStatus(bookingId);
      }
    } catch (e) {
      emit(PaymentFailed(e.toString()));
    }
  }

  Future<void> checkStatus(String bookingId) async {
    emit(PaymentPolling());
    try {
      final status = await repository.getPaymentStatus(bookingId);
      if (status.status == 'SUCCESS' || status.status == 'PAID') {
        emit(PaymentSuccess(status));
      } else if (status.status == 'FAILED') {
        emit(const PaymentFailed('Thanh toán thất bại'));
      } else {
        emit(PaymentFailed('Trạng thái thanh toán: ${status.status}'));
      }
    } catch (e) {
      emit(PaymentFailed(e.toString()));
    }
  }
}

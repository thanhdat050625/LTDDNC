import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile_shared/mobile_shared.dart';

import '../../data/repositories/staff_repository.dart';

abstract class StaffState extends Equatable {
  const StaffState();
  @override
  List<Object?> get props => [];
}

class StaffInitial extends StaffState {}

class StaffScanning extends StaffState {}

class StaffCheckinSuccess extends StaffState {
  final TicketModel ticket;
  const StaffCheckinSuccess(this.ticket);
  @override
  List<Object?> get props => [ticket];
}

class StaffCheckinError extends StaffState {
  final String message;
  final String? code;
  final bool isWarning;

  const StaffCheckinError(this.message, {this.code, this.isWarning = false});
  @override
  List<Object?> get props => [message, code, isWarning];
}

class StaffCubit extends Cubit<StaffState> {
  final StaffRepository repository;
  bool isProcessing = false;

  StaffCubit(this.repository) : super(StaffInitial());

  Future<void> checkin(String qrCode) async {
    final cleanCode = qrCode.trim();
    if (cleanCode.isEmpty) return;
    if (isProcessing) return;

    isProcessing = true;
    emit(StaffScanning());

    try {
      final ticket = await repository.checkinTicket(cleanCode);
      emit(StaffCheckinSuccess(ticket));
    } catch (e) {
      if (e is ServerException) {
        final isWarning =
            e.code == 'BOOKING_CODE_SCANNED' ||
            e.code == 'TICKET_ALREADY_CHECKED_IN';
        emit(StaffCheckinError(e.message, code: e.code, isWarning: isWarning));
      } else {
        emit(StaffCheckinError(e.toString()));
      }
    }

    await Future.delayed(const Duration(seconds: 4));
    if (!isClosed) {
      emit(StaffInitial());
    }
    isProcessing = false;
  }

  void reset() {
    isProcessing = false;
    emit(StaffInitial());
  }
}

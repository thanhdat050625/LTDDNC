import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:cineplex_mobile/features/staff/data/repositories/staff_repository.dart';
import 'package:cineplex_mobile/features/ticket/data/models/ticket_model.dart';

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
  const StaffCheckinError(this.message);
  @override
  List<Object?> get props => [message];
}

class StaffCubit extends Cubit<StaffState> {
  final StaffRepository repository;
  bool isProcessing = false;

  StaffCubit(this.repository) : super(StaffInitial());

  Future<void> checkin(String qrCode) async {
    if (isProcessing) return;
    isProcessing = true;
    emit(StaffScanning());
    try {
      final ticket = await repository.checkinTicket(qrCode);
      emit(StaffCheckinSuccess(ticket));
    } catch (e) {
      emit(StaffCheckinError(e.toString()));
    }
    await Future.delayed(const Duration(seconds: 3));
    emit(StaffInitial());
    isProcessing = false;
  }
}

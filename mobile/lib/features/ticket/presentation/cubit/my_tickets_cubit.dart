import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:cineplex_mobile/features/ticket/data/models/ticket_model.dart';
import 'package:cineplex_mobile/features/ticket/data/repositories/ticket_repository.dart';

abstract class MyTicketsState extends Equatable {
  const MyTicketsState();
  @override
  List<Object?> get props => [];
}

class MyTicketsInitial extends MyTicketsState {}
class MyTicketsLoading extends MyTicketsState {}
class MyTicketsLoaded extends MyTicketsState {
  final List<BookingDetailModel> upcoming;
  final List<BookingDetailModel> past;

  const MyTicketsLoaded(this.upcoming, this.past);

  @override
  List<Object?> get props => [upcoming, past];
}
class MyTicketsError extends MyTicketsState {
  final String message;
  const MyTicketsError(this.message);
  @override
  List<Object?> get props => [message];
}

class MyTicketsCubit extends Cubit<MyTicketsState> {
  final TicketRepository repository;

  MyTicketsCubit(this.repository) : super(MyTicketsInitial());

  Future<void> loadMyTickets() async {
    emit(MyTicketsLoading());
    try {
      final bookings = await repository.getMyBookings();
      // Simple logic: assume if status is PAID/ACTIVE it's upcoming, else past
      final upcoming = bookings.where((b) => b.status == 'PAID').toList();
      final past = bookings.where((b) => b.status != 'PAID').toList();
      emit(MyTicketsLoaded(upcoming, past));
    } catch (e) {
      emit(MyTicketsError(e.toString()));
    }
  }
}

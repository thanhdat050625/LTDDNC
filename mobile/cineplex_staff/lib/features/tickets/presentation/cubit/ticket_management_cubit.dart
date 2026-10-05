import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_shared/mobile_shared.dart'
    hide
        TicketManagementState,
        TicketManagementInitial,
        TicketManagementLoading,
        TicketManagementLoaded,
        TicketManagementError;

import 'ticket_management_state.dart';

class TicketManagementCubit extends Cubit<TicketManagementState> {
  final BookingManagementRepository _repository;

  TicketManagementCubit(this._repository)
    : super(const TicketManagementInitial());

  Future<void> loadAll() async {
    emit(const TicketManagementLoading());
    try {
      final results = await Future.wait([
        _repository.getAllBookings(page: 1, pageSize: 50),
        _repository.getTicketPrices(),
      ]);

      final bookings = results[0] as List<BookingDetailModel>;
      final prices = results[1] as List<TicketPriceModel>;

      emit(TicketManagementLoaded(allBookings: bookings, ticketPrices: prices));
    } catch (e) {
      emit(TicketManagementError(e.toString()));
    }
  }

  void search(String query) {
    if (state is TicketManagementLoaded) {
      final loaded = state as TicketManagementLoaded;
      emit(loaded.copyWith(searchQuery: query));
    }
  }

  void setStatusFilter(String status) {
    if (state is TicketManagementLoaded) {
      final loaded = state as TicketManagementLoaded;
      emit(loaded.copyWith(statusFilter: status));
    }
  }

  void setTab(int index) {
    if (state is TicketManagementLoaded) {
      final loaded = state as TicketManagementLoaded;
      emit(loaded.copyWith(currentTabIndex: index));
    }
  }

  Future<bool> updatePrice(int id, num newPrice) async {
    if (state is! TicketManagementLoaded) return false;
    final loaded = state as TicketManagementLoaded;

    emit(loaded.copyWith(isSubmitting: true));
    try {
      await _repository.updateTicketPrice(id, newPrice);
      final updatedPrices = await _repository.getTicketPrices();
      emit(loaded.copyWith(ticketPrices: updatedPrices, isSubmitting: false));
      return true;
    } catch (_) {
      emit(loaded.copyWith(isSubmitting: false));
      return false;
    }
  }
}

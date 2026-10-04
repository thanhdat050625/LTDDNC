import 'package:equatable/equatable.dart';
import 'package:mobile_shared/mobile_shared.dart';

abstract class TicketManagementState extends Equatable {
  const TicketManagementState();

  @override
  List<Object?> get props => [];
}

class TicketManagementInitial extends TicketManagementState {
  const TicketManagementInitial();
}

class TicketManagementLoading extends TicketManagementState {
  const TicketManagementLoading();
}

class TicketManagementLoaded extends TicketManagementState {
  final List<BookingDetailModel> allBookings;
  final List<TicketPriceModel> ticketPrices;
  final String searchQuery;
  final String statusFilter;
  final int currentTabIndex;
  final bool isSubmitting;

  const TicketManagementLoaded({
    required this.allBookings,
    required this.ticketPrices,
    this.searchQuery = '',
    this.statusFilter = 'ALL',
    this.currentTabIndex = 0,
    this.isSubmitting = false,
  });

  List<BookingDetailModel> get filteredBookings {
    return allBookings.where((b) {
      // Filter by status
      if (statusFilter != 'ALL') {
        final bStatus = b.status.toUpperCase();
        if (statusFilter == 'CONFIRMED' &&
            bStatus != 'CONFIRMED' &&
            bStatus != 'PAID') {
          return false;
        } else if (statusFilter == 'PENDING' && bStatus != 'PENDING') {
          return false;
        } else if (statusFilter == 'CANCELLED' && bStatus != 'CANCELLED') {
          return false;
        }
      }

      // Filter by query
      if (searchQuery.isNotEmpty) {
        final q = searchQuery.toLowerCase().trim();
        final code = b.bookingCode.toLowerCase();
        final movie = (b.movieTitle ?? '').toLowerCase();
        final customer = (b.customerName ?? '').toLowerCase();
        final phone = (b.customerPhone ?? '').toLowerCase();
        return code.contains(q) ||
            movie.contains(q) ||
            customer.contains(q) ||
            phone.contains(q);
      }

      return true;
    }).toList();
  }

  TicketManagementLoaded copyWith({
    List<BookingDetailModel>? allBookings,
    List<TicketPriceModel>? ticketPrices,
    String? searchQuery,
    String? statusFilter,
    int? currentTabIndex,
    bool? isSubmitting,
  }) {
    return TicketManagementLoaded(
      allBookings: allBookings ?? this.allBookings,
      ticketPrices: ticketPrices ?? this.ticketPrices,
      searchQuery: searchQuery ?? this.searchQuery,
      statusFilter: statusFilter ?? this.statusFilter,
      currentTabIndex: currentTabIndex ?? this.currentTabIndex,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }

  @override
  List<Object?> get props => [
    allBookings,
    ticketPrices,
    searchQuery,
    statusFilter,
    currentTabIndex,
    isSubmitting,
  ];
}

class TicketManagementError extends TicketManagementState {
  final String message;

  const TicketManagementError(this.message);

  @override
  List<Object?> get props => [message];
}

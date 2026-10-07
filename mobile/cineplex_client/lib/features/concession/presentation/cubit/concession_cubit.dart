import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_shared/mobile_shared.dart';
import 'package:cineplex_client/features/concession/data/repositories/concession_repository.dart';
import 'package:cineplex_client/features/booking/data/repositories/booking_repository.dart';

abstract class ConcessionState extends Equatable {
  const ConcessionState();
  @override
  List<Object?> get props => [];
}

class ConcessionInitial extends ConcessionState {}
class ConcessionLoading extends ConcessionState {}

class ConcessionLoaded extends ConcessionState {
  final List<ConcessionProductModel> products;
  final Map<int, int> selectedItems;
  final double totalPrice;
  final bool isSubmitting;

  const ConcessionLoaded({
    required this.products,
    this.selectedItems = const {},
    this.totalPrice = 0.0,
    this.isSubmitting = false,
  });

  ConcessionLoaded copyWith({
    List<ConcessionProductModel>? products,
    Map<int, int>? selectedItems,
    double? totalPrice,
    bool? isSubmitting,
  }) {
    return ConcessionLoaded(
      products: products ?? this.products,
      selectedItems: selectedItems ?? this.selectedItems,
      totalPrice: totalPrice ?? this.totalPrice,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }

  @override
  List<Object?> get props => [products, selectedItems, totalPrice, isSubmitting];
}

class ConcessionSubmitSuccess extends ConcessionState {
  final int bookingId;
  const ConcessionSubmitSuccess(this.bookingId);
  @override
  List<Object?> get props => [bookingId];
}

class ConcessionError extends ConcessionState {
  final String message;
  const ConcessionError(this.message);
  @override
  List<Object?> get props => [message];
}

class ConcessionCubit extends Cubit<ConcessionState> {
  final ConcessionRepository _repository;
  final BookingRepository? _bookingRepository;

  ConcessionCubit(this._repository, [this._bookingRepository]) : super(ConcessionInitial());

  Future<void> loadConcessions() async {
    emit(ConcessionLoading());
    try {
      final products = await _repository.getConcessions();
      emit(ConcessionLoaded(products: products));
    } catch (e) {
      emit(ConcessionError(e.toString()));
    }
  }

  void updateQuantity(int productId, int quantity) {
    if (state is ConcessionLoaded) {
      final currentState = state as ConcessionLoaded;
      final safeQuantity = quantity < 0 ? 0 : quantity;
      final newSelectedItems = Map<int, int>.from(currentState.selectedItems);
      
      if (safeQuantity <= 0) {
        newSelectedItems.remove(productId);
      } else {
        newSelectedItems[productId] = safeQuantity;
      }
      
      double total = 0;
      for (final item in newSelectedItems.entries) {
        final product = currentState.products.firstWhere(
          (p) => p.id == item.key,
          orElse: () => const ConcessionProductModel(id: 0, name: '', price: 0, stockQuantity: 0),
        );
        total += product.price * item.value;
      }
      
      emit(currentState.copyWith(
        selectedItems: newSelectedItems,
        totalPrice: total,
      ));
    }
  }

  Future<bool> submitConcessions([
    int bookingId = 0,
    int showtimeId = 0,
    List<int> seatIds = const [],
    bool skip = false,
  ]) async {
    if (state is ConcessionLoaded) {
      final currentState = state as ConcessionLoaded;
      emit(currentState.copyWith(isSubmitting: true));

      try {
        final items = skip
            ? <ConcessionItemDto>[]
            : currentState.selectedItems.entries
                .where((item) => item.value > 0)
                .map((item) => ConcessionItemDto(
                      concessionId: item.key,
                      quantity: item.value,
                    ))
                .toList();

        int targetBookingId = bookingId;

        // ponytail: Create booking only when user confirms payment/concessions step.
        if (targetBookingId <= 0 && showtimeId > 0 && seatIds.isNotEmpty && _bookingRepository != null) {
          final booking = await _bookingRepository.createBooking(CreateBookingDto(
            showtimeId: showtimeId,
            seatIds: seatIds,
            concessions: items,
          ));
          targetBookingId = booking.id;
        } else if (targetBookingId > 0 && _bookingRepository != null && !skip) {
          await _bookingRepository.updateBookingConcessions(
            targetBookingId,
            UpdateBookingConcessionsDto(concessions: items),
          );
        }

        emit(ConcessionSubmitSuccess(targetBookingId));
        return true;
      } catch (e) {
        emit(ConcessionError(e.toString()));
        emit(currentState.copyWith(isSubmitting: false));
        return false;
      }
    }
    return false;
  }
}

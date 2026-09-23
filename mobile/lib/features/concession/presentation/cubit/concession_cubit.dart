import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cineplex_mobile/features/concession/data/models/concession_model.dart';
import 'package:cineplex_mobile/features/concession/data/repositories/concession_repository.dart';

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

  const ConcessionLoaded({
    required this.products,
    this.selectedItems = const {},
    this.totalPrice = 0.0,
  });

  ConcessionLoaded copyWith({
    List<ConcessionProductModel>? products,
    Map<int, int>? selectedItems,
    double? totalPrice,
  }) {
    return ConcessionLoaded(
      products: products ?? this.products,
      selectedItems: selectedItems ?? this.selectedItems,
      totalPrice: totalPrice ?? this.totalPrice,
    );
  }

  @override
  List<Object?> get props => [products, selectedItems, totalPrice];
}

class ConcessionError extends ConcessionState {
  final String message;
  const ConcessionError(this.message);
  @override
  List<Object?> get props => [message];
}

class ConcessionCubit extends Cubit<ConcessionState> {
  final ConcessionRepository _repository;

  ConcessionCubit(this._repository) : super(ConcessionInitial());

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
      final newSelectedItems = Map<int, int>.from(currentState.selectedItems);
      
      if (quantity <= 0) {
        newSelectedItems.remove(productId);
      } else {
        newSelectedItems[productId] = quantity;
      }
      
      double total = 0;
      for (final item in newSelectedItems.entries) {
        final product = currentState.products.firstWhere((p) => p.id == item.key);
        total += product.price * item.value;
      }
      
      emit(currentState.copyWith(
        selectedItems: newSelectedItems,
        totalPrice: total,
      ));
    }
  }
}

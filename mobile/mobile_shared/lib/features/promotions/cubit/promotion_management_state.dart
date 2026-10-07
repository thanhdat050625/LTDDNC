import 'package:equatable/equatable.dart';
import 'package:mobile_shared/mobile_shared.dart';

abstract class PromotionManagementState extends Equatable {
  const PromotionManagementState();
  @override
  List<Object?> get props => [];
}

class PromotionManagementInitial extends PromotionManagementState {}
class PromotionManagementLoading extends PromotionManagementState {}
class PromotionManagementLoaded extends PromotionManagementState {
  final List<PromotionModel> allPromotions;
  final List<PromotionModel> promotions;
  final String? selectedFilter;
  final String searchQuery;

  const PromotionManagementLoaded({
    required this.allPromotions,
    required this.promotions,
    this.selectedFilter,
    this.searchQuery = '',
  });

  @override
  List<Object?> get props => [allPromotions, promotions, selectedFilter, searchQuery];
}
class PromotionManagementError extends PromotionManagementState {
  final String message;
  const PromotionManagementError(this.message);
  @override
  List<Object?> get props => [message];
}

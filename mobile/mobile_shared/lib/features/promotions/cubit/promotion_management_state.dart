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
  final List<PromotionModel> promotions;
  const PromotionManagementLoaded(this.promotions);
  @override
  List<Object?> get props => [promotions];
}
class PromotionManagementError extends PromotionManagementState {
  final String message;
  const PromotionManagementError(this.message);
  @override
  List<Object?> get props => [message];
}

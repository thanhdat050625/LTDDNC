import 'package:equatable/equatable.dart';
import 'package:mobile_shared/mobile_shared.dart';

abstract class ConcessionManagementState extends Equatable {
  const ConcessionManagementState();
  @override
  List<Object?> get props => [];
}

class ConcessionManagementInitial extends ConcessionManagementState {}

class ConcessionManagementLoading extends ConcessionManagementState {}

class ConcessionManagementLoaded extends ConcessionManagementState {
  final List<ConcessionProductModel> concessions;
  final Map<String, int> summary;
  const ConcessionManagementLoaded(this.concessions, this.summary);
  @override
  List<Object?> get props => [concessions, summary];
}

class ConcessionManagementError extends ConcessionManagementState {
  final String message;
  const ConcessionManagementError(this.message);
  @override
  List<Object?> get props => [message];
}

import 'package:equatable/equatable.dart';

abstract class ConcessionFormState extends Equatable {
  const ConcessionFormState();
  @override
  List<Object?> get props => [];
}

class ConcessionFormInitial extends ConcessionFormState {}

class ConcessionFormSubmitting extends ConcessionFormState {}

class ConcessionFormSuccess extends ConcessionFormState {}

class ConcessionFormError extends ConcessionFormState {
  final String message;
  const ConcessionFormError(this.message);
  @override
  List<Object?> get props => [message];
}

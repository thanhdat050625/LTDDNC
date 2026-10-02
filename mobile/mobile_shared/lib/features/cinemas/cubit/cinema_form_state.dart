import 'package:equatable/equatable.dart';
import 'package:mobile_shared/mobile_shared.dart';

abstract class CinemaFormState extends Equatable {
  const CinemaFormState();
  @override
  List<Object?> get props => [];
}

class CinemaFormInitial extends CinemaFormState {}
class CinemaFormSubmitting extends CinemaFormState {}
class CinemaFormSuccess extends CinemaFormState {}
class CinemaFormError extends CinemaFormState {
  final String message;
  const CinemaFormError(this.message);
  @override
  List<Object?> get props => [message];
}

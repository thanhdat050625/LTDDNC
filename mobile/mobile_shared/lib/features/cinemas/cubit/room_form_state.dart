import 'package:equatable/equatable.dart';

abstract class RoomFormState extends Equatable {
  const RoomFormState();
  @override
  List<Object?> get props => [];
}

class RoomFormInitial extends RoomFormState {}
class RoomFormSubmitting extends RoomFormState {}
class RoomFormSuccess extends RoomFormState {}
class RoomFormError extends RoomFormState {
  final String message;
  const RoomFormError(this.message);
  @override
  List<Object?> get props => [message];
}

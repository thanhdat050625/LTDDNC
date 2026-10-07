import 'package:equatable/equatable.dart';
import 'package:mobile_shared/mobile_shared.dart';

abstract class MovieManagementState extends Equatable {
  const MovieManagementState();

  @override
  List<Object?> get props => [];
}

class MovieManagementInitial extends MovieManagementState {}

class MovieManagementLoading extends MovieManagementState {}

class MovieManagementLoaded extends MovieManagementState {
  final List<MovieModel> movies;
  final List<MovieModel> allMovies;
  final String? selectedStatus;
  final bool isSearching;

  const MovieManagementLoaded({
    required this.movies,
    this.allMovies = const [],
    this.selectedStatus,
    this.isSearching = false,
  });

  @override
  List<Object?> get props => [movies, allMovies, selectedStatus, isSearching];
}

class MovieManagementError extends MovieManagementState {
  final String message;

  const MovieManagementError(this.message);

  @override
  List<Object?> get props => [message];
}

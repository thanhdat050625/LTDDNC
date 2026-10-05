import 'package:equatable/equatable.dart';
import 'package:mobile_shared/mobile_shared.dart';

abstract class ShowtimeBulkCreateState extends Equatable {
  const ShowtimeBulkCreateState();

  @override
  List<Object?> get props => [];
}

class ShowtimeBulkCreateInitial extends ShowtimeBulkCreateState {}

class ShowtimeBulkCreateLoadingDeps extends ShowtimeBulkCreateState {}

class ShowtimeBulkCreateDepsLoaded extends ShowtimeBulkCreateState {
  final List<MovieModel> movies;
  final List<CinemaModel> cinemas;
  final List<RoomModel> rooms;
  final int? selectedCinemaId;
  final bool isLoadingRooms;

  const ShowtimeBulkCreateDepsLoaded({
    required this.movies,
    required this.cinemas,
    required this.rooms,
    this.selectedCinemaId,
    this.isLoadingRooms = false,
  });

  ShowtimeBulkCreateDepsLoaded copyWith({
    List<MovieModel>? movies,
    List<CinemaModel>? cinemas,
    List<RoomModel>? rooms,
    int? selectedCinemaId,
    bool? isLoadingRooms,
  }) {
    return ShowtimeBulkCreateDepsLoaded(
      movies: movies ?? this.movies,
      cinemas: cinemas ?? this.cinemas,
      rooms: rooms ?? this.rooms,
      selectedCinemaId: selectedCinemaId ?? this.selectedCinemaId,
      isLoadingRooms: isLoadingRooms ?? this.isLoadingRooms,
    );
  }

  @override
  List<Object?> get props => [
        movies,
        cinemas,
        rooms,
        selectedCinemaId,
        isLoadingRooms,
      ];
}

class ShowtimeBulkCreateSubmitting extends ShowtimeBulkCreateState {}

class ShowtimeBulkCreateSuccess extends ShowtimeBulkCreateState {
  final Map<String, dynamic> result;

  const ShowtimeBulkCreateSuccess(this.result);

  int get successCount => (result['successCount'] as num?)?.toInt() ?? 0;
  int get failedCount => (result['failedCount'] as num?)?.toInt() ?? 0;
  List<dynamic> get failedSlots =>
      (result['failedSlots'] as List<dynamic>?) ?? [];
  List<dynamic> get createdShowtimes =>
      (result['createdShowtimes'] as List<dynamic>?) ?? [];

  @override
  List<Object?> get props => [result];
}

class ShowtimeBulkCreateError extends ShowtimeBulkCreateState {
  final String message;

  const ShowtimeBulkCreateError(this.message);

  @override
  List<Object?> get props => [message];
}

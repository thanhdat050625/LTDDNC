import 'package:equatable/equatable.dart';
import 'package:cineplex_mobile/features/movie/data/models/movie_model.dart';
import 'cinema_model.dart';

class ShowtimeModel extends Equatable {
  final int id;
  final int movieId;
  final int roomId;
  final DateTime publicStartTime;
  final String format;
  final String status;
  final MovieModel? movie;
  final RoomModel? room;
  final double? pricePerSeat;

  const ShowtimeModel({
    required this.id,
    required this.movieId,
    required this.roomId,
    required this.publicStartTime,
    required this.format,
    required this.status,
    this.movie,
    this.room,
    this.pricePerSeat,
  });

  factory ShowtimeModel.fromJson(Map<String, dynamic> json) {
    return ShowtimeModel(
      id: json['id'] as int,
      movieId: json['movieId'] as int,
      roomId: json['roomId'] as int,
      publicStartTime: DateTime.parse(json['publicStartTime'] as String).toLocal(),
      format: json['format'] as String? ?? 'FORMAT_2D',
      status: json['status'] as String? ?? 'SCHEDULED',
      movie: json['movie'] != null ? MovieModel.fromJson(json['movie'] as Map<String, dynamic>) : null,
      room: json['room'] != null ? RoomModel.fromJson(json['room'] as Map<String, dynamic>) : null,
      pricePerSeat: (json['pricePerSeat'] as num?)?.toDouble(),
    );
  }

  @override
  List<Object?> get props => [id, movieId, roomId, publicStartTime, format, status, movie, room, pricePerSeat];
}

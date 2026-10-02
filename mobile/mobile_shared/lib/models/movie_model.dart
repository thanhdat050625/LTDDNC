import 'package:equatable/equatable.dart';

class MovieModel extends Equatable {
  final int id;
  final String title;
  final String genre;
  final int durationMinutes;
  final String? director;
  final String? cast;
  final DateTime? releaseDate;
  final DateTime? screeningEndDate;
  final String? description;
  final String? language;
  final int? ageLimit;
  final String? posterUrl;
  final String? trailerUrl;
  final String status;

  const MovieModel({
    required this.id,
    required this.title,
    required this.genre,
    required this.durationMinutes,
    this.director,
    this.cast,
    this.releaseDate,
    this.screeningEndDate,
    this.description,
    this.language,
    this.ageLimit,
    this.posterUrl,
    this.trailerUrl,
    required this.status,
  });

  factory MovieModel.fromJson(Map<String, dynamic> json) {
    return MovieModel(
      id: json['id'] as int? ?? 0,
      title: (json['title'] ?? json['name']) as String? ?? '',
      genre: json['genre'] as String? ?? '',
      durationMinutes: json['durationMinutes'] as int? ?? 0,
      director: json['director'] as String?,
      cast: json['cast'] as String?,
      releaseDate: json['releaseDate'] != null ? DateTime.tryParse(json['releaseDate']) : null,
      screeningEndDate: json['screeningEndDate'] != null ? DateTime.tryParse(json['screeningEndDate']) : null,
      description: json['description'] as String?,
      language: json['language'] as String?,
      ageLimit: json['ageLimit'] as int?,
      posterUrl: json['posterUrl'] as String?,
      trailerUrl: json['trailerUrl'] as String?,
      status: json['status'] as String? ?? 'COMING_SOON',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'genre': genre,
      'durationMinutes': durationMinutes,
      'director': director,
      'cast': cast,
      'releaseDate': releaseDate?.toIso8601String(),
      'screeningEndDate': screeningEndDate?.toIso8601String(),
      'description': description,
      'language': language,
      'ageLimit': ageLimit,
      'posterUrl': posterUrl,
      'trailerUrl': trailerUrl,
      'status': status,
    };
  }

  MovieModel copyWith({
    int? id,
    String? title,
    String? genre,
    int? durationMinutes,
    String? director,
    String? cast,
    DateTime? releaseDate,
    DateTime? screeningEndDate,
    String? description,
    String? language,
    int? ageLimit,
    String? posterUrl,
    String? trailerUrl,
    String? status,
  }) {
    return MovieModel(
      id: id ?? this.id,
      title: title ?? this.title,
      genre: genre ?? this.genre,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      director: director ?? this.director,
      cast: cast ?? this.cast,
      releaseDate: releaseDate ?? this.releaseDate,
      screeningEndDate: screeningEndDate ?? this.screeningEndDate,
      description: description ?? this.description,
      language: language ?? this.language,
      ageLimit: ageLimit ?? this.ageLimit,
      posterUrl: posterUrl ?? this.posterUrl,
      trailerUrl: trailerUrl ?? this.trailerUrl,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [
        id, title, genre, durationMinutes, director, cast, releaseDate,
        screeningEndDate, description, language, ageLimit, posterUrl,
        trailerUrl, status,
      ];
}

import 'package:equatable/equatable.dart';

class SummaryModel extends Equatable {
  final num revenue;
  final int tickets;
  final int cinemas;
  final int activeMovies;

  const SummaryModel({
    required this.revenue,
    required this.tickets,
    required this.cinemas,
    required this.activeMovies,
  });

  factory SummaryModel.fromJson(Map<String, dynamic> json) {
    return SummaryModel(
      revenue: json['revenue'] ?? 0,
      tickets: json['tickets'] ?? 0,
      cinemas: json['cinemas'] ?? 0,
      activeMovies: json['activeMovies'] ?? 0,
    );
  }

  @override
  List<Object?> get props => [revenue, tickets, cinemas, activeMovies];
}

class RevenuePeriodModel extends Equatable {
  final String period;
  final num revenue;

  const RevenuePeriodModel({
    required this.period,
    required this.revenue,
  });

  factory RevenuePeriodModel.fromJson(Map<String, dynamic> json) {
    return RevenuePeriodModel(
      period: json['period']?.toString() ?? '',
      revenue: json['revenue'] ?? 0,
    );
  }

  @override
  List<Object?> get props => [period, revenue];
}

class MoviePerformanceModel extends Equatable {
  final int id;
  final String title;
  final String? poster;
  final int ticketsSold;
  final num revenue;
  final int occupancyRate;

  const MoviePerformanceModel({
    required this.id,
    required this.title,
    this.poster,
    required this.ticketsSold,
    required this.revenue,
    required this.occupancyRate,
  });

  factory MoviePerformanceModel.fromJson(Map<String, dynamic> json) {
    return MoviePerformanceModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      title: json['title']?.toString() ?? '',
      poster: json['poster']?.toString(),
      ticketsSold: json['ticketsSold'] ?? 0,
      revenue: json['revenue'] ?? 0,
      occupancyRate: json['occupancyRate'] ?? 0,
    );
  }

  @override
  List<Object?> get props => [id, title, poster, ticketsSold, revenue, occupancyRate];
}

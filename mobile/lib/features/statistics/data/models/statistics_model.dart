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

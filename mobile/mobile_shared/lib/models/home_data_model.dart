import 'package:equatable/equatable.dart';
import 'movie_model.dart';
import 'promotion_model.dart';

class HomeDataModel extends Equatable {
  final List<MovieModel> nowShowing;
  final List<MovieModel> comingSoon;
  final List<PromotionModel> activePromotions;

  const HomeDataModel({required this.nowShowing, required this.comingSoon, required this.activePromotions});

  factory HomeDataModel.fromJson(Map<String, dynamic> json) {
    return HomeDataModel(
      nowShowing: (json['nowShowing'] as List).map((e) => MovieModel.fromJson(e)).toList(),
      comingSoon: (json['comingSoon'] as List).map((e) => MovieModel.fromJson(e)).toList(),
      activePromotions: (json['activePromotions'] as List).map((e) => PromotionModel.fromJson(e)).toList(),
    );
  }

  @override
  List<Object?> get props => [nowShowing, comingSoon, activePromotions];
}

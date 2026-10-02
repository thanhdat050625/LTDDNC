import 'package:equatable/equatable.dart';

class PromotionModel extends Equatable {
  final int id;
  final String code;
  final String? description;
  final String discountType;
  final num discountValue;
  final int? movieId;
  final DateTime startDate;
  final DateTime endDate;
  final int? maxUsage;
  final int usedCount;
  final bool isActive;

  const PromotionModel({
    required this.id,
    required this.code,
    this.description,
    required this.discountType,
    required this.discountValue,
    this.movieId,
    required this.startDate,
    required this.endDate,
    this.maxUsage,
    required this.usedCount,
    required this.isActive,
  });

  factory PromotionModel.fromJson(Map<String, dynamic> json) {
    return PromotionModel(
      id: json['id'] as int,
      code: json['code'] as String,
      description: json['description'] as String?,
      discountType: json['discountType'] as String,
      discountValue: json['discountValue'] as num,
      movieId: json['movieId'] as int?,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      maxUsage: json['maxUsage'] as int?,
      usedCount: json['usedCount'] as int? ?? 0,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'description': description,
      'discountType': discountType,
      'discountValue': discountValue,
      if (movieId != null) 'movieId': movieId,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      if (maxUsage != null) 'maxUsage': maxUsage,
      'isActive': isActive,
    };
  }

  @override
  List<Object?> get props => [
        id,
        code,
        description,
        discountType,
        discountValue,
        movieId,
        startDate,
        endDate,
        maxUsage,
        usedCount,
        isActive,
      ];
}

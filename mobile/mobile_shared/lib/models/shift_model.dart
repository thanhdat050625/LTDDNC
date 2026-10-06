import 'package:equatable/equatable.dart';

class ShiftModel extends Equatable {
  final int id;
  final String name;
  final String startTime;
  final String endTime;
  final String? description;
  final bool isActive;

  const ShiftModel({
    required this.id,
    required this.name,
    required this.startTime,
    required this.endTime,
    this.description,
    this.isActive = true,
  });

  factory ShiftModel.fromJson(Map<String, dynamic> json) {
    return ShiftModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      startTime: json['startTime'] as String? ?? '',
      endTime: json['endTime'] as String? ?? '',
      description: json['description'] as String?,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'startTime': startTime,
      'endTime': endTime,
      if (description != null) 'description': description,
      'isActive': isActive,
    };
  }

  @override
  List<Object?> get props => [id, name, startTime, endTime, description, isActive];
}

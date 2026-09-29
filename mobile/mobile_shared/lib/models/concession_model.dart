import 'package:equatable/equatable.dart';

class ConcessionProductModel extends Equatable {
  final int id;
  final String name;
  final double price;
  final int stockQuantity;

  const ConcessionProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.stockQuantity,
  });

  factory ConcessionProductModel.fromJson(Map<String, dynamic> json) {
    return ConcessionProductModel(
      id: json['id'] as int,
      name: json['name'] as String,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      stockQuantity: json['stockQuantity'] as int? ?? 0,
    );
  }

  @override
  List<Object?> get props => [id, name, price, stockQuantity];
}

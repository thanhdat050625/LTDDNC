import 'package:equatable/equatable.dart';

class ConcessionProductModel extends Equatable {
  final int id;
  final String name;
  final num price;
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
      price: json['price'] as num,
      stockQuantity: json['stockQuantity'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
      'stockQuantity': stockQuantity,
    };
  }

  @override
  List<Object?> get props => [id, name, price, stockQuantity];
}

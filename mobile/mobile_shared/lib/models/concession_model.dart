import 'package:equatable/equatable.dart';

class ConcessionProductModel extends Equatable {
  final int id;
  final String name;
  final num price;
  final int stockQuantity;
  final String? description;
  final String? imageUrl;

  const ConcessionProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.stockQuantity,
    this.description,
    this.imageUrl,
  });

  factory ConcessionProductModel.fromJson(Map<String, dynamic> json) {
    return ConcessionProductModel(
      id: json['id'] as int,
      name: json['name'] as String,
      price: json['price'] as num,
      stockQuantity: json['stockQuantity'] as int? ?? 0,
      description: json['description'] as String?,
      imageUrl: json['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
      'stockQuantity': stockQuantity,
      if (description != null) 'description': description,
      if (imageUrl != null) 'imageUrl': imageUrl,
    };
  }

  ConcessionProductModel copyWith({
    int? id,
    String? name,
    num? price,
    int? stockQuantity,
    String? description,
    String? imageUrl,
  }) {
    return ConcessionProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  @override
  List<Object?> get props => [id, name, price, stockQuantity, description, imageUrl];
}

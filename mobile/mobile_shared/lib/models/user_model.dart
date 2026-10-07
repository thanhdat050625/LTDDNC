import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final int id;
  final String fullName;
  final String email;
  final String role;
  final String? phone;
  final String status;
  final int loyaltyPoints;
  final String? gender;
  final String? avatar;
  final DateTime? dateOfBirth;
  final DateTime? createdAt;

  const UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    this.phone,
    required this.status,
    this.loyaltyPoints = 0,
    this.gender,
    this.avatar,
    this.dateOfBirth,
    this.createdAt,
  });

  bool get isBlocked => status.toUpperCase() == 'BLOCKED';
  bool get isActive => status.toUpperCase() == 'ACTIVE';
  bool get isStaff => role.toUpperCase() == 'STAFF';
  bool get isAdmin => role.toUpperCase() == 'ADMIN';
  bool get isCustomer => role.toUpperCase() == 'CUSTOMER';

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      fullName: json['fullName'] ?? json['name'] ?? '',
      email: json['email'] ?? '',
      role: (json['role'] ?? 'CUSTOMER').toString().toUpperCase(),
      phone: json['phone']?.toString(),
      status: (json['status'] ?? 'ACTIVE').toString().toUpperCase(),
      loyaltyPoints: json['loyaltyPoints'] is int
          ? json['loyaltyPoints']
          : int.tryParse(json['loyaltyPoints']?.toString() ?? '0') ?? 0,
      gender: json['gender']?.toString(),
      avatar: json['avatar']?.toString(),
      dateOfBirth: json['dateOfBirth'] != null ? DateTime.tryParse(json['dateOfBirth'].toString()) : null,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'fullName': fullName,
        'email': email,
        'role': role,
        'phone': phone,
        'status': status,
        'loyaltyPoints': loyaltyPoints,
        'gender': gender,
        'avatar': avatar,
        'dateOfBirth': dateOfBirth?.toIso8601String(),
        'createdAt': createdAt?.toIso8601String(),
      };

  @override
  List<Object?> get props => [
        id,
        fullName,
        email,
        role,
        phone,
        status,
        loyaltyPoints,
        gender,
        avatar,
        dateOfBirth,
        createdAt,
      ];
}

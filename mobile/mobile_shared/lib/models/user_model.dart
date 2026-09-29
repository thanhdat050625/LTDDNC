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
  final DateTime? dateOfBirth;

  const UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    this.phone,
    required this.status,
    this.loyaltyPoints = 0,
    this.gender,
    this.dateOfBirth,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      fullName: json['fullName'],
      email: json['email'],
      role: json['role'],
      phone: json['phone'],
      status: json['status'],
      loyaltyPoints: json['loyaltyPoints'] ?? 0,
      gender: json['gender'],
      dateOfBirth: json['dateOfBirth'] != null ? DateTime.parse(json['dateOfBirth']) : null,
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
        'dateOfBirth': dateOfBirth?.toIso8601String(),
      };

  @override
  List<Object?> get props => [id, fullName, email, role, phone, status, loyaltyPoints, gender, dateOfBirth];
}

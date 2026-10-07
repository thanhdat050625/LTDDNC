import 'package:equatable/equatable.dart';

class NotificationModel extends Equatable {
  final String id;
  final String subject;
  final String content;
  final String type;
  final String? link;
  final bool isRead;
  final DateTime createdAt;

  const NotificationModel({
    required this.id,
    required this.subject,
    required this.content,
    required this.type,
    this.link,
    this.isRead = false,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id']?.toString() ?? '',
      subject: json['subject']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      type: json['type']?.toString() ?? 'SYSTEM',
      link: json['link']?.toString(),
      isRead: json['isRead'] == true,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [id, subject, content, type, link, isRead, createdAt];
}

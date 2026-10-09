import 'package:equatable/equatable.dart';

class StaffScheduleModel extends Equatable {
  final int id;
  final int staffId;
  final String staffName;
  final String staffEmail;
  final String? staffAvatar;
  final int cinemaId;
  final String cinemaName;
  final int shiftId;
  final String shiftName;
  final String startTime;
  final String endTime;
  final String workDate;
  final String assignedRole;
  final String status;
  final String? note;
  final String? assignedByName;

  const StaffScheduleModel({
    required this.id,
    required this.staffId,
    required this.staffName,
    required this.staffEmail,
    this.staffAvatar,
    required this.cinemaId,
    required this.cinemaName,
    required this.shiftId,
    required this.shiftName,
    required this.startTime,
    required this.endTime,
    required this.workDate,
    required this.assignedRole,
    required this.status,
    this.note,
    this.assignedByName,
  });

  factory StaffScheduleModel.fromJson(Map<String, dynamic> json) {
    final staff = json['staff'] as Map<String, dynamic>?;
    final cinema = json['cinema'] as Map<String, dynamic>?;
    final shift = json['shift'] as Map<String, dynamic>?;
    final assignedBy = json['assignedBy'] as Map<String, dynamic>?;

    String parsedWorkDate = '';
    final rawWorkDate = json['workDate'];
    if (rawWorkDate != null) {
      final str = rawWorkDate.toString();
      if (str.contains('T')) {
        final dt = DateTime.tryParse(str);
        if (dt != null) {
          final local = dt.toLocal();
          final y = local.year.toString().padLeft(4, '0');
          final m = local.month.toString().padLeft(2, '0');
          final d = local.day.toString().padLeft(2, '0');
          parsedWorkDate = '$y-$m-$d';
        } else {
          parsedWorkDate = str.split('T').first;
        }
      } else {
        parsedWorkDate = str;
      }
    }

    return StaffScheduleModel(
      id: json['id'] as int,
      staffId: json['staffId'] as int? ?? staff?['id'] as int? ?? 0,
      staffName: staff?['fullName'] as String? ?? 'Nhân viên #${json['staffId']}',
      staffEmail: staff?['email'] as String? ?? '',
      staffAvatar: staff?['avatar'] as String?,
      cinemaId: json['cinemaId'] as int? ?? cinema?['id'] as int? ?? 0,
      cinemaName: cinema?['name'] as String? ?? 'Rạp #${json['cinemaId']}',
      shiftId: json['shiftId'] as int? ?? shift?['id'] as int? ?? 0,
      shiftName: shift?['name'] as String? ?? 'Ca làm #${json['shiftId']}',
      startTime: shift?['startTime'] as String? ?? '',
      endTime: shift?['endTime'] as String? ?? '',
      workDate: parsedWorkDate,
      assignedRole: json['assignedRole'] as String? ?? 'GENERAL',
      status: json['status'] as String? ?? 'SCHEDULED',
      note: json['note'] as String?,
      assignedByName: assignedBy?['fullName'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'staffId': staffId,
      'cinemaId': cinemaId,
      'shiftId': shiftId,
      'workDate': workDate,
      'assignedRole': assignedRole,
      'status': status,
      if (note != null) 'note': note,
    };
  }

  @override
  List<Object?> get props => [
        id,
        staffId,
        staffName,
        staffEmail,
        staffAvatar,
        cinemaId,
        cinemaName,
        shiftId,
        shiftName,
        startTime,
        endTime,
        workDate,
        assignedRole,
        status,
        note,
        assignedByName,
      ];
}

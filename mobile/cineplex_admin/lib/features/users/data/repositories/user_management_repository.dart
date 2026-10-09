import 'package:mobile_shared/mobile_shared.dart';

class UserManagementResult {
  final List<UserModel> users;
  final int page;
  final int pageSize;
  final int totalItems;
  final int totalPages;
  final int totalAll;
  final int totalCustomers;
  final int totalStaff;
  final int totalBlocked;

  const UserManagementResult({
    required this.users,
    this.page = 1,
    this.pageSize = 10,
    this.totalItems = 0,
    this.totalPages = 1,
    this.totalAll = 0,
    this.totalCustomers = 0,
    this.totalStaff = 0,
    this.totalBlocked = 0,
  });
}

class UserManagementRepository {
  final DioClient _dioClient;

  UserManagementRepository(this._dioClient);

  Future<UserManagementResult> getUsers({
    int page = 1,
    int pageSize = 10,
    String? role,
    String? status,
    String? keyword,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'pageSize': pageSize,
    };
    if (role != null && role.isNotEmpty) queryParams['role'] = role;
    if (status != null && status.isNotEmpty) queryParams['status'] = status;
    if (keyword != null && keyword.trim().isNotEmpty) queryParams['keyword'] = keyword.trim();

    final response = await _dioClient.get('/users', queryParameters: queryParams);
    final raw = response.data as Map<String, dynamic>;
    final items = (raw['data'] as List? ?? [])
        .map((e) => UserModel.fromJson(e as Map<String, dynamic>))
        .toList();
    final pagination = raw['pagination'] as Map<String, dynamic>? ?? {};
    final stats = raw['stats'] as Map<String, dynamic>? ?? {};

    return UserManagementResult(
      users: items,
      page: pagination['page'] is int ? pagination['page'] : int.tryParse(pagination['page']?.toString() ?? '1') ?? 1,
      pageSize: pagination['pageSize'] is int
          ? pagination['pageSize']
          : int.tryParse(pagination['pageSize']?.toString() ?? '10') ?? 10,
      totalItems: pagination['totalItems'] is int
          ? pagination['totalItems']
          : int.tryParse(pagination['totalItems']?.toString() ?? '0') ?? items.length,
      totalPages: pagination['totalPages'] is int
          ? pagination['totalPages']
          : int.tryParse(pagination['totalPages']?.toString() ?? '1') ?? 1,
      totalAll: stats['totalAll'] is int
          ? stats['totalAll']
          : int.tryParse(stats['totalAll']?.toString() ?? '0') ?? items.length,
      totalCustomers: stats['totalCustomers'] is int
          ? stats['totalCustomers']
          : int.tryParse(stats['totalCustomers']?.toString() ?? '0') ?? 0,
      totalStaff: stats['totalStaff'] is int
          ? stats['totalStaff']
          : int.tryParse(stats['totalStaff']?.toString() ?? '0') ?? 0,
      totalBlocked: stats['totalBlocked'] is int
          ? stats['totalBlocked']
          : int.tryParse(stats['totalBlocked']?.toString() ?? '0') ?? 0,
    );
  }

  Future<UserModel> createStaff({
    required String fullName,
    required String email,
    required String password,
    String? phone,
    String? avatarFilePath,
  }) async {
    final payload = <String, dynamic>{
      'fullName': fullName.trim(),
      'email': email.trim(),
      'password': password,
      if (phone != null && phone.trim().isNotEmpty) 'phone': phone.trim(),
    };

    dynamic requestData;
    if (avatarFilePath != null && avatarFilePath.isNotEmpty) {
      final formData = FormData.fromMap(payload);
      formData.files.add(
        MapEntry('avatar', await MultipartFile.fromFile(avatarFilePath)),
      );
      requestData = formData;
    } else {
      requestData = payload;
    }

    final response = await _dioClient.post('/users/staff', data: requestData);
    final raw = response.data as Map<String, dynamic>;
    final data = raw['data'] as Map<String, dynamic>;
    return UserModel.fromJson(data);
  }

  Future<UserModel> updateStaff({
    required int staffId,
    required String fullName,
    String? email,
    String? password,
    String? phone,
    String? avatarFilePath,
  }) async {
    final payload = <String, dynamic>{
      'fullName': fullName.trim(),
      if (email != null && email.trim().isNotEmpty) 'email': email.trim(),
      if (password != null && password.trim().isNotEmpty) 'password': password.trim(),
      'phone': phone?.trim() ?? '',
    };

    dynamic requestData;
    if (avatarFilePath != null && avatarFilePath.isNotEmpty) {
      final formData = FormData.fromMap(payload);
      formData.files.add(
        MapEntry('avatar', await MultipartFile.fromFile(avatarFilePath)),
      );
      requestData = formData;
    } else {
      requestData = payload;
    }

    final response = await _dioClient.put('/users/staff/$staffId', data: requestData);
    final raw = response.data as Map<String, dynamic>;
    final data = raw['data'] as Map<String, dynamic>;
    return UserModel.fromJson(data);
  }

  Future<void> updateUserStatus(int userId, String status) async {
    await _dioClient.put('/users/$userId/status', data: {
      'status': status,
    });
  }
}

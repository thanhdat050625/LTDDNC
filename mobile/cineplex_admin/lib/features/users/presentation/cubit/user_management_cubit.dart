import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile_shared/mobile_shared.dart';
import '../../data/repositories/user_management_repository.dart';

abstract class UserManagementState extends Equatable {
  const UserManagementState();
  @override
  List<Object?> get props => [];
}

class UserManagementInitial extends UserManagementState {}

class UserManagementLoading extends UserManagementState {}

class UserManagementLoaded extends UserManagementState {
  final List<UserModel> users;
  final int page;
  final int pageSize;
  final int totalPages;
  final int totalItems;
  final int totalAll;
  final int totalCustomers;
  final int totalStaff;
  final int totalBlocked;
  final String? selectedRole;
  final String? selectedStatus;
  final String keyword;
  final int? updatingUserId;
  final bool isCreatingStaff;

  const UserManagementLoaded({
    required this.users,
    this.page = 1,
    this.pageSize = 10,
    this.totalPages = 1,
    this.totalItems = 0,
    this.totalAll = 0,
    this.totalCustomers = 0,
    this.totalStaff = 0,
    this.totalBlocked = 0,
    this.selectedRole,
    this.selectedStatus,
    this.keyword = '',
    this.updatingUserId,
    this.isCreatingStaff = false,
  });

  @override
  List<Object?> get props => [
        users,
        page,
        pageSize,
        totalPages,
        totalItems,
        totalAll,
        totalCustomers,
        totalStaff,
        totalBlocked,
        selectedRole,
        selectedStatus,
        keyword,
        updatingUserId,
        isCreatingStaff,
      ];

  UserManagementLoaded copyWith({
    List<UserModel>? users,
    int? page,
    int? pageSize,
    int? totalPages,
    int? totalItems,
    int? totalAll,
    int? totalCustomers,
    int? totalStaff,
    int? totalBlocked,
    String? selectedRole,
    bool clearRole = false,
    String? selectedStatus,
    bool clearStatus = false,
    String? keyword,
    int? updatingUserId,
    bool clearUpdatingUser = false,
    bool? isCreatingStaff,
  }) {
    return UserManagementLoaded(
      users: users ?? this.users,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      totalPages: totalPages ?? this.totalPages,
      totalItems: totalItems ?? this.totalItems,
      totalAll: totalAll ?? this.totalAll,
      totalCustomers: totalCustomers ?? this.totalCustomers,
      totalStaff: totalStaff ?? this.totalStaff,
      totalBlocked: totalBlocked ?? this.totalBlocked,
      selectedRole: clearRole ? null : (selectedRole ?? this.selectedRole),
      selectedStatus: clearStatus ? null : (selectedStatus ?? this.selectedStatus),
      keyword: keyword ?? this.keyword,
      updatingUserId: clearUpdatingUser ? null : (updatingUserId ?? this.updatingUserId),
      isCreatingStaff: isCreatingStaff ?? this.isCreatingStaff,
    );
  }
}

class UserManagementError extends UserManagementState {
  final String message;
  const UserManagementError(this.message);
  @override
  List<Object?> get props => [message];
}

class UserManagementCubit extends Cubit<UserManagementState> {
  final UserManagementRepository repository;

  UserManagementCubit(this.repository) : super(UserManagementInitial());

  Future<void> loadUsers({
    int? page,
    String? role,
    bool clearRole = false,
    String? status,
    bool clearStatus = false,
    String? keyword,
  }) async {
    final currentState = state;
    final currentPage = page ?? (currentState is UserManagementLoaded ? currentState.page : 1);
    final currentRole = clearRole
        ? null
        : (role ?? (currentState is UserManagementLoaded ? currentState.selectedRole : null));
    final currentStatus = clearStatus
        ? null
        : (status ?? (currentState is UserManagementLoaded ? currentState.selectedStatus : null));
    final currentKeyword = keyword ?? (currentState is UserManagementLoaded ? currentState.keyword : '');

    emit(UserManagementLoading());
    try {
      final result = await repository.getUsers(
        page: currentPage,
        pageSize: 10,
        role: currentRole,
        status: currentStatus,
        keyword: currentKeyword,
      );

      emit(UserManagementLoaded(
        users: result.users,
        page: result.page,
        pageSize: result.pageSize,
        totalPages: result.totalPages,
        totalItems: result.totalItems,
        totalAll: result.totalAll,
        totalCustomers: result.totalCustomers,
        totalStaff: result.totalStaff,
        totalBlocked: result.totalBlocked,
        selectedRole: currentRole,
        selectedStatus: currentStatus,
        keyword: currentKeyword,
      ));
    } catch (e) {
      emit(UserManagementError(e.toString()));
    }
  }

  Future<void> setRoleFilter(String? role) async {
    await loadUsers(page: 1, role: role, clearRole: role == null);
  }

  Future<void> setStatusFilter(String? status) async {
    await loadUsers(page: 1, status: status, clearStatus: status == null);
  }

  Future<void> searchUsers(String keyword) async {
    await loadUsers(page: 1, keyword: keyword);
  }

  Future<void> goToPage(int targetPage) async {
    final currentState = state;
    if (currentState is! UserManagementLoaded) return;
    if (targetPage < 1 || targetPage > currentState.totalPages) return;
    await loadUsers(page: targetPage);
  }

  Future<bool> createStaff({
    required String fullName,
    required String email,
    required String password,
    String? phone,
  }) async {
    final currentState = state;
    if (currentState is UserManagementLoaded) {
      emit(currentState.copyWith(isCreatingStaff: true));
    }

    try {
      await repository.createStaff(
        fullName: fullName,
        email: email,
        password: password,
        phone: phone,
      );
      // Reload on success
      await loadUsers();
      return true;
    } catch (e) {
      if (currentState is UserManagementLoaded) {
        emit(currentState.copyWith(isCreatingStaff: false));
      }
      return false;
    }
  }

  Future<bool> toggleUserStatus(int userId, String currentStatus) async {
    final currentState = state;
    if (currentState is! UserManagementLoaded) return false;

    final newStatus = currentStatus.toUpperCase() == 'BLOCKED' ? 'ACTIVE' : 'BLOCKED';
    emit(currentState.copyWith(updatingUserId: userId));

    try {
      await repository.updateUserStatus(userId, newStatus);
      final updatedList = currentState.users.map((u) {
        if (u.id == userId) {
          return UserModel(
            id: u.id,
            fullName: u.fullName,
            email: u.email,
            role: u.role,
            phone: u.phone,
            status: newStatus,
            loyaltyPoints: u.loyaltyPoints,
            gender: u.gender,
            dateOfBirth: u.dateOfBirth,
            createdAt: u.createdAt,
          );
        }
        return u;
      }).toList();

      final newTotalBlocked = newStatus == 'BLOCKED'
          ? currentState.totalBlocked + 1
          : (currentState.totalBlocked > 0 ? currentState.totalBlocked - 1 : 0);

      emit(currentState.copyWith(
        users: updatedList,
        clearUpdatingUser: true,
        totalBlocked: newTotalBlocked,
      ));
      return true;
    } catch (e) {
      emit(currentState.copyWith(clearUpdatingUser: true));
      return false;
    }
  }
}

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/repositories/user_management_repository.dart';

abstract class UserManagementState extends Equatable {
  const UserManagementState();
  @override
  List<Object?> get props => [];
}

class UserManagementInitial extends UserManagementState {}
class UserManagementLoading extends UserManagementState {}

class UserManagementLoaded extends UserManagementState {
  final List<Map<String, dynamic>> users;
  final bool isSearching;
  final String keyword;
  final int? updatingUserId;

  const UserManagementLoaded({
    required this.users,
    this.isSearching = false,
    this.keyword = '',
    this.updatingUserId,
  });

  @override
  List<Object?> get props => [users, isSearching, keyword, updatingUserId];

  UserManagementLoaded copyWith({
    List<Map<String, dynamic>>? users,
    bool? isSearching,
    String? keyword,
    int? updatingUserId,
  }) {
    return UserManagementLoaded(
      users: users ?? this.users,
      isSearching: isSearching ?? this.isSearching,
      keyword: keyword ?? this.keyword,
      updatingUserId: updatingUserId,
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

  Future<void> loadUsers() async {
    emit(UserManagementLoading());
    try {
      final users = await repository.getUsers();
      emit(UserManagementLoaded(users: users));
    } catch (e) {
      emit(UserManagementError(e.toString()));
    }
  }

  Future<void> searchUsers(String keyword) async {
    final cleanKeyword = keyword.trim();
    if (cleanKeyword.isEmpty) {
      await loadUsers();
      return;
    }

    emit(UserManagementLoading());
    try {
      final users = await repository.searchUsers(cleanKeyword);
      emit(UserManagementLoaded(users: users, isSearching: true, keyword: cleanKeyword));
    } catch (e) {
      emit(UserManagementError(e.toString()));
    }
  }

  Future<bool> toggleUserStatus(int userId, String currentStatus) async {
    final currentState = state;
    if (currentState is! UserManagementLoaded) return false;

    final newStatus = currentStatus == 'BLOCKED' ? 'ACTIVE' : 'BLOCKED';
    emit(currentState.copyWith(updatingUserId: userId));

    try {
      await repository.updateUserStatus(userId, newStatus);
      final updatedList = currentState.users.map((u) {
        if (u['id'] == userId) {
          final copy = Map<String, dynamic>.from(u);
          copy['status'] = newStatus;
          return copy;
        }
        return u;
      }).toList();

      emit(currentState.copyWith(users: updatedList, updatingUserId: null));
      return true;
    } catch (e) {
      emit(currentState.copyWith(updatingUserId: null));
      return false;
    }
  }
}

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/repositories/profile_repository.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();
  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}
class ProfileLoading extends ProfileState {}
class ProfileLoaded extends ProfileState {
  final Map<String, dynamic> user;
  final Map<String, dynamic> loyaltyInfo;

  const ProfileLoaded(this.user, this.loyaltyInfo);

  @override
  List<Object?> get props => [user, loyaltyInfo];
}
class ProfileError extends ProfileState {
  final String message;
  const ProfileError(this.message);
  @override
  List<Object?> get props => [message];
}

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepository repository;

  ProfileCubit(this.repository) : super(ProfileInitial());

  Future<void> loadProfile() async {
    emit(ProfileLoading());
    try {
      final user = await repository.getProfile();
      final loyaltyInfo = await repository.getLoyaltyInfo();
      emit(ProfileLoaded(user, loyaltyInfo));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<bool> updateProfile(Map<String, dynamic> data, {String? avatarPath}) async {
    try {
      await repository.updateProfile(data, avatarPath: avatarPath);
      await loadProfile();
      return true;
    } catch (e) {
      emit(ProfileError(e.toString()));
      return false;
    }
  }

  Future<void> logout() async {
    // Handled by AuthBloc in ProfileScreen
  }
}

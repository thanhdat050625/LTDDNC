import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../repositories/auth_repository.dart';
import '../models/user_model.dart';

// --- States ---
abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final UserModel user;
  const AuthAuthenticated(this.user);
  @override
  List<Object?> get props => [user];
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
  @override
  List<Object?> get props => [message];
}

class AuthOtpSent extends AuthState {}

class AuthPasswordReset extends AuthState {}

// --- Events ---
abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class CheckAuthStatus extends AuthEvent {}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;
  final bool rememberMe;
  const LoginRequested(this.email, this.password, {this.rememberMe = false});
  @override
  List<Object?> get props => [email, password, rememberMe];
}

class SendOtpRequested extends AuthEvent {
  final String email;
  final String purpose;
  const SendOtpRequested(this.email, this.purpose);
  @override
  List<Object?> get props => [email, purpose];
}

class RegisterRequested extends AuthEvent {
  final String email;
  final String otp;
  final String password;
  final String confirmPassword;
  const RegisterRequested(this.email, this.otp, this.password, this.confirmPassword);
  @override
  List<Object?> get props => [email, otp, password, confirmPassword];
}

class ForgotPasswordRequested extends AuthEvent {
  final String email;
  final String otp;
  final String newPassword;
  final String confirmPassword;
  const ForgotPasswordRequested(this.email, this.otp, this.newPassword, this.confirmPassword);
  @override
  List<Object?> get props => [email, otp, newPassword, confirmPassword];
}

class LogoutRequested extends AuthEvent {}

// --- Bloc ---
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _repo;

  AuthBloc(this._repo) : super(AuthInitial()) {
    on<CheckAuthStatus>(_onCheckAuth);
    on<LoginRequested>(_onLogin);
    on<SendOtpRequested>(_onSendOtp);
    on<RegisterRequested>(_onRegister);
    on<ForgotPasswordRequested>(_onForgotPassword);
    on<LogoutRequested>(_onLogout);
  }

  Future<void> _onCheckAuth(CheckAuthStatus event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final user = await _repo.checkAuth();
    if (user != null) {
      emit(AuthAuthenticated(user));
    } else {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onLogin(LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await _repo.login(event.email, event.password, rememberMe: event.rememberMe);
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onSendOtp(SendOtpRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _repo.sendOtp(event.email, event.purpose);
      emit(AuthOtpSent());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onRegister(RegisterRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await _repo.register(event.email, event.otp, event.password, event.confirmPassword);
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onForgotPassword(ForgotPasswordRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _repo.forgotPassword(event.email, event.otp, event.newPassword, event.confirmPassword);
      emit(AuthPasswordReset());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onLogout(LogoutRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    await _repo.logout();
    emit(AuthUnauthenticated());
  }
}

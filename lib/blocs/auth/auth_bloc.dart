import 'package:bloc/bloc.dart';
import 'package:customer_maxx_crm/models/user.dart';
import 'package:customer_maxx_crm/services/auth_service.dart';
import 'package:customer_maxx_crm/utils/api_service_locator.dart';
import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class AppStarted extends AuthEvent {}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;
  final String? role;

  const LoginRequested({required this.email, required this.password, this.role});

  @override
  List<Object> get props => [email, password, role ?? ''];
}

class RegisterRequested extends AuthEvent {
  final String name;
  final String email;
  final String password;
  final String? role;

  const RegisterRequested({required this.name, required this.email, required this.password, this.role});

  @override
  List<Object> get props => [name, email, password, role ?? ''];
}

class LogoutRequested extends AuthEvent {}

class CheckAuthStatus extends AuthEvent {}

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class Authenticated extends AuthState {
  final User? user;

  const Authenticated(this.user);

  @override
  List<Object?> get props => [user];
}

class Unauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService = ServiceLocator.authService;

  AuthBloc() : super(AuthInitial()) {
    on<AppStarted>(_onAppStarted);
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<CheckAuthStatus>(_onCheckAuthStatus);
  }

  Future<void> _onAppStarted(AppStarted event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _authService.init();
      final user = _authService.currentUser;
      if (user != null) {
        emit(Authenticated(user));
      } else {
        emit(Unauthenticated());
      }
    } catch (e) {
      emit(AuthError('Failed to initialize auth: ${e.toString()}'));
    }
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      // Log the login attempt
      // ignore: avoid_print
      print('Attempting login with email: ${event.email}, role: ${event.role}');
      final result = await _authService.login(
        event.email,
        event.password,
        event.role ?? 'admin',
      );
      
      // Log successful login
      // ignore: avoid_print
      print('Login successful: ${result['success']}');
      
      if (result['success']) {
        emit(Authenticated(result['user']));
      } else {
        emit(AuthError(result['message'] ?? 'Login failed'));
      }
    } catch (e) {
      // Log login error
      // ignore: avoid_print
      print('Login failed with error: $e');
      // Pass through the actual backend message without prefix
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onRegisterRequested(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final result = await _authService.register(
        event.name,
        event.email,
        event.password,
        event.role ?? 'lead_manager',
      );
      
      if (result['success']) {
        // Revert to the previous approach that was working
        emit(AuthInitial());
      } else {
        emit(AuthError(result['message'] ?? 'Registration failed'));
      }
    } catch (e) {
      // Pass through the actual backend message without prefix
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      // Log the logout attempt
      // ignore: avoid_print
      print('Attempting logout');
      await _authService.logout();
      // Log successful logout
      // ignore: avoid_print
      print('Logout successful');
      emit(Unauthenticated());
    } catch (e) {
      // Log logout error
      // ignore: avoid_print
      print('Logout failed with error: $e');
      emit(Unauthenticated()); // Even if logout fails, clear local state
    }
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
    final user = _authService.currentUser;
    if (user != null) {
      emit(Authenticated(user));
    } else {
      emit(Unauthenticated());
    }
  }
}
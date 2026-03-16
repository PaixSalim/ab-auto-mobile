part of 'auth_bloc.dart';

abstract class AuthEvent {
  const AuthEvent();
}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;
  const LoginRequested({required this.email, required this.password});
}

class RegisterRequested extends AuthEvent {
  final String fullName;
  final String email;
  final String password;
  const RegisterRequested({
    required this.fullName,
    required this.email,
    required this.password,
  });
}

class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}

class SessionExpired extends AuthEvent {
  const SessionExpired();
}

class AppStarted extends AuthEvent {
  const AppStarted();
}

part of 'auth_bloc.dart';

abstract class AuthEvent {
  const AuthEvent();
}

class LoginRequested extends AuthEvent {
  final String uid; // API attend "uid" au lieu de "email"
  final String password;
  const LoginRequested({required this.uid, required this.password});
}

class RegisterRequested extends AuthEvent {
  final String fullName;
  final String? email; // Optionnel comme sur le web
  final String password;
  final String phone;
  final String? city; // Optionnel pour les clients
  final String confirmPassword;
  final bool isSeller;
  
  const RegisterRequested({
    required this.fullName,
    this.email,
    required this.password,
    required this.phone,
    this.city,
    required this.confirmPassword,
    required this.isSeller,
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

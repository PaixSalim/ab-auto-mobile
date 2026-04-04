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
  final String email;
  final String password;
  final String phone;
  final String city;
  final String confirmPassword;
  final bool isSeller;
  
  const RegisterRequested({
    required this.fullName,
    required this.email,
    required this.password,
    required this.phone,
    required this.city,
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

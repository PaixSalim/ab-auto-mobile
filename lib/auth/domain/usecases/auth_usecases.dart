import 'package:auto/auth/domain/entities/user_entity.dart';
import 'package:auto/auth/domain/repository/auth_repository.dart';
import 'package:auto/core/resources/data_state.dart';

class LoginUseCase {
  final AuthRepository _repository;
  LoginUseCase(this._repository);

  Future<DataState<UserEntity>> call({
    required String uid, // API attend "uid" au lieu de "email"
    required String password,
  }) =>
      _repository.login(uid: uid, password: password);
}

class RegisterUseCase {
  final AuthRepository _repository;
  RegisterUseCase(this._repository);

  Future<DataState<UserEntity>> call({
    required String fullName,
    String? email, // Optionnel comme sur le web
    required String password,
    required String phone,
    String? city, // Optionnel pour les clients
    required String confirmPassword,
    required bool isSeller,
  }) =>
      _repository.register(
        fullName: fullName,
        email: email,
        password: password,
        phone: phone,
        city: city,
        confirmPassword: confirmPassword,
        isSeller: isSeller,
      );
}

class LogoutUseCase {
  final AuthRepository _repository;
  LogoutUseCase(this._repository);

  Future<void> call() => _repository.logout();
}

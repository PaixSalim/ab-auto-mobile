import 'package:auto/auth/domain/entities/user_entity.dart';
import 'package:auto/auth/domain/repository/auth_repository.dart';
import 'package:auto/core/resources/data_state.dart';

class LoginUseCase {
  final AuthRepository _repository;
  LoginUseCase(this._repository);

  Future<DataState<UserEntity>> call({
    required String email,
    required String password,
  }) =>
      _repository.login(email: email, password: password);
}

class RegisterUseCase {
  final AuthRepository _repository;
  RegisterUseCase(this._repository);

  Future<DataState<UserEntity>> call({
    required String fullName,
    required String email,
    required String password,
  }) =>
      _repository.register(fullName: fullName, email: email, password: password);
}

class LogoutUseCase {
  final AuthRepository _repository;
  LogoutUseCase(this._repository);

  Future<void> call() => _repository.logout();
}

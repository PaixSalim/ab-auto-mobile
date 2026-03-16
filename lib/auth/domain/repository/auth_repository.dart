import 'package:auto/auth/domain/entities/user_entity.dart';
import 'package:auto/core/resources/data_state.dart';

abstract class AuthRepository {
  Future<DataState<UserEntity>> login({
    required String email,
    required String password,
  });

  Future<DataState<UserEntity>> register({
    required String fullName,
    required String email,
    required String password,
  });

  Future<void> logout();
}

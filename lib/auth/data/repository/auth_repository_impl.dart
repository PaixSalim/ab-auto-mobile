import 'package:auto/auth/data/datasource/auth_remote_datasource.dart';
import 'package:auto/auth/domain/entities/user_entity.dart';
import 'package:auto/auth/domain/repository/auth_repository.dart';
import 'package:auto/core/resources/data_state.dart';
import 'package:auto/core/resources/local_storage_service.dart';
import 'package:dio/dio.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource _datasource;
  AuthRepositoryImpl(this._datasource);

  @override
  Future<DataState<UserEntity>> login({
    required String uid, // API attend "uid" au lieu de "email"
    required String password,
  }) async {
    try {
      final response = await _datasource.login(uid: uid, password: password);
      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final user = _parseUser(data);
        await LocalStorageService.saveAuth(
          token: 'session',
          fullName: user.fullName,
          email: user.email,
        );
        return DataSuccess(user);
      }
      return DataFailed(
        DioException(
          requestOptions: response.requestOptions,
          message: (response.data as Map?)?['message'] ?? 'Identifiants invalides',
          response: response,
        ),
      );
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<UserEntity>> register({
    required String fullName,
    required String email,
    required String password,
    required String phone,
    required String city,
    required String confirmPassword,
    required bool isSeller,
  }) async {
    try {
      final response = await _datasource.register(
        fullName: fullName,
        email: email,
        password: password,
        phone: phone,
        city: city,
        confirmPassword: confirmPassword,
        isSeller: isSeller,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data as Map<String, dynamic>;
        final user = _parseUser(data);
        await LocalStorageService.saveAuth(
          token: 'session',
          fullName: user.fullName,
          email: user.email,
        );
        return DataSuccess(user);
      }
      return DataFailed(
        DioException(
          requestOptions: response.requestOptions,
          message: (response.data as Map?)?['message'] ?? 'Erreur lors de l\'inscription',
          response: response,
        ),
      );
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _datasource.logout();
    } catch (_) {}
    await LocalStorageService.clearAuth();
  }

  UserEntity _parseUser(Map<String, dynamic> data) {
    final u = data['user'] ?? data;
    return UserEntity(
      token: 'session',
      fullName: u['fullName'] ?? '',
      email: u['email'] ?? '',
      role: u['role'] ?? 'customer',
    );
  }
}

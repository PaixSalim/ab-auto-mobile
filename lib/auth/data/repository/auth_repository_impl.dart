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
      print('🔐 Login attempt with uid: $uid');
      final response = await _datasource.login(uid: uid, password: password);
      
      print('🔐 Login response status: ${response.statusCode}');
      print('🔐 Login response data: ${response.data}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data as Map<String, dynamic>;
        
        // Check if login was successful
        if (data['success'] == false) {
          print('❌ Login failed: ${data['message']}');
          return DataFailed(
            DioException(
              requestOptions: response.requestOptions,
              message: data['message'] ?? 'Identifiants invalides',
              response: response,
            ),
          );
        }
        
        final user = _parseUser(data);
        await LocalStorageService.saveAuth(
          token: data['access_token'] ?? 'session',
          fullName: user.fullName,
          email: user.email,
          phone: user.phone,
          userId: user.id,
        );
        print('✅ Login successful for: ${user.fullName}');
        return DataSuccess(user);
      }
      return DataFailed(
        DioException(
          requestOptions: response.requestOptions,
          message: (response.data as Map?)?['message'] ?? (response.data as Map?)?['error'] ?? 'Identifiants invalides',
          response: response,
        ),
      );
    } on DioException catch (e) {
      print('❌ Login DioException: ${e.message}');
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<UserEntity>> register({
    required String fullName,
    String? email,
    required String password,
    required String phone,
    String? city,
    required String confirmPassword,
    required bool isSeller,
  }) async {
    try {
      print('📝 Registering user: $fullName, phone: $phone');
      final response = await _datasource.register(
        fullName: fullName,
        email: email,
        password: password,
        phone: phone,
        city: city,
        confirmPassword: confirmPassword,
        isSeller: isSeller,
      );
      
      print('📝 Response status: ${response.statusCode}');
      print('📝 Response data: ${response.data}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data as Map<String, dynamic>;
        final user = _parseUser(data);
        await LocalStorageService.saveAuth(
          token: data['access_token'] ?? 'session',
          fullName: user.fullName,
          email: user.email,
          phone: user.phone,
          userId: user.id,
        );
        print('✅ Registration successful');
        return DataSuccess(user);
      }
      
      // Extract error message from response
      final errorMsg = (response.data as Map?)?['message'] ?? 
                      (response.data as Map?)?['error'] ?? 
                      'Erreur lors de l\'inscription';
      print('❌ Registration failed: $errorMsg');
      
      return DataFailed(
        DioException(
          requestOptions: response.requestOptions,
          message: errorMsg,
          response: response,
        ),
      );
    } on DioException catch (e) {
      print('❌ DioException during registration: ${e.message}');
      print('❌ Response: ${e.response?.data}');
      
      // Try to extract error message from response
      String errorMsg = 'Erreur lors de l\'inscription';
      if (e.response?.data != null) {
        final data = e.response?.data;
        if (data is Map) {
          errorMsg = data['message'] ?? data['error'] ?? errorMsg;
        }
      }
      
      return DataFailed(
        DioException(
          requestOptions: e.requestOptions,
          message: errorMsg,
          response: e.response,
          type: e.type,
        ),
      );
    } catch (e) {
      print('❌ Unexpected error during registration: $e');
      return DataFailed(
        DioException(
          requestOptions: RequestOptions(),
          message: e.toString(),
          type: DioExceptionType.unknown,
        ),
      );
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
      id: u['id']?.toString() ?? '',
      token: data['access_token'] ?? 'session',
      fullName: u['fullName'] ?? '',
      email: u['email'] ?? '',
      phone: u['phone'] ?? '',
      role: u['role'] ?? 'customer',
    );
  }
}

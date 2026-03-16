import 'package:dio/dio.dart';

class AuthRemoteDatasource {
  final Dio _dio;
  AuthRemoteDatasource(this._dio);

  Future<Response> login({
    required String email,
    required String password,
  }) async {
    return await _dio.post(
      '/auth/login',
      data: {'email': email, 'password': password},
      options: Options(
        headers: {'Accept': 'application/json', 'Content-Type': 'application/json'},
        followRedirects: false,
        validateStatus: (status) => status != null && status < 500,
      ),
    );
  }

  Future<Response> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    return await _dio.post(
      '/auth/register',
      data: {'fullName': fullName, 'email': email, 'password': password},
      options: Options(
        headers: {'Accept': 'application/json', 'Content-Type': 'application/json'},
        followRedirects: false,
        validateStatus: (status) => status != null && status < 500,
      ),
    );
  }

  Future<Response> getMe() async {
    return await _dio.get(
      '/auth/me',
      options: Options(headers: {'Accept': 'application/json'}),
    );
  }

  Future<Response> logout() async {
    return await _dio.post(
      '/auth/logout',
      options: Options(headers: {'Accept': 'application/json'}),
    );
  }
}

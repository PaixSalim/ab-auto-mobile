import 'package:dio/dio.dart';

class AuthRemoteDatasource {
  final Dio _dio;
  AuthRemoteDatasource(this._dio);

  Future<Response> login({
    required String uid, // API attend "uid" au lieu de "email"
    required String password,
  }) async {
    print('🔐 LOGIN ATTEMPT - uid: $uid, password: ${password.length > 0 ? "***" : "empty"}');
    
    final response = await _dio.post(
      '/auth/mobile/login',
      data: {'uid': uid, 'password': password},
      options: Options(
        headers: {'Accept': 'application/json', 'Content-Type': 'application/json'},
        followRedirects: false,
        validateStatus: (status) => status != null && status < 500,
      ),
    );
    
    print('🔐 LOGIN RESPONSE - Status: ${response.statusCode}');
    print('🔐 LOGIN RESPONSE - Data: ${response.data}');
    
    return response;
  }

  Future<Response> register({
    required String fullName,
    String? email,
    required String password,
    required String phone,
    String? city,
    required String confirmPassword,
    required bool isSeller,
  }) async {
    final data = {
      'fullName': fullName,
      'phone': phone,
      'password': password,
      'confirmPassword': confirmPassword,
      'isSeller': isSeller,
    };
    
    // Ajouter email seulement s'il est fourni
    if (email != null && email.isNotEmpty) {
      data['email'] = email;
    }
    
    // Ajouter city seulement si elle est fournie
    if (city != null && city.isNotEmpty) {
      data['city'] = city;
    }
    
    return await _dio.post(
      '/auth/mobile/register',
      data: data,
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

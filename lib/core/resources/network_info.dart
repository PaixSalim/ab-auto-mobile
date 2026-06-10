import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:auto/core/constants/constants.dart';
import 'package:dio/dio.dart';

class NetworkInfo {
  final InternetConnection _connection;
  const NetworkInfo(this._connection);

  Future<bool> get isConnected async {
    print('📡 NetworkInfo: checking connection...');
    // Tente d'abord un ping direct vers le serveur API local
    try {
      print('📡 NetworkInfo: trying direct ping to health endpoint...');
      final dio = Dio();
      final response = await dio
          .get(
            localAPIBaseUrl.replaceAll('/api/v1', '/health'),
            options: Options(
              sendTimeout: const Duration(seconds: 3),
              receiveTimeout: const Duration(seconds: 3),
            ),
          )
          .timeout(const Duration(seconds: 3));
      if (response.statusCode != null) {
        print('📡 NetworkInfo: API ping success (status: ${response.statusCode})');
        return true;
      }
    } catch (e) {
      print('📡 NetworkInfo: API ping failed: $e');
    }
    // Fallback : vérification internet classique
    print('📡 NetworkInfo: falling back to connection checker...');
    final result = await _connection.hasInternetAccess;
    print('📡 NetworkInfo: connection checker result = $result');
    return result;
  }
}

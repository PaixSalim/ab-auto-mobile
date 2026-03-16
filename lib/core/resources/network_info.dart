import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:auto/core/constants/constants.dart';
import 'package:dio/dio.dart';

class NetworkInfo {
  final InternetConnection _connection;
  const NetworkInfo(this._connection);

  Future<bool> get isConnected async {
    // Tente d'abord un ping direct vers le serveur API local
    try {
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
        print('[NetworkInfo] ✅ Serveur local accessible: ${response.statusCode}');
        return true;
      }
    } catch (e) {
      print('[NetworkInfo] ❌ Serveur local inaccessible: $e');
    }
    // Fallback : vérification internet classique
    final result = await _connection.hasInternetAccess;
    print('[NetworkInfo] 🌐 Internet classique: $result');
    return result;
  }
}

import 'package:dio/dio.dart';

class MyOrderRemoteDatasource {
  final Dio _dio;
  MyOrderRemoteDatasource(this._dio);

  Future<Response> getMyOrders() async {
    return await _dio.get(
      '/my-orders',
      options: Options(headers: {'Accept': 'application/json'}),
    );
  }
}

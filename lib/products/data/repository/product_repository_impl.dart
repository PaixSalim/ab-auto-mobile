import 'dart:io';

import 'package:auto/core/resources/data_state.dart';
import 'package:auto/core/resources/network_info.dart';
import 'package:auto/products/data/data_source/local/product_local_data_source.dart';
import 'package:auto/products/data/data_source/remote/product_remote_datasource_dio.dart';
import 'package:auto/products/data/models/product.model.dart';
import 'package:auto/products/domain/entities/order_entity.dart';
import 'package:auto/products/domain/repository/product_repository.dart';
import 'package:dio/dio.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDatasourceDio _remote;
  final ProductLocalDataSource _local;
  final NetworkInfo _networkInfo;
  final Dio _dio;
  ProductRepositoryImpl(this._remote, this._local, this._networkInfo, this._dio);
  @override
  Future<DataState<List<ProductModel>>> getProducts() async {
    if (await _networkInfo.isConnected) {
      try {
        final httpResponse = await _remote.getProducts();

        if (httpResponse.response.statusCode == HttpStatus.ok) {
          await _local.cacheProducts(httpResponse.data);
          return DataSuccess(httpResponse.data);
        } else {
          return DataFailed(
            DioException(
              error: httpResponse.response.statusMessage,
              type: DioExceptionType.badResponse,
              requestOptions: httpResponse.response.requestOptions,
            ),
          );
        }
      } on DioException catch (e) {
        return DataFailed(e);
      }
    } else {
      return DataSuccess(await _local.getProducts());
    }
  }

  @override
  Future<bool> sendOrder(OrderEntity order) async {
    try {
      final response = await _dio.post(
        '/order',
        data: order.toJson(),
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}

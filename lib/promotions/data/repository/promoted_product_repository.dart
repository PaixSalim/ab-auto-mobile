import 'dart:io';

import 'package:auto/core/resources/data_state.dart';
import 'package:auto/core/resources/network_info.dart';
import 'package:auto/promotions/data/data_source/remote/promotion_remote_datasource_dio.dart';
import 'package:auto/promotions/data/models/promoted_product_model.dart';
import 'package:auto/promotions/domain/repository/promoted_product_repository.dart';
import 'package:dio/dio.dart';

class PromotedProductRepositoryImpl implements PromotedProductRepository {
  final PromotionRemoteDatasourceDio _remote;
  final NetworkInfo _networkInfo;

  PromotedProductRepositoryImpl(this._remote, this._networkInfo);
  @override
  Future<DataState<List<PromotedProductModel>>> getPromotedProducts() async {
    if (await _networkInfo.isConnected) {
      try {
        final httpResponse = await _remote.getPromotions();

        if (httpResponse.response.statusCode == HttpStatus.ok) {
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
      return DataSuccess([]);
    }
  }
}

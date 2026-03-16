import 'dart:io';

import 'package:auto/brands/data/data_source/local/brand_local_datasource_objectbox.dart';
import 'package:auto/brands/data/data_source/remote/brand_remote_datasource_dio.dart';
import 'package:auto/brands/data/models/brand_model.dart';
import 'package:auto/brands/domain/repository/brand_repository.dart';
import 'package:auto/core/resources/data_state.dart';
import 'package:auto/core/resources/network_info.dart';
import 'package:dio/dio.dart';

class BrandRepositoryDioImpl implements BrandRepository {
  final BrandRemoteDatasourceDio _remote;
  final BrandLocalDataSource _local;
  final NetworkInfo _networkInfo;

  BrandRepositoryDioImpl(this._remote, this._local, this._networkInfo);
  @override
  Future<DataState<List<BrandModel>>> getBrands() async {
    if (await _networkInfo.isConnected) {
      try {
        final httpResponse = await _remote.getBrands();

        if (httpResponse.response.statusCode == HttpStatus.ok) {
          await _local.cacheBrands(httpResponse.data);
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
      return DataSuccess(await _local.getBrands());
    }
  }
}

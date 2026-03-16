import 'dart:io';

import 'package:auto/banners/data/data_source/local/banner_local_datasource_objectbox.dart';
import 'package:auto/banners/data/data_source/remote/banner_remote_datasource_dio.dart';
import 'package:auto/banners/data/models/banner_model.dart';
import 'package:auto/banners/domain/repository/banner_repository.dart';
import 'package:auto/core/resources/data_state.dart';
import 'package:auto/core/resources/network_info.dart';
import 'package:dio/dio.dart';

class BannerRepositoryImpl implements BannerRepository {
  final BannerRemoteDatasourceDio _remote;
  final BannerLocalDataSource _local;
  final NetworkInfo _networkInfo;

  BannerRepositoryImpl(this._remote, this._local, this._networkInfo);
  @override
  Future<DataState<List<BannerModel>>> getBanners() async {
    if (await _networkInfo.isConnected) {
      try {
        final httpResponse = await _remote.getBanners();

        if (httpResponse.response.statusCode == HttpStatus.ok) {
          await _local.cacheBanners(httpResponse.data);
          return DataSuccess(httpResponse.data);
        } else {
          return DataFailed(
            DioException(
              error: httpResponse.response.statusMessage,
              type: DioExceptionType.connectionError,
              requestOptions: httpResponse.response.requestOptions,
            ),
          );
        }
      } on DioException catch (e) {
        return DataFailed(e);
      }
    } else {
      return DataSuccess(await _local.getBanners());
    }
  }
}

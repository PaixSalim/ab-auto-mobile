import 'dart:io';

import 'package:auto/categories/data/data_source/local/category_local_datasource_objectbox.dart';
import 'package:auto/categories/data/data_source/remote/category_remote_datasource_dio.dart';
import 'package:auto/categories/data/models/category_model.dart';
import 'package:auto/categories/domain/repository/category_repository.dart';
import 'package:auto/core/resources/data_state.dart';
import 'package:auto/core/resources/network_info.dart';
import 'package:dio/dio.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryRemoteDataSourceDio _remoteDataSourceDio;
  final CategoryLocalDataSource _local;
  final NetworkInfo networkInfo;

  CategoryRepositoryImpl(
    this._remoteDataSourceDio,
    this._local,
    this.networkInfo,
  );
  @override
  Future<DataState<List<CategoryModel>>> getCategories() async {
    if (await networkInfo.isConnected) {
      try {
        final httpResponse = await _remoteDataSourceDio.getCategories();

        if (httpResponse.response.statusCode == HttpStatus.ok) {
          await _local.cacheCategories(httpResponse.data);
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
      return DataSuccess(await _local.getCategories());
    }
  }
}

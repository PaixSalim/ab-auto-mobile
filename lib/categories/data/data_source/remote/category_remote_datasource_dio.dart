import 'package:auto/categories/data/models/category_model.dart';
import 'package:auto/core/constants/constants.dart';
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'category_remote_datasource_dio.g.dart';

@RestApi(baseUrl: localAPIBaseUrl)
abstract class CategoryRemoteDataSourceDio {
  factory CategoryRemoteDataSourceDio(Dio dio) = _CategoryRemoteDataSourceDio;

  @GET('/categories')
  Future<HttpResponse<List<CategoryModel>>> getCategories();
}

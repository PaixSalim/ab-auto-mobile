import 'package:auto/brands/data/models/brand_model.dart';
import 'package:auto/core/constants/constants.dart';
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'brand_remote_datasource_dio.g.dart';

@RestApi(baseUrl: localAPIBaseUrl)
abstract class BrandRemoteDatasourceDio {
  factory BrandRemoteDatasourceDio(Dio dio) = _BrandRemoteDatasourceDio;

  @GET('/brands')
  Future<HttpResponse<List<BrandModel>>> getBrands();
}

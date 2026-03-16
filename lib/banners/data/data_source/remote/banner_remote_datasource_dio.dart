import 'package:auto/banners/data/models/banner_model.dart';
import 'package:auto/core/constants/constants.dart';
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'banner_remote_datasource_dio.g.dart';

@RestApi(baseUrl: localAPIBaseUrl)
abstract class BannerRemoteDatasourceDio {
  factory BannerRemoteDatasourceDio(Dio dio) = _BannerRemoteDatasourceDio;

  @GET('/banners')
  Future<HttpResponse<List<BannerModel>>> getBanners();
}

import 'package:auto/core/constants/constants.dart';
import 'package:auto/promotions/data/models/promoted_product_model.dart';
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'promotion_remote_datasource_dio.g.dart';

@RestApi(baseUrl: localAPIBaseUrl)
abstract class PromotionRemoteDatasourceDio {
  factory PromotionRemoteDatasourceDio(Dio dio) = _PromotionRemoteDatasourceDio;

  @GET('/promotions')
  Future<HttpResponse<List<PromotedProductModel>>> getPromotions();
}

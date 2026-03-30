import 'package:auto/core/constants/constants.dart';
import 'package:auto/products/data/models/product.model.dart';
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'product_remote_datasource_dio.g.dart';

@RestApi(baseUrl: localAPIBaseUrl)
abstract class ProductRemoteDatasourceDio {
  factory ProductRemoteDatasourceDio(Dio dio) = _ProductRemoteDatasourceDio;

  @GET('/products')
  Future<HttpResponse<List<ProductModel>>> getProducts();

  @GET('/products/{id}')
  Future<HttpResponse<ProductModel>> getProductById(@Path('id') int id);
}

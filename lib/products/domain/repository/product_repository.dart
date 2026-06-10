import 'package:auto/core/resources/data_state.dart';
import 'package:auto/products/domain/entities/model_entity.dart';
import 'package:auto/products/domain/entities/product_entity.dart';
import 'package:auto/products/domain/entities/year_entity.dart';
import 'package:auto/products/domain/entities/order_entity.dart';

abstract class ProductRepository {
  Future<DataState<List<ProductEntity>>> getProducts();
  Future<DataState<Map<String, dynamic>>> getProductsPaginated({int page, int limit});
  Future<DataState<ProductEntity>> getProductById(String id);
  Future<DataState<List<ModelEntity>>> getModels();
  Future<DataState<List<YearEntity>>> getYears();
  Future<bool> sendOrder(OrderEntity order);
}

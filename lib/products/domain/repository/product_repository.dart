import 'package:auto/core/resources/data_state.dart';
import 'package:auto/products/domain/entities/order_entity.dart';
import 'package:auto/products/domain/entities/product_entity.dart';

abstract class ProductRepository {
  Future<DataState<List<ProductEntity>>> getProducts();
  Future<bool> sendOrder(OrderEntity order);
}

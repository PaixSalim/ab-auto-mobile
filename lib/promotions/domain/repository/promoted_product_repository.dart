import 'package:auto/core/resources/data_state.dart';
import 'package:auto/promotions/domain/entity/promoted_poduct_entity.dart';

abstract class PromotedProductRepository {
  Future<DataState<List<PromotedProductEntity>>> getPromotedProducts();
}

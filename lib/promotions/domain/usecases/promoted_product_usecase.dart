import 'package:auto/core/resources/data_state.dart';
import 'package:auto/core/usecases/usecase.dart';
import 'package:auto/promotions/domain/entity/promoted_poduct_entity.dart';
import 'package:auto/promotions/domain/repository/promoted_product_repository.dart';

class GetPromotedProductUseCase
    implements Usecase<DataState<List<PromotedProductEntity>>, void> {
  final PromotedProductRepository _promotedProductRepository;
  const GetPromotedProductUseCase(this._promotedProductRepository);

  @override
  Future<DataState<List<PromotedProductEntity>>> call({void params}) {
    return _promotedProductRepository.getPromotedProducts();
  }
}

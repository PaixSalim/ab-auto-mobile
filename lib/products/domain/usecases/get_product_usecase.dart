import 'package:auto/core/resources/data_state.dart';
import 'package:auto/core/usecases/usecase.dart';
import 'package:auto/products/domain/entities/product_entity.dart';
import 'package:auto/products/domain/repository/product_repository.dart';

class GetProductUseCase
    implements Usecase<DataState<List<ProductEntity>>, void> {
  final ProductRepository _productRepository;
  const GetProductUseCase(this._productRepository);

  @override
  Future<DataState<List<ProductEntity>>> call({void params}) {
    return _productRepository.getProducts();
  }
}

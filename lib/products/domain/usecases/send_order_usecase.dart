import 'package:auto/core/usecases/usecase.dart';
import 'package:auto/products/domain/repository/product_repository.dart';

class SendOrderUseCase extends Usecase {
  final ProductRepository _productRepository;

  SendOrderUseCase(this._productRepository);
  @override
  Future<bool> call({params}) {
    return _productRepository.sendOrder(params);
  }
}

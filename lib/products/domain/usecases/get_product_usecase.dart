import 'package:auto/core/resources/data_state.dart';
import 'package:auto/core/usecases/usecase.dart';
import 'package:auto/products/domain/entities/model_entity.dart';
import 'package:auto/products/domain/entities/product_entity.dart';
import 'package:auto/products/domain/repository/product_repository.dart';
import 'package:auto/products/domain/entities/year_entity.dart';

class GetProductUseCase
    implements Usecase<DataState<List<ProductEntity>>, void> {
  final ProductRepository _productRepository;
  const GetProductUseCase(this._productRepository);

  @override
  Future<DataState<List<ProductEntity>>> call({void params}) {
    return _productRepository.getProducts();
  }
}

class GetProductByIdUseCase
    implements Usecase<DataState<ProductEntity>, String> {
  final ProductRepository _productRepository;
  const GetProductByIdUseCase(this._productRepository);

  @override
  Future<DataState<ProductEntity>> call({String? params}) {
    return _productRepository.getProductById(params!);
  }
}

class GetProductsPaginatedUseCase
    implements Usecase<DataState<Map<String, dynamic>>, Map<String, int>> {
  final ProductRepository _productRepository;
  const GetProductsPaginatedUseCase(this._productRepository);

  @override
  Future<DataState<Map<String, dynamic>>> call({Map<String, int>? params}) {
    final page = params?['page'] ?? 1;
    final limit = params?['limit'] ?? 20;
    return _productRepository.getProductsPaginated(page: page, limit: limit);
  }
}

class GetModelsUseCase implements Usecase<DataState<List<ModelEntity>>, void> {
  final ProductRepository _productRepository;
  const GetModelsUseCase(this._productRepository);

  @override
  Future<DataState<List<ModelEntity>>> call({void params}) {
    return _productRepository.getModels();
  }
}

class GetYearsUseCase implements Usecase<DataState<List<YearEntity>>, void> {
  final ProductRepository _productRepository;
  const GetYearsUseCase(this._productRepository);

  @override
  Future<DataState<List<YearEntity>>> call({void params}) {
    return _productRepository.getYears();
  }
}

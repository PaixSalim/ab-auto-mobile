import 'package:auto/brands/domain/entities/brand_entity.dart';
import 'package:auto/brands/domain/repository/brand_repository.dart';
import 'package:auto/core/resources/data_state.dart';
import 'package:auto/core/usecases/usecase.dart';

class GetBrandUseCase implements Usecase<DataState<List<BrandEntity>>, void> {
  final BrandRepository _brandRepository;
  const GetBrandUseCase(this._brandRepository);
  @override
  Future<DataState<List<BrandEntity>>> call({void params}) {
    return _brandRepository.getBrands();
  }
}

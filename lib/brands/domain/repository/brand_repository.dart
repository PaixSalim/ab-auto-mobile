import 'package:auto/brands/domain/entities/brand_entity.dart';
import 'package:auto/core/resources/data_state.dart';

abstract class BrandRepository {
  Future<DataState<List<BrandEntity>>> getBrands();
}

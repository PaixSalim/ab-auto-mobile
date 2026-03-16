import 'package:auto/categories/domain/entities/category_entity.dart';
import 'package:auto/categories/domain/repository/category_repository.dart';
import 'package:auto/core/resources/data_state.dart';
import 'package:auto/core/usecases/usecase.dart' show Usecase;

class GetCategoryUseCase
    implements Usecase<DataState<List<CategoryEntity>>, void> {
  final CategoryRepository _categoryRepository;
  GetCategoryUseCase(this._categoryRepository);

  @override
  Future<DataState<List<CategoryEntity>>> call({void params}) {
    return _categoryRepository.getCategories();
  }
}

import 'package:auto/categories/domain/entities/category_entity.dart';
import 'package:auto/core/resources/data_state.dart';

abstract class CategoryRepository {
  Future<DataState<List<CategoryEntity>>> getCategories();
}

import 'package:auto/app_database.dart';
import 'package:auto/categories/data/models/category_converter.dart';
import 'package:auto/categories/data/models/category_model.dart';
import 'package:auto/categories/domain/entities/category_entity.dart';

class CategoryLocalDataSource {
  final ObjectBoxService _objectBox;

  CategoryLocalDataSource(this._objectBox);

  Future<void> cacheCategories(List<CategoryEntity> categories) async {
    final box = _objectBox.box<CategoryObjectBox>();
    box.removeAll();
    box.putMany(categories.map((e) => CategoryObjectBox.fromModel(e)).toList());
  }

  Future<List<CategoryModel>> getCategories() async {
    final box = _objectBox.box<CategoryObjectBox>();
    return box.getAll().map((e) => e.toModel()).toList();
  }
}

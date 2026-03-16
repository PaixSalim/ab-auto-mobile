import 'package:auto/app_database.dart';
import 'package:auto/brands/data/models/brand_converter.dart';
import 'package:auto/brands/data/models/brand_model.dart';
import 'package:auto/brands/domain/entities/brand_entity.dart';

class BrandLocalDataSource {
  final ObjectBoxService _objectBox;

  BrandLocalDataSource(this._objectBox);

  Future<void> cacheBrands(List<BrandEntity> brands) async {
    final box = _objectBox.box<BrandObjectBox>();
    box.removeAll();
    box.putMany(brands.map((e) => BrandObjectBox.fromModel(e)).toList());
  }

  Future<List<BrandModel>> getBrands() async {
    final box = _objectBox.box<BrandObjectBox>();
    return box.getAll().map((e) => e.toModel()).toList();
  }
}

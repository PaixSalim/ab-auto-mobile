import 'package:auto/app_database.dart';
import 'package:auto/products/data/models/product.model.dart';
import 'package:auto/products/data/models/product_converter.dart';
import 'package:auto/products/domain/entities/product_entity.dart';

class ProductLocalDataSource {
  final ObjectBoxService _objectBox;

  ProductLocalDataSource(this._objectBox);

  Future<void> cacheProducts(List<ProductEntity> products) async {
    final box = _objectBox.box<ProductObjectBox>();
    box.removeAll();
    box.putMany(products.map((e) => ProductObjectBox.fromModel(e)).toList());
  }

  Future<List<ProductModel>> getProducts() async {
    final box = _objectBox.box<ProductObjectBox>();
    return box.getAll().map((e) => e.toModel()).toList();
  }
}

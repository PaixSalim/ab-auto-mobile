import 'package:auto/banners/data/models/banner_converter.dart';
import 'package:auto/chatbot/data/models/chat_message_converter.dart';
import 'package:auto/products/data/models/product_converter.dart';

import 'brands/data/models/brand_converter.dart';
import 'categories/data/models/category_converter.dart';
import 'objectbox.g.dart';

class ObjectBoxService {
  static late final Store _store;

  static Future<void> init() async {
    _store = await openStore();
  }

  static Store get store {
    return _store;
  }

  Box<T> box<T>() {
    if (T == ProductObjectBox) return store.box<ProductObjectBox>() as Box<T>;
    if (T == BrandObjectBox) return store.box<BrandObjectBox>() as Box<T>;
    if (T == CategoryObjectBox) return store.box<CategoryObjectBox>() as Box<T>;
    if (T == BannerObjectBox) return store.box<BannerObjectBox>() as Box<T>;
    if (T == ChatObjectBox) return store.box<ChatObjectBox>() as Box<T>;
    throw Exception('Unsupported box type: $T');
  }
}

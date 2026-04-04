import 'dart:io';
import 'package:auto/banners/data/models/banner_converter.dart';
import 'package:auto/chatbot/data/models/chat_message_converter.dart';
import 'package:auto/products/data/models/product_converter.dart';

import 'brands/data/models/brand_converter.dart';
import 'categories/data/models/category_converter.dart';
import 'objectbox.g.dart';

class ObjectBoxService {
  static late final Store _store;

  static Future<void> init() async {
    try {
      print('Attempting to open ObjectBox store...');
      _store = await openStore();
      print('ObjectBox store opened successfully');
    } catch (e) {
      print('Error opening store: $e');
      // If schema mismatch, delete old database and recreate
      if (e.toString().contains('not compatible')) {
        print('Schema incompatibility detected, deleting old database...');
        try {
          // Try multiple common database locations
          final possiblePaths = [
            Directory.current.path + '/objectbox',
            Directory.systemTemp.path + '/objectbox',
            Directory.current.path + '/data/objectbox',
          ];
          
          bool deleted = false;
          for (final path in possiblePaths) {
            final dbDir = Directory(path);
            print('Checking database path: ${dbDir.path}');
            
            if (await dbDir.exists()) {
              print('Database directory exists, deleting...');
              await dbDir.delete(recursive: true);
              print('Database directory deleted');
              deleted = true;
              break;
            }
          }
          
          if (!deleted) {
            print('No database directory found to delete');
          }
          
          // Try to open again with new schema
          print('Attempting to open store with new schema...');
          _store = await openStore();
          print('Store opened with new schema successfully');
        } catch (deleteError) {
          print('Error during database deletion/recreation: $deleteError');
          rethrow;
        }
      } else {
        print('Different error, rethrowing...');
        rethrow;
      }
    }
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

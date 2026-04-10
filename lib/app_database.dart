import 'dart:io';
import 'package:auto/banners/data/models/banner_converter.dart';
import 'package:auto/chatbot/data/models/chat_message_converter.dart';
import 'package:auto/products/data/models/product_converter.dart';
import 'package:auto/notifications/data/models/notification_model.dart';

import 'brands/data/models/brand_converter.dart';
import 'categories/data/models/category_converter.dart';
import 'objectbox.g.dart';

class ObjectBoxService {
  static bool _initialized = false;
  static Store? _storeInstance;

  static Future<void> init() async {
    if (_initialized) return;
    try {
      print('Attempting to open ObjectBox store...');
      _storeInstance = await openStore();
      _initialized = true;
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
          _storeInstance = await openStore();
          _initialized = true;
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
    if (_storeInstance == null) throw Exception('ObjectBox store not initialized');
    return _storeInstance!;
  }

  Box<T> box<T>() {
    if (T == ProductObjectBox) return store.box<ProductObjectBox>() as Box<T>;
    if (T == BrandObjectBox) return store.box<BrandObjectBox>() as Box<T>;
    if (T == CategoryObjectBox) return store.box<CategoryObjectBox>() as Box<T>;
    if (T == BannerObjectBox) return store.box<BannerObjectBox>() as Box<T>;
    if (T == ChatObjectBox) return store.box<ChatObjectBox>() as Box<T>;
    if (T == NotificationObjectBox) return store.box<NotificationObjectBox>() as Box<T>;
    throw Exception('Unsupported box type: $T');
  }
}

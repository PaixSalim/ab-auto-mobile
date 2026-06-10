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
            _storeInstance = await openStore();
      _initialized = true;
          } catch (e) {
            // If schema mismatch, delete old database and recreate
      if (e.toString().contains('not compatible')) {
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
                        
            if (await dbDir.exists()) {
                            await dbDir.delete(recursive: true);
                            deleted = true;
              break;
            }
          }
          
          if (!deleted) {
                      }
          
          // Try to open again with new schema
                    _storeInstance = await openStore();
          _initialized = true;
                  } catch (deleteError) {
                    rethrow;
        }
      } else {
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

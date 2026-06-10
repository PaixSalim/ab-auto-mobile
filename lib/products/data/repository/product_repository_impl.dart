import 'dart:io';

import 'package:auto/core/resources/data_state.dart';
import 'package:auto/core/resources/network_info.dart';
import 'package:auto/products/data/data_source/local/product_local_data_source.dart';
import 'package:auto/products/data/data_source/remote/product_remote_datasource_dio.dart';
import 'package:auto/products/data/models/product.model.dart';
import 'package:auto/products/domain/entities/product_entity.dart';
import 'package:auto/products/domain/entities/order_entity.dart';
import 'package:auto/products/domain/repository/product_repository.dart';
import 'package:dio/dio.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDatasourceDio _remote;
  final ProductLocalDataSource _local;
  final NetworkInfo _networkInfo;
  final Dio _dio;
  ProductRepositoryImpl(this._remote, this._local, this._networkInfo, this._dio);
  @override
  Future<DataState<List<ProductEntity>>> getProducts() async {
    print('🔄 getProducts() called');
    if (await _networkInfo.isConnected) {
      try {
        // Récupérer la liste des produits
        final httpResponse = await _remote.getProducts();
        
        if (httpResponse.response.statusCode == HttpStatus.ok) {
          final productModels = httpResponse.data as List<dynamic>;
          print('🚀 getProducts: Received ${productModels.length} products from remote');
                    
          // Les données sont déjà des ProductModel (converties par Retrofit)
          // Il faut juste les convertir en ProductEntity
          final products = <ProductEntity>[];
          
          for (int i = 0; i < productModels.length; i++) {
            try {
                            final model = productModels[i] as ProductModel;  // Changé ici
                            
              final entity = ProductEntity(
                id: model.id,
                name: model.name ?? '',
                slug: model.slug ?? '',
                cta: model.cta ?? '',
                warranty: model.warranty ?? '',
                state: model.state ?? '',
                description: model.description ?? '',
                price: model.price,
                discount: model.discount,
                category: model.category,
                features: model.features,
                brand: model.brand,
                medias: model.medias,
                seller: model.seller,
                sellerId: model.sellerId,
              );
                            products.add(entity);
            } catch (e, stackTrace) {
              print('❌ getProducts: Error parsing product: $e\n$stackTrace');
            }
          }
          
                    
          // Pour l'instant, utilisons les produits sans détails supplémentaires
          // pour vérifier si l'affichage fonctionne
                    await _local.cacheProducts(products);
          return DataSuccess(products);
        } else {
          print('⚠️ getProducts: API returned status ${httpResponse.response.statusCode}');
          return DataFailed(
            DioException(
              error: httpResponse.response.statusMessage,
              type: DioExceptionType.badResponse,
              requestOptions: httpResponse.response.requestOptions,
            ),
          );
        }
      } on DioException catch (e) {
        print('❌ getProducts: DioException: ${e.message}');
        return DataFailed(e);
      }
    } else {
      print('⚠️ getProducts: No internet connection. Fetching from local cache.');
      return DataSuccess(await _local.getProducts());
    }
  }

  @override
  Future<DataState<Map<String, dynamic>>> getProductsPaginated({
    int page = 1,
    int limit = 20,
  }) async {
    print('🔄 getProductsPaginated() called (page: $page, limit: $limit)');
    bool isConnected = await _networkInfo.isConnected;
    print('📡 getProductsPaginated: isConnected=$isConnected');
    if (isConnected) {
      try {
        print('🌐 getProductsPaginated: starting API request...');
                final response = await _dio.get(
          '/products',
          queryParameters: {'page': page, 'limit': limit},
        );

                
        if (response.statusCode == HttpStatus.ok) {
          List<dynamic> productModels = [];
          Map<String, dynamic>? paginationInfo;
          
          if (response.data is List) {
            productModels = response.data as List<dynamic>;
          } else if (response.data is Map<String, dynamic>) {
            final responseData = response.data as Map<String, dynamic>;
            if (responseData.containsKey('data')) {
              productModels = responseData['data'] as List<dynamic>;
            } else {
              productModels = responseData.values.firstWhere((v) => v is List, orElse: () => []) as List<dynamic>;
            }
            paginationInfo = responseData;
          }
          print('🚀 getProductsPaginated: Received ${productModels.length} products from remote (page: $page, limit: $limit)');
          final products = <ProductEntity>[];
          
          for (int i = 0; i < productModels.length; i++) {
            try {
              final json = productModels[i] as Map<String, dynamic>;
                            
              final model = ProductModel.fromJson(json);
                            
              final entity = ProductEntity(
                id: model.id,
                name: model.name ?? '',
                slug: model.slug ?? '',
                cta: model.cta ?? '',
                warranty: model.warranty ?? '',
                state: model.state ?? '',
                description: model.description ?? '',
                price: model.price,
                discount: model.discount,
                category: model.category,
                subCategory: model.subCategory,
                subCategoryId: model.subCategoryId,
                features: model.features,
                brand: model.brand,
                medias: model.medias,
                seller: model.seller,
                sellerId: model.sellerId,
                validationStatus: model.validationStatus,
              );
                            products.add(entity);
            } catch (e, stackTrace) {
              print('❌ getProductsPaginated: Error parsing product: $e\n$stackTrace');
            }
          }
          
                    
          // Retourner les produits avec les métadonnées de pagination
          return DataSuccess({
            'products': products,
            'total': paginationInfo?['total'] ?? products.length,
            'page': paginationInfo?['page'] ?? 1,
            'limit': paginationInfo?['limit'] ?? products.length,
            'totalPages': paginationInfo?['totalPages'] ?? 1,
            'hasNextPage': paginationInfo?['hasNextPage'] ?? false,
            'hasPreviousPage': paginationInfo?['hasPreviousPage'] ?? false,
          });
        } else {
          print('⚠️ getProductsPaginated: API returned status ${response.statusCode}');
          return DataFailed(
            DioException(
              error: response.statusMessage,
              type: DioExceptionType.badResponse,
              requestOptions: response.requestOptions,
            ),
          );
        }
      } on DioException catch (e) {
        print('❌ getProductsPaginated: DioException: ${e.message}');
        return DataFailed(e);
      }
    } else {
      print('⚠️ getProductsPaginated: No internet connection.');
      return DataFailed(
        DioException(
          error: 'No internet connection',
          type: DioExceptionType.unknown,
          requestOptions: RequestOptions(path: '/products'),
        ),
      );
    }
  }

  @override
  Future<DataState<ProductEntity>> getProductById(String id) async {
    if (await _networkInfo.isConnected) {
      try {
        final httpResponse = await _remote.getProductById(id);

        if (httpResponse.response.statusCode == HttpStatus.ok) {
          return DataSuccess(httpResponse.data);
        } else {
          return DataFailed(
            DioException(
              error: httpResponse.response.statusMessage,
              type: DioExceptionType.badResponse,
              requestOptions: httpResponse.response.requestOptions,
            ),
          );
        }
      } on DioException catch (e) {
        return DataFailed(e);
      }
    } else {
      // Pour le mode hors ligne, on pourrait chercher dans le cache local
      return DataFailed(
        DioException(
          error: 'No internet connection and no cached data available',
          type: DioExceptionType.unknown,
          requestOptions: RequestOptions(path: '/products/$id'),
        ),
      );
    }
  }

  @override
  Future<bool> sendOrder(OrderEntity order) async {
    try {
      final response = await _dio.post(
        '/order',
        data: order.toJson(),
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}

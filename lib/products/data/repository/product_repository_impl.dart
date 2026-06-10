import 'package:auto/core/resources/data_state.dart';
import 'package:auto/core/resources/network_info.dart';
import 'package:auto/products/data/data_source/local/product_local_data_source.dart';
import 'package:auto/products/data/data_source/remote/product_remote_datasource_dio.dart';
import 'package:auto/products/data/models/product.model.dart';
import 'package:auto/products/domain/entities/model_entity.dart';
import 'package:auto/products/domain/entities/product_entity.dart';
import 'package:auto/products/domain/entities/year_entity.dart';
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
        final httpResponse = await _remote.getProducts();
        
        if (httpResponse.response.statusCode == 200) {
          final productModels = httpResponse.data as List<dynamic>;
          print('🚀 getProducts: Received ${productModels.length} products from remote');
                    
          final products = <ProductEntity>[];
          
          for (int i = 0; i < productModels.length; i++) {
            try {
                            final model = productModels[i] as ProductModel;
                             
              final entity = ProductEntity(
                id: model.id,
                name: model.name ?? '',
                slug: model.slug ?? '',
                cta: model.cta ?? '',
                warranty: model.warranty ?? '',
                state: model.state ?? '',
                description: model.description ?? '',
                model: model.model,
                year: model.year,
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

                
        if (response.statusCode == 200) {
          final responseData = response.data;

          List<dynamic> productModels = [];
          if (responseData is List) {
            productModels = responseData;
          } else if (responseData is Map<String, dynamic>) {
            if (responseData.containsKey('data') && responseData['data'] is List) {
              productModels = responseData['data'];
            } else if (responseData.containsKey('products') && responseData['products'] is List) {
              productModels = responseData['products'];
            } else {
              final listValue = responseData.values.firstWhere((v) => v is List, orElse: () => []);
              productModels = listValue as List<dynamic>;
            }
          }

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
                model: model.model,
                year: model.year,
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

          return DataSuccess({
            'products': products,
            'total': (responseData is Map<String, dynamic>) ? (responseData['total'] ?? products.length) : products.length,
            'page': (responseData is Map<String, dynamic>) ? (responseData['page'] ?? page) : page,
            'limit': (responseData is Map<String, dynamic>) ? (responseData['limit'] ?? limit) : limit,
            'totalPages': (responseData is Map<String, dynamic>) ? (responseData['totalPages'] ?? 1) : 1,
            'hasNextPage': (responseData is Map<String, dynamic>) ? (responseData['hasNextPage'] ?? false) : false,
            'hasPreviousPage': (responseData is Map<String, dynamic>) ? (responseData['hasPreviousPage'] ?? false) : false,
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

        if (httpResponse.response.statusCode == 200) {
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

  @override
  Future<DataState<List<ModelEntity>>> getModels() async {
    try {
      final response = await _dio.get('/models');
      if (response.statusCode == 200) {
        final items = (response.data as List).map((e) => ModelEntity(id: e['id']?.toString(), name: e['name'] as String?)).toList();
        return DataSuccess(items);
      }
      return DataFailed(DioException(error: response.statusMessage, type: DioExceptionType.badResponse, requestOptions: response.requestOptions));
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<List<YearEntity>>> getYears() async {
    try {
      final response = await _dio.get('/years');
      if (response.statusCode == 200) {
        final items = (response.data as List).map((e) => YearEntity(id: e['id']?.toString(), name: e['name'] as String?)).toList();
        return DataSuccess(items);
      }
      return DataFailed(DioException(error: response.statusMessage, type: DioExceptionType.badResponse, requestOptions: response.requestOptions));
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }
}

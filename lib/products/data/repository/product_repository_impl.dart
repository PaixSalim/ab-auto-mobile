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
    if (await _networkInfo.isConnected) {
      try {
        // Récupérer la liste des produits
        final httpResponse = await _remote.getProducts();
        
        if (httpResponse.response.statusCode == HttpStatus.ok) {
          final productModels = httpResponse.data as List<dynamic>;
          print('Received ${productModels.length} products from API');
          
          // Les données sont déjà des ProductModel (converties par Retrofit)
          // Il faut juste les convertir en ProductEntity
          final products = <ProductEntity>[];
          
          for (int i = 0; i < productModels.length; i++) {
            try {
              print('Converting product $i...');
              final model = productModels[i] as ProductModel;  // Changé ici
              print('ProductModel received for: ${model.name}');
              
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
              print('ProductEntity created for: ${entity.name}');
              products.add(entity);
            } catch (e) {
              print('Error converting product $i: $e');
              print('Product data: ${productModels[i]}');
            }
          }
          
          print('Converted ${products.length} products to ProductEntity');
          
          // Pour l'instant, utilisons les produits sans détails supplémentaires
          // pour vérifier si l'affichage fonctionne
          print('Using products without seller details for now');
          await _local.cacheProducts(products);
          return DataSuccess(products);
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
      return DataSuccess(await _local.getProducts());
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

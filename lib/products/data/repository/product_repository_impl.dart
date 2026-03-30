import 'dart:io';

import 'package:auto/core/resources/data_state.dart';
import 'package:auto/core/resources/network_info.dart';
import 'package:auto/products/data/data_source/local/product_local_data_source.dart';
import 'package:auto/products/data/data_source/remote/product_remote_datasource_dio.dart';
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
          final products = httpResponse.data as List<ProductEntity>;
          
          // Pour chaque produit, récupérer les détails complets qui incluent le seller
          final productsWithSeller = <ProductEntity>[];
          
          for (final product in products) {
            if (product.id != null) {
              try {
                // Récupérer les détails complets du produit (avec seller)
                final detailResponse = await _remote.getProductById(product.id!);
                if (detailResponse.response.statusCode == HttpStatus.ok) {
                  // L'API retourne maintenant le seller complet !
                  productsWithSeller.add(detailResponse.data);
                } else {
                  productsWithSeller.add(product);
                }
              } catch (e) {
                // Si erreur, utiliser le produit sans seller
                productsWithSeller.add(product);
              }
            } else {
              productsWithSeller.add(product);
            }
          }
          
          await _local.cacheProducts(productsWithSeller);
          return DataSuccess(productsWithSeller);
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
  Future<DataState<ProductEntity>> getProductById(int id) async {
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

import 'package:auto/core/constants/constants.dart' show localAPIBaseUrl;
import 'package:auto/core/resources/data_state.dart';
import 'package:auto/orders/data/datasource/my_order_remote_datasource.dart';
import 'package:auto/orders/domain/entities/my_order_entity.dart';
import 'package:auto/orders/domain/repository/my_order_repository.dart';
import 'package:dio/dio.dart';

class MyOrderRepositoryImpl implements MyOrderRepository {
  final MyOrderRemoteDatasource _datasource;
  MyOrderRepositoryImpl(this._datasource);

  @override
  Future<DataState<List<MyOrderEntity>>> getMyOrders() async {
    try {
      final response = await _datasource.getMyOrders();
      
      // Debug: Afficher la réponse brute du backend
                        
      if (response.statusCode == 200) {
        final raw = response.data;
        final List data = raw is List ? raw : (raw['data'] ?? raw['orders'] ?? []) as List;
                        
        final orders = data
            .whereType<Map<String, dynamic>>()
            .map((e) => _fromJson(e))
            .toList();
                return DataSuccess(orders);
      }
      return DataFailed(
        DioException(
          requestOptions: RequestOptions(path: '$localAPIBaseUrl/my-orders'),
          message: 'Erreur lors du chargement des commandes',
        ),
      );
    } on DioException catch (e) {
                  return DataFailed(e);
    } catch (e) {
            return DataFailed(
        DioException(
          requestOptions: RequestOptions(path: '$localAPIBaseUrl/my-orders'),
          message: e.toString(),
        ),
      );
    }
  }

  double _parsePrice(dynamic price) {
    if (price == null) return 0.0;
    if (price is num) return price.toDouble();
    if (price is String) {
      return double.tryParse(price) ?? 0.0;
    }
    return 0.0;
  }

  MyOrderEntity _fromJson(Map<String, dynamic> json) {
    try {
      // Debug: Afficher les données brutes reçues
            
      final product = json['product'] as Map<String, dynamic>? ?? {};
            
      final medias = product['medias'] as List?;
            
      String imageUrl = '';
      if (medias != null && medias.isNotEmpty) {
        final first = medias[0];
        final raw = first is Map ? (first['url'] ?? '').toString() : first.toString();
        imageUrl = raw.startsWith('http') ? raw : '$localAPIBaseUrl$raw';
      }
            
      final orderEntity = MyOrderEntity(
        id: json['id'] ?? 0,
        productName: product['name']?.toString() ?? 'Produit',
        productImage: imageUrl,
        quantity: json['quantity'] ?? 1,
        status: json['status']?.toString() ?? 'pending',
        city: json['city']?.toString() ?? '',
        phoneNumber: (json['phone_number'] ?? json['phoneNumber'] ?? '').toString(),
        createdAt: (json['created_at'] ?? json['createdAt'] ?? '').toString(),
        customerName: (json['customer_name'] ?? json['customerName'] ?? '').toString(),
        price: _parsePrice(product['price']),
        productPrice: _parsePrice(product['price']),
      );
      
            return orderEntity;
    } catch (e) {
            return MyOrderEntity(
        id: json['id'] ?? 0,
        productName: 'Produit',
        productImage: '',
        quantity: 1,
        status: 'pending',
        city: '',
        phoneNumber: '',
        createdAt: '',
        customerName: '',
        price: 0.0,
        productPrice: 0.0,
      );
    }
  }
}

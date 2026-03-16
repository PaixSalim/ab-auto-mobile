import 'package:auto/orders/domain/entities/my_order_entity.dart';
import 'package:auto/core/resources/data_state.dart';

abstract class MyOrderRepository {
  Future<DataState<List<MyOrderEntity>>> getMyOrders();
}

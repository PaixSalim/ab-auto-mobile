import 'package:auto/orders/domain/entities/my_order_entity.dart';
import 'package:auto/orders/domain/repository/my_order_repository.dart';
import 'package:auto/core/resources/data_state.dart';

class GetMyOrdersUseCase {
  final MyOrderRepository _repository;
  GetMyOrdersUseCase(this._repository);

  Future<DataState<List<MyOrderEntity>>> call() => _repository.getMyOrders();
}

part of 'my_orders_bloc.dart';

abstract class MyOrdersEvent {
  const MyOrdersEvent();
}

class FetchMyOrders extends MyOrdersEvent {
  const FetchMyOrders();
}

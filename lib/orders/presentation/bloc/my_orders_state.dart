part of 'my_orders_bloc.dart';

abstract class MyOrdersState {
  const MyOrdersState();
}

class MyOrdersInitial extends MyOrdersState {}

class MyOrdersLoading extends MyOrdersState {}

class MyOrdersLoaded extends MyOrdersState {
  final List<MyOrderEntity> orders;
  const MyOrdersLoaded(this.orders);
}

class MyOrdersError extends MyOrdersState {
  final String message;
  const MyOrdersError(this.message);
}

part of 'remote_order_bloc.dart';

abstract class RemoteOrderEvent {
  const RemoteOrderEvent();
}

class SendOrder extends RemoteOrderEvent {
  final OrderEntity order;
  const SendOrder(this.order);
}

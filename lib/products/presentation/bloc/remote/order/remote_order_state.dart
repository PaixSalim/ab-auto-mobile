part of 'remote_order_bloc.dart';

sealed class RemoteOrderState {
  final bool? orderSent;
  const RemoteOrderState({this.orderSent});

  bool? get orderSentSuccess => orderSent;
}

class RemoteOrderInitial extends RemoteOrderState {
  const RemoteOrderInitial();
}

class RemoteOrderSent extends RemoteOrderState {
  const RemoteOrderSent(bool orderSent) : super(orderSent: orderSent);
}

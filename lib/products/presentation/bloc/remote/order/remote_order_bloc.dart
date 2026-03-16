import 'package:auto/products/domain/entities/order_entity.dart';
import 'package:auto/products/domain/usecases/send_order_usecase.dart';
import 'package:bloc/bloc.dart';

part 'remote_order_event.dart';
part 'remote_order_state.dart';

class RemoteOrderBloc extends Bloc<RemoteOrderEvent, RemoteOrderState> {
  final SendOrderUseCase _sendOrderUseCase;

  RemoteOrderBloc(this._sendOrderUseCase) : super(RemoteOrderInitial()) {
    on<SendOrder>(_onSendOrder);
  }

  Future<bool> _onSendOrder(
    SendOrder event,
    Emitter<RemoteOrderState> emit,
  ) async {
    final OrderEntity order = event.order;
    final bool result = await _sendOrderUseCase(params: order);
    emit(RemoteOrderSent(result));
    if (result) {
      return result;
    } else {
      return !result;
    }
  }
}

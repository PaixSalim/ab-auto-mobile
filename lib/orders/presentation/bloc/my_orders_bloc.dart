import 'package:auto/core/resources/data_state.dart';
import 'package:auto/orders/domain/entities/my_order_entity.dart';
import 'package:auto/orders/domain/usecases/get_my_orders_usecase.dart';
import 'package:bloc/bloc.dart';

part 'my_orders_event.dart';
part 'my_orders_state.dart';

class MyOrdersBloc extends Bloc<MyOrdersEvent, MyOrdersState> {
  final GetMyOrdersUseCase _getMyOrdersUseCase;

  MyOrdersBloc(this._getMyOrdersUseCase) : super(MyOrdersInitial()) {
    on<FetchMyOrders>(_onFetch);
  }

  Future<void> _onFetch(FetchMyOrders event, Emitter<MyOrdersState> emit) async {
    emit(MyOrdersLoading());
    final result = await _getMyOrdersUseCase();
    if (result is DataSuccess<List<MyOrderEntity>>) {
      emit(MyOrdersLoaded(result.data!));
    } else {
      emit(MyOrdersError(result.error?.message ?? 'Erreur lors du chargement'));
    }
  }
}

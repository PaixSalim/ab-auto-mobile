import 'package:auto/core/resources/data_state.dart';
import 'package:auto/promotions/domain/entity/promoted_poduct_entity.dart';
import 'package:auto/promotions/domain/usecases/promoted_product_usecase.dart';
import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';

part 'remote_promoted_product_event.dart';
part 'remote_promoted_product_state.dart';

class RemotePromotedProductBloc
    extends Bloc<RemotePromotedProductEvent, RemotePromotedProductState> {
  final GetPromotedProductUseCase _promotedProductUseCase;
  RemotePromotedProductBloc(this._promotedProductUseCase)
    : super(RemotePromotedProductLoading()) {
    on<GetPromotedProduct>(onGetPromotedProduct);
  }
  Future<void> onGetPromotedProduct(
    GetPromotedProduct event,
    Emitter<RemotePromotedProductState> emit,
  ) async {
    final dataState = await _promotedProductUseCase();
    if (dataState is DataSuccess && dataState.data!.isNotEmpty) {
      emit(RemotePromotedProductDone(dataState.data!));
    }
    if (dataState is DataFailed) {
      emit(RemotePromotedProductError(dataState.error!));
    }
  }
}

import 'package:auto/brands/domain/entities/brand_entity.dart';
import 'package:auto/brands/domain/usecases/get_brand_usecase.dart';
import 'package:auto/core/resources/data_state.dart';
import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';

part 'remote_brand_event.dart';
part 'remote_brand_state.dart';

class RemoteBrandBloc extends Bloc<RemoteBrandEvent, RemoteBrandState> {
  final GetBrandUseCase _getBrandUseCase;
  RemoteBrandBloc(this._getBrandUseCase) : super(RemoteBrandLoading()) {
    on<RemoteBrandEvent>(onGetBrands);
  }

  Future<void> onGetBrands(
    RemoteBrandEvent event,
    Emitter<RemoteBrandState> emit,
  ) async {
    final dataState = await _getBrandUseCase();
    if (dataState is DataSuccess && dataState.data!.isNotEmpty) {
      emit(RemoteBrandDone(dataState.data!));
    }
    if (dataState is DataFailed) {
      emit(RemoteBrandError(dataState.error!));
    }
  }
}

import 'package:auto/banners/domain/entity/banner_entity.dart';
import 'package:auto/banners/domain/usecases/get_banners_usecase.dart';
import 'package:auto/core/resources/data_state.dart';
import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';

part 'remote_banner_event.dart';
part 'remote_banner_state.dart';

class RemoteBannerBloc extends Bloc<RemoteBannerEvent, RemoteBannerState> {
  final GetBannerUseCase _getBannerUseCase;
  RemoteBannerBloc(this._getBannerUseCase) : super(RemoteBannerLoading()) {
    on<GetBanner>(_onGetBanner);
  }
  Future<void> _onGetBanner(
    GetBanner event,
    Emitter<RemoteBannerState> emit,
  ) async {
    final dataState = await _getBannerUseCase();
    if (dataState is DataSuccess && dataState.data!.isNotEmpty) {
      emit(RemoteBannerDone(dataState.data!));
    }
    if (dataState is DataFailed) {
      emit(RemoteBannerError(dataState.error!));
    }
  }
}

import 'package:auto/categories/domain/entities/category_entity.dart';
import 'package:auto/categories/domain/usecases/get_category_usecase.dart';
import 'package:auto/core/resources/data_state.dart';
import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';

part 'remote_category_event.dart';
part 'remote_category_state.dart';

class RemoteCategoryBloc
    extends Bloc<RemoteCategoryEvent, RemoteCategoryState> {
  final GetCategoryUseCase _categoryUseCase;
  RemoteCategoryBloc(this._categoryUseCase) : super(RemoteCategoryLoading()) {
    on<GetCategories>(onGetCategories);
  }

  Future<void> onGetCategories(
    RemoteCategoryEvent event,
    Emitter<RemoteCategoryState> emit,
  ) async {
    final dataState = await _categoryUseCase();
    if (dataState is DataSuccess && dataState.data!.isNotEmpty) {
      emit(RemoteCategoryDone(dataState.data!));
    }
    if (dataState is DataFailed) {
      emit(RemoteCategoryError(dataState.error!));
    }
  }
}

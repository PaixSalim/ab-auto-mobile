part of 'remote_category_bloc.dart';

sealed class RemoteCategoryState {
  final List<CategoryEntity>? categories;
  final DioException? error;
  const RemoteCategoryState({this.categories, this.error});
  @override
  List<Object> get props => [categories!, error!];
}

final class RemoteCategoryLoading extends RemoteCategoryState {
  const RemoteCategoryLoading();
}

final class RemoteCategoryDone extends RemoteCategoryState {
  const RemoteCategoryDone(List<CategoryEntity> categories)
    : super(categories: categories);
}

final class RemoteCategoryError extends RemoteCategoryState {
  const RemoteCategoryError(DioException error) : super(error: error);
}

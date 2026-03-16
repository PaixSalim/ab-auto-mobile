part of 'remote_category_bloc.dart';

sealed class RemoteCategoryEvent {
  const RemoteCategoryEvent();
}

class GetCategories extends RemoteCategoryEvent {
  const GetCategories();
}

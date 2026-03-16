part of 'remote_promoted_product_bloc.dart';

abstract class RemotePromotedProductState {
  final List<PromotedProductEntity>? promotedProducts;
  final DioException? error;

  const RemotePromotedProductState({this.promotedProducts, this.error});
  List<Object> get props => [promotedProducts!, error!];
}

class RemotePromotedProductLoading extends RemotePromotedProductState {
  const RemotePromotedProductLoading();
}

class RemotePromotedProductError extends RemotePromotedProductState {
  const RemotePromotedProductError(DioException error) : super(error: error);
}

class RemotePromotedProductDone extends RemotePromotedProductState {
  const RemotePromotedProductDone(List<PromotedProductEntity> promotedProducts)
    : super(promotedProducts: promotedProducts);
}

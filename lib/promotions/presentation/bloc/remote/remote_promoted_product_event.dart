part of 'remote_promoted_product_bloc.dart';

abstract class RemotePromotedProductEvent {
  const RemotePromotedProductEvent();
}

class GetPromotedProduct extends RemotePromotedProductEvent {
  const GetPromotedProduct();
}

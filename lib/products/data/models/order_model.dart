import 'package:auto/products/domain/entities/order_entity.dart';

class OrderModel extends OrderEntity {
  const OrderModel(
    super.productId,
    super.quantity,
    super.fullName,
    super.city,
    super.phoneNumber,
  );

  @override
  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'city': city,
      'productId': productId,
      'quantity': quantity,
    };
  }
}

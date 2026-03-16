class OrderEntity {
  final String fullName;
  final String phoneNumber;
  final String city;
  final int productId;
  final int quantity;

  const OrderEntity(
    this.fullName,
    this.phoneNumber,
    this.city,
    this.productId,
    this.quantity,
  );

  Map<String, dynamic> toJson() {
    return {
      'customerName': fullName,
      'phoneNumber': phoneNumber,
      'city': city,
      'productId': productId,
      'quantity': quantity,
    };
  }
}

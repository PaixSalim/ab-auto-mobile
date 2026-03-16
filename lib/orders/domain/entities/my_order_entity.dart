class MyOrderEntity {
  final int id;
  final String productName;
  final String productImage;
  final int quantity;
  final String status;
  final String city;
  final String phoneNumber;
  final String createdAt;
  final String customerName;
  final double price;
  final double productPrice;

  const MyOrderEntity({
    required this.id,
    required this.productName,
    required this.productImage,
    required this.quantity,
    required this.status,
    required this.city,
    required this.phoneNumber,
    required this.createdAt,
    required this.customerName,
    required this.price,
    required this.productPrice,
  });
}

import 'package:intl/intl.dart';

String getProductPrice(double price, double discount) {
  final discountedPrice = price - (price * discount) / 100;
  final formatter = NumberFormat("#,##0", "fr_FR");
  return formatter.format(discountedPrice);
}

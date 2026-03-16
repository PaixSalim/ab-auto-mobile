import 'package:intl/intl.dart';

String getCartPrice(double price, double discount, int quantity) {
  final cartPrice = (price - (price * discount) / 100) * quantity;
  final formatter = NumberFormat("#,##0", "fr_FR");
  return formatter.format(cartPrice);
}

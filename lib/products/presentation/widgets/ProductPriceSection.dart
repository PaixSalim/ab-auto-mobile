import 'package:flutter/material.dart';
import 'package:auto/products/domain/entities/product_entity.dart';

class ProductPriceSection extends StatelessWidget {
  final ProductEntity product;

  const ProductPriceSection({
    super.key,
    required this.product,
  });

  double getRealPrice(double price, double? discount) {
    if (discount == null || discount == 0) return price;
    return price * (1 - discount / 100);
  }

  String formatPrice(double price) {
    return '${price.toInt().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), 
      (Match m) => '${m[1]} '
    )} Fcfa';
  }

  @override
  Widget build(BuildContext context) {
    final hasDiscount = product.discount != null && product.discount! > 0;
    final realPrice = getRealPrice(product.price ?? 0, product.discount ?? 0);
    final hasCta = product.cta != null && product.cta!.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product title
          Text(
            product.name ?? 'Produit',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Price section
          if (hasCta) ...[
            // CTA display
            Text(
              product.cta!,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3B82F6),
              ),
            ),
          ] else ...[
            // Price with discount
            Row(
              children: [
                Text(
                  formatPrice(realPrice),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3B82F6),
                  ),
                ),
                
                if (hasDiscount) ...[
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6).withOpacity(0.1),
                      border: Border.all(color: const Color(0xFF3B82F6)),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      'Prix promo',
                      style: const TextStyle(
                        color: Color(0xFF3B82F6),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            
            // Original price with discount
            if (hasDiscount) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    formatPrice(product.price ?? 0),
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '-${product.discount!.toInt()}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
          
          const SizedBox(height: 8),
          
          // Additional info
          if (product.warranty != null && product.warranty!.isNotEmpty) ...[
            Row(
              children: [
                Icon(
                  Icons.verified_outlined,
                  size: 16,
                  color: Colors.green[600],
                ),
                const SizedBox(width: 4),
                Text(
                  'Garantie: ${product.warranty}',
                  style: TextStyle(
                    color: Colors.green[600],
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

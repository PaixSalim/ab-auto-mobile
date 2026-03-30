import 'package:flutter/material.dart';
import 'package:auto/products/domain/entities/product_entity.dart';

class ProductBreadcrumb extends StatelessWidget {
  final ProductEntity product;
  final VoidCallback? onHomeTap;
  final VoidCallback? onCatalogTap;

  const ProductBreadcrumb({
    super.key,
    required this.product,
    this.onHomeTap,
    this.onCatalogTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Home
          InkWell(
            onTap: onHomeTap ?? () => Navigator.of(context).popUntil((route) => route.isFirst),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.home_outlined,
                  size: 16,
                  color: Color(0xFF6B7280),
                ),
                const SizedBox(width: 4),
                const Text(
                  'Accueil',
                  style: TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          
          // Separator
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Icon(
              Icons.chevron_right,
              size: 16,
              color: Color(0xFF9CA3AF),
            ),
          ),
          
          // Category
          InkWell(
            onTap: onCatalogTap,
            child: Text(
              product.category?.name ?? 'Catégorie',
              style: const TextStyle(
                color: Color(0xFF4B5563),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          
          // Separator
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Icon(
              Icons.chevron_right,
              size: 16,
              color: Color(0xFF9CA3AF),
            ),
          ),
          
          // Catalog
          const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.grid_view_outlined,
                size: 16,
                color: Color(0xFF6B7280),
              ),
              SizedBox(width: 4),
              Text(
                'Catalogue',
                style: TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 14,
                ),
              ),
            ],
          ),
          
          // Separator
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Icon(
              Icons.chevron_right,
              size: 16,
              color: Color(0xFF9CA3AF),
            ),
          ),
          
          // Product name
          Expanded(
            child: Text(
              product.name ?? 'Produit',
              style: const TextStyle(
                color: Color(0xFF3B82F6),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

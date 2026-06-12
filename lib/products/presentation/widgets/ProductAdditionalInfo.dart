import 'package:flutter/material.dart';
import 'package:auto/products/domain/entities/product_entity.dart';

class ProductAdditionalInfo extends StatelessWidget {
  final ProductEntity product;

  const ProductAdditionalInfo({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        children: [
          const Divider(color: Color(0xFFE5E7EB)),
          const SizedBox(height: 24),
          
          // Section title
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Informations supplémentaires',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Info grid
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Column(
              children: [
                // Brand
                if (product.brand != null) ...[
                  _InfoRow(
                    icon: Icons.business_outlined,
                    label: 'Marque',
                    value: product.brand!.name ?? 'Non spécifiée',
                    iconColor: const Color(0xFF3B82F6),
                  ),
                  const SizedBox(height: 16),
                ],
                
                // Category
                if (product.category != null) ...[
                  _InfoRow(
                    icon: Icons.category_outlined,
                    label: 'Catégorie',
                    value: product.category!.name ?? 'Non spécifiée',
                    iconColor: const Color(0xFF10B981),
                  ),
                  const SizedBox(height: 16),
                ],
                
                // Delivery info
                _InfoRow(
                  icon: Icons.local_shipping_outlined,
                  label: 'Livraison estimée',
                  value: 'Contactez le vendeur pour les informations',
                  iconColor: const Color(0xFFF59E0B),
                ),
                
                // Additional features if available
                if (product.features != null && product.features!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Divider(color: Color(0xFFF3F4F6)),
                  const SizedBox(height: 16),
                  
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Caractéristiques',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF374151),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  ...product.features!.map((feature) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 16,
                          color: Colors.green[600],
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            feature,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
                ],
                
                // State info
                if (product.state != null && product.state!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Divider(color: Color(0xFFF3F4F6)),
                  const SizedBox(height: 16),
                  
                  _InfoRow(
                    icon: Icons.info_outline,
                    label: 'État',
                    value: product.state!,
                    iconColor: const Color(0xFF6B7280),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color iconColor;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 20,
            color: iconColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF1F2937),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

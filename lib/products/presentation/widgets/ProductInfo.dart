import 'package:auto/products/domain/entities/product_entity.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

class ProductInfo extends StatelessWidget {
  final ProductEntity product;
  const ProductInfo({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final seller = product.seller;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Marque', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(product.brand?.name ?? '-'),
          ],
        ),
        const SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Catégorie', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(product.category?.name ?? '-'),
          ],
        ),
        const SizedBox(height: 5),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Livraison', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('3-7 jours ouvrés'),
          ],
        ),
        if (seller != null) ..._buildSellerSection(context, seller),
        const SizedBox(height: 20),
      ],
    );
  }

  List<Widget> _buildSellerSection(BuildContext context, SellerEntity seller) {
    final primary = Theme.of(context).primaryColor;
    return [
      const SizedBox(height: 16),
      const Divider(),
      const SizedBox(height: 8),
      Row(
        children: [
          Icon(LucideIcons.store, size: 18, color: primary),
          const SizedBox(width: 8),
          Text(
            'Informations du vendeur',
            style: TextStyle(fontWeight: FontWeight.bold, color: primary, fontSize: 15),
          ),
        ],
      ),
      const SizedBox(height: 10),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Vendeur', style: TextStyle(fontWeight: FontWeight.bold)),
          Text(seller.fullName ?? 'Vendeur AB Auto'),
        ],
      ),
      if (seller.phone != null && seller.phone!.isNotEmpty) ...[  
        const SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Téléphone', style: TextStyle(fontWeight: FontWeight.bold)),
            GestureDetector(
              onTap: () => launchUrl(Uri.parse('tel:${seller.phone}')),
              child: Text(
                seller.phone!,
                style: TextStyle(color: primary, decoration: TextDecoration.underline),
              ),
            ),
          ],
        ),
      ],
      if (seller.email != null && seller.email!.isNotEmpty) ...[  
        const SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Email', style: TextStyle(fontWeight: FontWeight.bold)),
            GestureDetector(
              onTap: () => launchUrl(Uri.parse('mailto:${seller.email}')),
              child: Text(
                seller.email!,
                style: TextStyle(color: primary, decoration: TextDecoration.underline),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    ];
  }
}

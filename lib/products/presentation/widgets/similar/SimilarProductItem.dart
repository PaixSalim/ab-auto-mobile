import 'package:auto/products/data/utils/getProductPrice.dart';
import 'package:auto/products/domain/entities/product_entity.dart';
import 'package:auto/products/presentation/widgets/ProductCard.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SimilarProductItem extends StatelessWidget {
  final ProductEntity product;
  final VoidCallback onTap;

  const SimilarProductItem({
    super.key,
    required this.product,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(8),
              ),
              child: SizedBox(
                height: 120,
                width: double.infinity,
                child: product.medias != null && product.medias!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: resolveMediaUrl(product.medias![0]),
                        fit: BoxFit.cover,
                        progressIndicatorBuilder:
                            (context, url, downloadProgress) => Lottie.asset(
                              'assets/animations/lottie/loading-image.json',
                              fit: BoxFit.cover,
                            ),
                        errorWidget:
                            (context, url, error) => Lottie.asset(
                              'assets/animations/lottie/error-network.json',
                              fit: BoxFit.cover,
                            ),
                      )
                    : Container(
                        color: Colors.grey[200],
                        child: const Icon(Icons.image_not_supported, color: Colors.grey),
                      ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nom du produit
                  Text(
                    product.name!,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  if (product.cta!.isNotEmpty)
                    Text(
                      product.cta!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  if (product.cta!.isEmpty)
                    Text(
                      '${getProductPrice(product.price!, 0)} Fcfa',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

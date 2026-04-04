import 'package:auto/config/routes/custom_navigation.dart';
import 'package:auto/products/data/utils/getProductPrice.dart';
import 'package:auto/products/domain/entities/product_entity.dart';
import 'package:auto/products/presentation/pages/ProductDetailPage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

// Résolution des URLs relatives (conservée pour compatibilité)
String resolveMediaUrl(String url) {
  return url; // URLs déjà résolues dans ProductModel.fromJson
}

class ProductGridCard extends StatelessWidget {
  final ProductEntity product;
  const ProductGridCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        goTo(context, ProductDetailPage(product: product), AnimationType.fade);
      },
      child: Card(
        color: Colors.white,
        elevation: 2,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            Expanded(
              flex: 5,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                    child: Hero(
                      tag: 'product-${product.id}',
                      child: product.medias != null && product.medias!.isNotEmpty
                          ? CachedNetworkImage(
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                              imageUrl: resolveMediaUrl(product.medias![0]),
                              progressIndicatorBuilder: (context, url, progress) => Lottie.asset(
                                'assets/animations/lottie/loading-image.json',
                              ),
                              errorWidget: (context, url, err) => const Icon(Icons.image_not_supported),
                            )
                          : Container(
                              color: Colors.grey[200],
                              child: const Center(child: Icon(Icons.image_not_supported)),
                            ),
                    ),
                  ),
                  if (product.discount! > 0)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "-${product.discount}%",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            
            // Info Section
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Title and Brand
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Text(
                        //   product.brand!.name!.toUpperCase(),
                        //   style: TextStyle(
                        //     color: Theme.of(context).primaryColor,
                        //     fontSize: 10,
                        //     fontWeight: FontWeight.bold,
                        //     letterSpacing: 1.1,
                        //   ),
                        // ),
                        const SizedBox(height: 2),
                        Text(
                          product.name!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    
                    // Price
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (product.discount! > 0)
                          Text(
                            "${getProductPrice(product.price!, 0)} Fcfa",
                            style: const TextStyle(
                              decoration: TextDecoration.lineThrough,
                              color: Colors.grey,
                              fontSize: 10,
                            ),
                          ),
                        Text(
                          "${getProductPrice(product.price!, product.discount!)} Fcfa",
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

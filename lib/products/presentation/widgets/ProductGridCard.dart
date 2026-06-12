import 'package:auto/config/routes/custom_navigation.dart';
import 'package:auto/products/data/utils/getProductPrice.dart';
import 'package:auto/products/domain/entities/product_entity.dart';
import 'package:auto/products/presentation/pages/ProductDetailPage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto/promotions/presentation/bloc/remote/remote_promoted_product_bloc.dart';
import 'package:lottie/lottie.dart';
import 'dart:ui';

// Résolution des URLs relatives (conservée pour compatibilité)
String resolveMediaUrl(String url) {
  return url; // URLs déjà résolues dans ProductModel.fromJson
}

class ProductGridCard extends StatelessWidget {
  final ProductEntity product;
  final int? index; // Index pour créer un tag unique
  final String heroTagPrefix;
  
  const ProductGridCard({
    super.key, 
    required this.product,
    this.index,
    this.heroTagPrefix = 'home-product',
  });

  String getStateText(String? state) {
    switch (state) {
      case 'new':
        return 'Neuf';
      case 'old':
        return 'Occasion';
      case 'used':
        return 'France Aurevoir';
      default:
        return 'Neuf';
    }
  }

  Color getStateColor(String? state) {
    switch (state) {
      case 'new':
        return Colors.green;
      case 'old':
        return Colors.orange;
      case 'used':
        return Colors.blue;
      default:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    double activeDiscount = product.discount ?? 0.0;
    try {
      final promoState = context.watch<RemotePromotedProductBloc>().state;
      if (promoState is RemotePromotedProductDone && promoState.promotedProducts != null) {
        final activePromo = promoState.promotedProducts!.cast<dynamic>().firstWhere(
          (promo) => promo.productId == product.id,
          orElse: () => null,
        );
        if (activePromo != null && activePromo.discountPercent != null) {
          activeDiscount = double.tryParse(activePromo.discountPercent!) ?? activeDiscount;
        }
      }
    } catch (_) {
      // Ignorer si pas de promo active ou si le bloc n'est pas fourni
    }

    return GestureDetector(
      onTap: () {
        goTo(context, ProductDetailPage(product: product), AnimationType.fade);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.withOpacity(0.1), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              spreadRadius: 0,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            Expanded(
              flex: 4,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                    child: Hero(
                      tag: index != null 
                          ? '$heroTagPrefix-${product.id}-$index'
                          : '$heroTagPrefix-${product.id}',
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
                  // State Badge
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: getStateColor(product.state),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        getStateText(product.state),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  if (activeDiscount > 0)
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
                          "-${activeDiscount.toInt()}%",
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
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Title
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              product.name ?? 'Produit',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Price and Seller with Add to Cart Button
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (activeDiscount > 0)
                                Wrap(
                                  crossAxisAlignment: WrapCrossAlignment.end,
                                  spacing: 4,
                                  children: [
                                    Text(
                                      "${getProductPrice(double.tryParse(product.price?.toString() ?? '0') ?? 0, activeDiscount)} Fcfa",
                                      style: TextStyle(
                                        color: Theme.of(context).primaryColor,
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 1.0),
                                      child: Text(
                                        getProductPrice(double.tryParse(product.price?.toString() ?? '0') ?? 0, 0),
                                        style: const TextStyle(
                                          decoration: TextDecoration.lineThrough,
                                          color: Colors.grey,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              else
                                Text(
                                  "${getProductPrice(double.tryParse(product.price?.toString() ?? '0') ?? 0, 0)} Fcfa",
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              const SizedBox(height: 4),
                              // Seller info
                              Row(
                                children: [
                                  Icon(
                                    Icons.store_outlined,
                                    size: 12,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      product.seller?.fullName ?? 'Vendeur',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 10,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              if (product.warranty != null) ...[
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.verified_outlined,
                                      size: 12,
                                      color: Colors.green[600],
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      "Garantie: ${product.warranty}",
                                      style: TextStyle(
                                        color: Colors.green[600],
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                        // Add to cart button
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.add_shopping_cart_rounded,
                            size: 16,
                            color: Theme.of(context).primaryColor,
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
    ),
  );
  }
}

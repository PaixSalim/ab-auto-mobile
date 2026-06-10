import 'package:auto/config/routes/custom_navigation.dart';
import 'package:auto/products/data/utils/getProductPrice.dart';
import 'package:auto/products/presentation/bloc/remote/remote_product_bloc.dart';
import 'package:auto/products/presentation/pages/ProductDetailPage.dart';
import 'package:auto/promotions/domain/entity/promoted_poduct_entity.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';

class PromotionCard extends StatelessWidget {
  final PromotedProductEntity promotion;
  const PromotionCard({super.key, required this.promotion});

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

  double? calculatePromoPrice(String? originalPrice, String? discountPercent) {
    if (originalPrice == null || discountPercent == null) return null;
    
    final price = double.tryParse(originalPrice);
    final discount = double.tryParse(discountPercent);
    
    if (price == null || discount == null) return null;
    
    return price * (1 - discount / 100);
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<RemoteProductsBloc>();
    final product = promotion.product;
    
    return GestureDetector(
      onTap: () {
        final allProducts = bloc.state.allProducts;
        if (allProducts == null || allProducts.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Chargement des produits...")),
          );
          return;
        }

        try {
          final productDetail = allProducts.firstWhere(
            (p) => p.id == promotion.productId,
          );
          goTo(
            context,
            ProductDetailPage(product: productDetail),
            AnimationType.gauche,
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Détails du produit non disponibles")),
          );
        }
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
            // Image and Badges
            Expanded(
              flex: 4,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                    child: Hero(
                      tag: 'promotion-${promotion.id}',
                      child: CachedNetworkImage(
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        imageUrl: promotion.url ?? '',
                        progressIndicatorBuilder: (context, url, progress) => Lottie.asset(
                          'assets/animations/lottie/loading-image.json',
                        ),
                        errorWidget: (context, url, error) => const Icon(Icons.error),
                      ),
                    ),
                  ),
                  // State Badge
                  if (product?.state != null)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: getStateColor(product!.state),
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
                  // Discount Badge
                  if (promotion.discountPercent != null)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "-${promotion.discountPercent}%",
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
                    // Title and Promo Label
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              product?.name ?? 'Produit',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          if (promotion.promoLabel != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              promotion.promoLabel!,
                              style: TextStyle(
                                color: Colors.red[600],
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    
                    // Price Section with Add to Cart Button
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Original Price (crossed out)
                              if (product?.price != null)
                                Text(
                                  "${getProductPrice(double.tryParse(product!.price!) ?? 0, 0)} Fcfa",
                                  style: const TextStyle(
                                    decoration: TextDecoration.lineThrough,
                                    color: Colors.grey,
                                    fontSize: 10,
                                  ),
                                ),
                              // Promo Price
                              if (product?.price != null && promotion.discountPercent != null)
                                Text(
                                  "${getProductPrice(calculatePromoPrice(product!.price, promotion.discountPercent) ?? 0, 0)} Fcfa",
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              const SizedBox(height: 2),
                              // Warranty info if available
                              if (product?.warranty != null) ...[
                                Row(
                                  children: [
                                    Icon(
                                      Icons.verified_outlined,
                                      size: 10,
                                      color: Colors.green[600],
                                    ),
                                    const SizedBox(width: 2),
                                    Expanded(
                                      child: Text(
                                        "Garantie: ${product!.warranty}",
                                        style: TextStyle(
                                          color: Colors.green[600],
                                          fontSize: 9,
                                        ),
                                        overflow: TextOverflow.ellipsis,
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

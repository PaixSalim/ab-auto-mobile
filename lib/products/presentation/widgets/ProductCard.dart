import 'package:auto/config/routes/custom_navigation.dart';
import 'package:auto/products/data/utils/getProductPrice.dart';
import 'package:auto/products/domain/entities/product_entity.dart';
import 'package:auto/products/presentation/pages/ProductDetailPage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto/promotions/presentation/bloc/remote/remote_promoted_product_bloc.dart';
import 'package:lottie/lottie.dart';

// Résolution des URLs relatives (conservée pour compatibilité)
String resolveMediaUrl(String url) {
  return url; // URLs déjà résolues dans ProductModel.fromJson
}

class ProductCard extends StatelessWidget {
  final ProductEntity product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    double activeDiscount = product.discount ?? 0.0;
    try {
      final promoState = context.watch<RemotePromotedProductBloc>().state;
      if (promoState is RemotePromotedProductDone && promoState.promotedProducts != null) {
        final activePromo = promoState.promotedProducts!.firstWhere(
          (promo) => promo.productId == product.id,
        );
        if (activePromo.discountPercent != null) {
          activeDiscount = double.tryParse(activePromo.discountPercent!) ?? activeDiscount;
        }
      }
    } catch (_) {}

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Brand and Profile style
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.white,
                    backgroundImage: CachedNetworkImageProvider(product.brand!.url!),
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.brand!.name!,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const Text(
                      "Sponsorisé • À l'instant",
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
                const Spacer(),
                const Icon(Icons.more_horiz, color: Colors.grey),
              ],
            ),
          ),
          
          // Product Description/Text
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
            child: Text(
              product.name!,
              style: const TextStyle(fontSize: 15),
            ),
          ),
          if (product.description != null && product.description!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 2.0),
              child: Text(
                product.description!.split('.')[0],
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
            ),
          
          const SizedBox(height: 8),

          // Main Image
          GestureDetector(
            onTap: () {
              goTo(context, ProductDetailPage(product: product), AnimationType.fade);
            },
            child: Stack(
              children: [
                product.medias != null && product.medias!.isNotEmpty
                    ? CachedNetworkImage(
                        fit: BoxFit.cover,
                        height: 300,
                        width: double.infinity,
                        imageUrl: resolveMediaUrl(product.medias![0]),
                        progressIndicatorBuilder: (context, url, downloadProgress) => Lottie.asset(
                          'assets/animations/lottie/loading-image.json',
                        ),
                        errorWidget: (context, url, error) => Lottie.asset(
                          'assets/animations/lottie/error-network.json',
                        ),
                      )
                    : Container(
                        height: 300,
                        width: double.infinity,
                        color: Colors.grey[200],
                        child: const Icon(Icons.image_not_supported, size: 48, color: Colors.grey),
                      ),
                if (activeDiscount > 0)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        "-${activeDiscount.toInt()}%",
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Bottom Info: Price and Action
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (activeDiscount > 0)
                      Text(
                        "${getProductPrice(product.price!, 0)} Fcfa",
                        style: const TextStyle(
                          decoration: TextDecoration.lineThrough,
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    Text(
                      "${getProductPrice(product.price!, activeDiscount)} Fcfa",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {
                    goTo(context, ProductDetailPage(product: product), AnimationType.fade);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  ),
                  child: const Text("Voir détails"),
                ),
              ],
            ),
          ),
          
          // Interactions (Social style)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.favorite_border, size: 20),
                  onPressed: () {},
                ),
                const Text("J'aime", style: TextStyle(fontSize: 12)),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.chat_bubble_outline, size: 20),
                  onPressed: () {},
                ),
                const Text("Commenter", style: TextStyle(fontSize: 12)),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.share_outlined, size: 20),
                  onPressed: () {},
                ),
                const Text("Partager", style: TextStyle(fontSize: 12)),
              ],
            ),
          ),
          const Divider(thickness: 1, height: 1),
        ],
      ),
    );
  }
}

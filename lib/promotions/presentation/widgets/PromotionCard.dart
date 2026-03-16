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

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<RemoteProductsBloc>();
    Size size = MediaQuery.of(context).size;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '-${promotion.discountPercent!}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Image du produit
            Center(
              child: GestureDetector(
                onTap: () {
                  final product =
                      bloc.state.displayedProducts!.where((p) {
                        return p.id == promotion.id;
                      }).first;
                  goTo(
                    context,
                    ProductDetailPage(product: product),
                    AnimationType.gauche,
                  );
                },
                child: CachedNetworkImage(
                  height: size.height / 3,
                  fit: BoxFit.cover,
                  imageUrl: promotion.url!,
                  progressIndicatorBuilder:
                      (context, url, downloadProgress) => Lottie.asset(
                        'assets/animations/lottie/loading-image.json',
                      ),
                  errorWidget:
                      (context, url, error) => Lottie.asset(
                        'assets/animations/lottie/error-network.json',
                      ),
                ),
              ),
            ),

            // Nom du produit
            Text(
              promotion.name!,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),

            // Prix
            Row(
              children: [
                Text(
                  '${getProductPrice(promotion.originalPrice!, 0)} Fcfa',
                  style: const TextStyle(
                    decoration: TextDecoration.lineThrough,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${getProductPrice(promotion.promoPrice!, 0)} Fcfa',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Bouton
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  final product =
                      bloc.state.displayedProducts!.where((p) {
                        return p.id == promotion.id;
                      }).first;
                  goTo(
                    context,
                    ProductDetailPage(product: product),
                    AnimationType.gauche,
                  );
                },
                icon: const Icon(Icons.shopping_cart),
                label: const Text("En profiter"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

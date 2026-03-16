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

class ProductCard extends StatelessWidget {
  final ProductEntity product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 0,
      shape: Border.all(color: Colors.grey.shade200),
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                GestureDetector(
                  onTap: () {
                    goTo(
                      context,
                      ProductDetailPage(product: product),
                      AnimationType.fade,
                    );
                  },
                  child: product.medias != null && product.medias!.isNotEmpty
                      ? CachedNetworkImage(
                          fit: BoxFit.cover,
                          height: 200,
                          width: double.infinity,
                          imageUrl: resolveMediaUrl(product.medias![0]),
                          progressIndicatorBuilder:
                              (context, url, downloadProgress) => Lottie.asset(
                                'assets/animations/lottie/loading-image.json',
                              ),
                          errorWidget:
                              (context, url, error) => Lottie.asset(
                                'assets/animations/lottie/error-network.json',
                              ),
                        )
                      : Container(
                          height: 200,
                          width: double.infinity,
                          color: Colors.grey[200],
                          child: const Icon(Icons.image_not_supported, size: 48, color: Colors.grey),
                        ),
                ),
                if (product.discount! > 0)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      child: Text(
                        "-${product.discount}%",
                        style: TextStyle(color: Colors.white, fontSize: 11),
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          product.name!,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      product.state == "new"
                          ? Text(
                            "Neuf",
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                            ),
                          )
                          : Text("Occasion", style: TextStyle()),
                    ],
                  ),
                  Row(
                    children: [
                      CachedNetworkImage(
                        height: 30,
                        imageUrl: product.brand!.url!,
                        progressIndicatorBuilder:
                            (context, url, downloadProgress) => Lottie.asset(
                              'assets/animations/lottie/loading-image.json',
                            ),
                        errorWidget:
                            (context, url, error) => Lottie.asset(
                              'assets/animations/lottie/error-network.json',
                            ),
                      ),
                    ],
                  ),
                  SizedBox(height: 5),
                  Text(product.description!.split('.')[0], style: TextStyle()),
                  SizedBox(height: 5),
                  Row(
                    children: [
                      if (product.discount! > 0)
                        Text(
                          "${getProductPrice(product.price!, 0)} Fcfa ",
                          style: TextStyle(
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey,
                          ),
                        ),
                      if (product.cta!.isNotEmpty)
                        Text(
                          product.cta!,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      if (product.cta!.isEmpty)
                        Text(
                          "${getProductPrice(product.price!, product.discount!)} Fcfa ",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      Spacer(),
                      TextButton(
                        onPressed: () {
                          goTo(
                            context,
                            ProductDetailPage(product: product),
                            AnimationType.fade,
                          );
                        },
                        child: Text(
                          'Voir détails',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    ],
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

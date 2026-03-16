import 'package:auto/brands/presentation/widgets/showBrandSelectionModal.dart';
import 'package:auto/categories/domain/entities/category_entity.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class CategoryCard extends StatelessWidget {
  final CategoryEntity category;

  const CategoryCard({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showCenteredBrandSelectionDialog(context, category);
      },
      child: Container(
        width: 150,
        height: 120, // Hauteur fixe pour éviter l'overflow
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              flex: 3,
              child: CachedNetworkImage(
                imageUrl: category.url!,
                fit: BoxFit.contain,
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
            const SizedBox(height: 8),
            Expanded(
              flex: 1,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        category.name!,
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    category.items!.toString(),
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 11,
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

import 'package:auto/categories/domain/entities/category_entity.dart';
import 'package:auto/categories/presentation/widgets/showSubCategorySelectionDialog.dart';
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
        showSubCategorySelectionDialog(context, category);
      },
      child: Container(
        width: 80,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.5),
                  width: 2,
                ),
              ),
              child: CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white,
                child: ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: category.url!,
                    width: 60,
                    height: 60,
                    fit: BoxFit.contain,
                    progressIndicatorBuilder: (context, url, downloadProgress) => Lottie.asset(
                      'assets/animations/lottie/loading-image.json',
                    ),
                    errorWidget: (context, url, error) => const Icon(Icons.category, color: Colors.grey),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              category.name!,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}

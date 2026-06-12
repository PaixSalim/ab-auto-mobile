import 'package:auto/config/routes/custom_navigation.dart';
import 'package:auto/products/domain/entities/product_entity.dart';
import 'package:auto/products/presentation/bloc/remote/remote_product_bloc.dart';
import 'package:auto/products/presentation/bloc/remote/remote_product_event.dart';
import 'package:auto/config/navigation/main_navigation.dart';
import 'package:auto/products/presentation/pages/ProductDetailPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Ajoutons une classe pour gérer l'extraction des slugs et la navigation
class UrlHandler {
  static const String baseUrl = 'https://auto-pro.uvatis.com';
  static const String cataloguePath = '$baseUrl/catalogue';
  static const String productPath = '$baseUrl/catalogue/view';

  // Méthode pour extraire le slug du produit
  static String? extractProductSlug(String url) {
    if (!url.startsWith(productPath)) return null;

    // Extraire le slug après /catalogue/product/
    final parts = url.split('/');
    if (parts.length < 4) return null;

    return parts[5]; // Le slug est la 4ème partie (index 3)
  }

  // Méthode pour déterminer le type de page à afficher
  static PageType determinePageType(String url) {
    if (url.startsWith(productPath)) {
      final slug = extractProductSlug(url);
      if (slug != null && slug.isNotEmpty) {
        return PageType.productDetail;
      }
    } else if (url.startsWith(cataloguePath)) {
      return PageType.productCatalogue;
    }

    return PageType.unknown;
  }

  // Méthode pour naviguer vers la page appropriée
  static void navigateToPage(BuildContext context, String url) {
    final pageType = determinePageType(url);

    switch (pageType) {
      case PageType.productDetail:
        final slug = extractProductSlug(url);
        final ProductEntity product =
            context
                .read<RemoteProductsBloc>()
                .state
                .allProducts!
                .where((p) => p.slug == slug)
                .first;
        goTo(context, ProductDetailPage(product: product), AnimationType.fade);
        break;
      case PageType.productCatalogue:
        context.read<RemoteProductsBloc>().add(ResetProductFilter());
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const MainNavigation(initialIndex: 1),
          ),
          (route) => false,
        );
        break;
      case PageType.unknown:
        break;
    }
  }
}

// Enum pour les types de pages
enum PageType { productDetail, productCatalogue, unknown }

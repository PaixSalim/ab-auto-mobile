import 'package:auto/config/navigation/main_navigation.dart';
import 'package:auto/config/routes/custom_navigation.dart';
import 'package:auto/products/domain/entities/product_entity.dart';
import 'package:auto/products/presentation/bloc/remote/remote_product_bloc.dart';
import 'package:auto/products/presentation/pages/ProductCatalogPage.dart';
import 'package:auto/products/presentation/pages/ProductDetailPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/remote/remote_product_event.dart';
import '../ProductGridCard.dart';

class SimilarProductsSection extends StatelessWidget {
  final List<ProductEntity> similarProducts;

  const SimilarProductsSection({super.key, required this.similarProducts});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Titre de la section
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Produits similaires',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {
                  // Mettre à jour les filtres
                  context.read<RemoteProductsBloc>().add(
                    SearchProducts(similarProducts[0].category!.name!),
                  );
                  // Naviguer vers la navigation principale avec l'onglet "Recherche par marque" sélectionné
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => const MainNavigation(initialIndex: 1),
                    ),
                    (route) => false,
                  );
                },
                child: const Text('Voir tout'),
              ),
            ],
          ),
        ),

        // Contenu de la section
        LayoutBuilder(
          builder: (context, constraints) {
            // Calculer la même largeur qu'une carte dans la grille (2 colonnes)
            final cardWidth = (MediaQuery.of(context).size.width - 32 - 10) / 2; 
            // 32 = padding horizontal (16 * 2), 10 = crossAxisSpacing
            final cardHeight = cardWidth / 0.90; // childAspectRatio de 0.90

            return SizedBox(
              height: cardHeight,
              child: _buildContent(context, similarProducts, cardWidth),
            );
          },
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context, List<ProductEntity> products, double cardWidth) {
    if (products.isEmpty) {
      return const Center(child: Text('Aucun produit similaire trouvé'));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      scrollDirection: Axis.horizontal,
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return Padding(
          padding: const EdgeInsets.only(right: 12.0),
          child: SizedBox(
            width: cardWidth,
            child: ProductGridCard(
              product: product,
              index: index,
              heroTagPrefix: 'similar-product',
            ),
          ),
        );
      },
    );
  }
}

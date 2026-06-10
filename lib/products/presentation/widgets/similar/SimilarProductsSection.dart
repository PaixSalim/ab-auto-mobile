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
                  // Navigation vers la page catalogue filtrée par catégorie
                  context.read<RemoteProductsBloc>().add(
                    SearchProducts(similarProducts[0].category!.name!),
                  );
                  goTo(context, ProductCatalogPage(), AnimationType.gauche);
                },
                child: const Text('Voir tout'),
              ),
            ],
          ),
        ),

        // Contenu de la section
        SizedBox(
          height: 260, // Augmenté pour correspondre à la hauteur de la carte ProductGridCard
          child: _buildContent(context, similarProducts),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context, List<ProductEntity> products) {
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
          child: AspectRatio(
            aspectRatio: 0.90,
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

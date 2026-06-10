import 'package:auto/config/routes/custom_navigation.dart';
import 'package:auto/promotions/domain/entity/promoted_poduct_entity.dart';
import 'package:auto/promotions/presentation/bloc/remote/remote_promoted_product_bloc.dart';
import 'package:auto/promotions/presentation/pages/AllPromotionsPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'PromotionCard.dart';

class PromotionsSection extends StatelessWidget {
  const PromotionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RemotePromotedProductBloc, RemotePromotedProductState>(
      builder: (context, state) {
        if (state is RemotePromotedProductLoading) {
          return const SizedBox.shrink();
        } else if (state is RemotePromotedProductError) {
          return const Center(child: Text('Erreur lors du chargement des promotions'));
        } else if (state is RemotePromotedProductDone) {
          List<PromotedProductEntity> promotions = state.promotedProducts ?? [];

          if (promotions.isEmpty) {
            return const SizedBox.shrink();
          }

          // Limiter à 4 promotions maximum pour l'accueil
          List<PromotedProductEntity> displayedPromotions = promotions.take(4).toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Nos promotions en cours",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        goTo(context, const AllPromotionsPage(), AnimationType.fade);
                      },
                      child: const Text('Voir plus'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Liste horizontale des promotions
              SizedBox(
                height: 200, // Hauteur réduite pour s'aligner avec les nouvelles cartes plus courtes
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  scrollDirection: Axis.horizontal,
                  itemCount: displayedPromotions.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: SizedBox(
                        width: 160, // Largeur fixe pour chaque carte dans le carrousel
                        child: PromotionCard(
                          promotion: displayedPromotions[index],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 30),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}


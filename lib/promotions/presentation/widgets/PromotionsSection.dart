import 'package:auto/promotions/domain/entity/promoted_poduct_entity.dart';
import 'package:auto/promotions/presentation/bloc/remote/remote_promoted_product_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'PromotionCard.dart';

class PromotionsSection extends StatefulWidget {
  const PromotionsSection({super.key});

  @override
  State<PromotionsSection> createState() => _PromotionsSectionState();
}

class _PromotionsSectionState extends State<PromotionsSection> {
  String selectedCategory = "Tout";
  int _displayedPromotionsCount = 6; // Initial number of promotions to display
  static const int _incrementCount = 6; // Number of promotions to load each time

  void _loadMorePromotions() {
    setState(() {
      _displayedPromotionsCount += _incrementCount;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RemotePromotedProductBloc, RemotePromotedProductState>(
      builder: (context, state) {
        if (state is RemotePromotedProductLoading) {
          return const Text('');
        } else if (state is RemotePromotedProductError) {
          return Center(child: Text('Une erreur promotions'));
        } else if (state is RemotePromotedProductDone) {
          List<PromotedProductEntity> promotions = state.promotedProducts!;

          List<String> categories =
              promotions.map((p) => p.product?.category?.name ?? 'Non catégorisé').toSet().toList();
          categories.insert(0, "Tout"); // Ajouter "Tout" au début

          // Filtrer les promotions selon la catégorie sélectionnée
          List<PromotedProductEntity> filteredPromotions =
              selectedCategory == "Tout"
                  ? promotions
                  : promotions
                      .where(
                        (promotion) => promotion.product?.category?.name == selectedCategory,
                      )
                      .toList();

          // Limiter le nombre de promotions affichées pour la pagination
          List<PromotedProductEntity> displayedPromotions = 
              filteredPromotions.take(_displayedPromotionsCount).toList();
          
          // Vérifier s'il y a plus de promotions à charger
          bool hasMorePromotions = _displayedPromotionsCount < filteredPromotions.length;
          return (promotions.isNotEmpty)
              ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      "Nos promotions en cours",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(
                        8.0,
                      ), // Définir le rayon du bord
                      // child: CachedNetworkImage(
                      //   imageUrl:
                      //       'https://auto-cdn.uvatis.com/promos/banner.jpg',
                      //   fit: BoxFit.cover,
                      //   progressIndicatorBuilder:
                      //       (context, url, downloadProgress) => Lottie.asset(
                      //         'assets/animations/lottie/loading-image.json',
                      //       ),
                      //   errorWidget:
                      //       (context, url, error) => Lottie.asset(
                      //         'assets/animations/lottie/error-network.json',
                      //       ),
                      // ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Onglets de catégories
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children:
                            categories.map((category) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: ChoiceChip(
                                  label: Text(
                                    category,
                                    style: TextStyle(
                                      color:
                                          selectedCategory == category
                                              ? Colors.white
                                              : Colors.black,
                                    ),
                                  ),
                                  selected: selectedCategory == category,
                                  checkmarkColor: Colors.white,
                                  selectedColor: Theme.of(context).primaryColor,
                                  onSelected: (selected) {
                                    setState(() {
                                      selectedCategory = category;
                                    });
                                  },
                                ),
                              );
                            }).toList(),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Liste des promotions
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child:
                        displayedPromotions.isEmpty
                            ? const Center(
                              child: Text("Aucune promotion disponible"),
                            )
                            : Column(
                              children: [
                                GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        crossAxisSpacing: 10,
                                        mainAxisSpacing: 10,
                                        childAspectRatio: 0.65,
                                      ),
                                  itemCount: displayedPromotions.length,
                                  itemBuilder: (context, index) {
                                    return PromotionCard(
                                      promotion: displayedPromotions[index],
                                    );
                                  },
                                ),
                                
                                // Bouton "Charger plus"
                                if (hasMorePromotions) ...[
                                  const SizedBox(height: 16),
                                  Center(
                                    child: ElevatedButton(
                                      onPressed: _loadMorePromotions,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Theme.of(context).primaryColor,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 32,
                                          vertical: 12,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(25),
                                        ),
                                      ),
                                      child: const Text(
                                        "Charger plus",
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                                
                                // Message de fin si toutes les promotions sont affichées
                                if (!hasMorePromotions && displayedPromotions.isNotEmpty) ...[
                                  const SizedBox(height: 16),
                                  Center(
                                    child: Text(
                                      "Toutes les promotions sont affichées",
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                  ),
                  const SizedBox(height: 50),
                ],
              )
              : Text('');
        }
        return const SizedBox.shrink();
      },
    );
  }
}

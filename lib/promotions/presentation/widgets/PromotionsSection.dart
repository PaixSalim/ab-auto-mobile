import 'package:auto/promotions/domain/entity/promoted_poduct_entity.dart';
import 'package:auto/promotions/presentation/bloc/remote/remote_promoted_product_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';

import 'PromotionCard.dart';

class PromotionsSection extends StatefulWidget {
  const PromotionsSection({super.key});

  @override
  State<PromotionsSection> createState() => _PromotionsSectionState();
}

class _PromotionsSectionState extends State<PromotionsSection> {
  String selectedCategory = "Tout";

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
              promotions.map((p) => p.category!).toSet().toList();
          categories.insert(0, "Tout"); // Ajouter "Tout" au début

          // Filtrer les promotions selon la catégorie sélectionnée
          List<PromotedProductEntity> filteredPromotions =
              selectedCategory == "Tout"
                  ? promotions
                  : promotions
                      .where(
                        (promotion) => promotion.category == selectedCategory,
                      )
                      .toList();
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
                      child: CachedNetworkImage(
                        imageUrl:
                            'https://auto-cdn.uvatis.com/promos/banner.jpg',
                        fit: BoxFit.cover,
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
                        filteredPromotions.isEmpty
                            ? const Center(
                              child: Text("Aucune promotion disponible"),
                            )
                            : GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 10,
                                    mainAxisSpacing: 10,
                                    childAspectRatio: 0.65,
                                  ),
                              itemCount: filteredPromotions.length,
                              itemBuilder: (context, index) {
                                return PromotionCard(
                                  promotion: filteredPromotions[index],
                                );
                              },
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

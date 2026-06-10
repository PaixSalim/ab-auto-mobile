import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto/promotions/domain/entity/promoted_poduct_entity.dart';
import 'package:auto/promotions/presentation/bloc/remote/remote_promoted_product_bloc.dart';
import 'package:auto/promotions/presentation/widgets/PromotionCard.dart';

class AllPromotionsPage extends StatefulWidget {
  const AllPromotionsPage({super.key});

  @override
  State<AllPromotionsPage> createState() => _AllPromotionsPageState();
}

class _AllPromotionsPageState extends State<AllPromotionsPage> {
  String selectedCategory = "Tout";
  int _displayedPromotionsCount = 10;
  static const int _incrementCount = 10;

  void _loadMorePromotions() {
    setState(() {
      _displayedPromotionsCount += _incrementCount;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFE0EAFC), // Bleu clair vibrant
            Color(0xFFCFDEF3), // Bleu ciel doux
            Color(0xFFE2D4F0), // Touche violet pastel
          ],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.white.withOpacity(0.3),
          elevation: 0,
          flexibleSpace: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(color: Colors.transparent),
            ),
          ),
          iconTheme: const IconThemeData(color: Colors.black87),
          title: const Text(
            "Toutes nos promotions",
            style: TextStyle(
              color: Colors.black87,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
        ),
        body: BlocBuilder<
          RemotePromotedProductBloc,
          RemotePromotedProductState
        >(
          builder: (context, state) {
            if (state is RemotePromotedProductLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is RemotePromotedProductError) {
              return const Center(
                child: Text('Erreur lors du chargement des promotions'),
              );
            } else if (state is RemotePromotedProductDone) {
              List<PromotedProductEntity> promotions =
                  state.promotedProducts ?? [];

              if (promotions.isEmpty) {
                return const Center(
                  child: Text("Aucune promotion disponible actuellement."),
                );
              }

              List<String> categories =
                  promotions
                      .map((p) => p.product?.category?.name ?? 'Non catégorisé')
                      .toSet()
                      .toList();
              categories.insert(0, "Tout");

              List<PromotedProductEntity> filteredPromotions =
                  selectedCategory == "Tout"
                      ? promotions
                      : promotions
                          .where(
                            (p) =>
                                p.product?.category?.name == selectedCategory,
                          )
                          .toList();

              List<PromotedProductEntity> displayedPromotions =
                  filteredPromotions.take(_displayedPromotionsCount).toList();

              bool hasMorePromotions =
                  _displayedPromotionsCount < filteredPromotions.length;

              return CustomScrollView(
                slivers: [
                  // Catégories (Filtres)
                  SliverToBoxAdapter(
                    child: Container(
                      padding: EdgeInsets.only(
                        top: MediaQuery.of(context).padding.top + 5.0,
                        bottom: 12.0,
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
                                                : Colors.black87,
                                      ),
                                    ),
                                    selected: selectedCategory == category,
                                    checkmarkColor: Colors.white,
                                    selectedColor:
                                        Theme.of(context).primaryColor,
                                    onSelected: (selected) {
                                      setState(() {
                                        selectedCategory = category;
                                        _displayedPromotionsCount =
                                            10; // Reset pagination when changing category
                                      });
                                    },
                                  ),
                                );
                              }).toList(),
                        ),
                      ),
                    ),
                  ),

                  // Grille de produits
                  SliverPadding(
                    padding: const EdgeInsets.all(16.0),
                    sliver:
                        displayedPromotions.isEmpty
                            ? const SliverToBoxAdapter(
                              child: Padding(
                                padding: EdgeInsets.all(32.0),
                                child: Center(
                                  child: Text(
                                    "Aucun produit dans cette catégorie.",
                                  ),
                                ),
                              ),
                            )
                            : SliverGrid(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 10,
                                    mainAxisSpacing: 10,
                                    childAspectRatio: 0.90,
                                  ),
                              delegate: SliverChildBuilderDelegate((
                                context,
                                index,
                              ) {
                                return PromotionCard(
                                  promotion: displayedPromotions[index],
                                );
                              }, childCount: displayedPromotions.length),
                            ),
                  ),

                  // Bouton "Charger plus"
                  if (hasMorePromotions)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 16.0,
                          horizontal: 16.0,
                        ),
                        child: Center(
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
                      ),
                    ),

                  // Message de fin
                  if (!hasMorePromotions && displayedPromotions.isNotEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24.0),
                        child: Center(
                          child: Text(
                            "Toutes les promotions sont affichées",
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

import 'package:auto/brands/domain/entities/brand_entity.dart';
import 'package:auto/categories/domain/entities/category_entity.dart';
import 'package:auto/config/routes/custom_navigation.dart';
import 'package:auto/products/presentation/bloc/remote/remote_product_bloc.dart';
import 'package:auto/products/presentation/bloc/remote/remote_product_event.dart';
import 'package:auto/config/navigation/main_navigation.dart';
import 'package:auto/products/presentation/pages/ProductCatalogPage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';

class BrandSelectionModal extends StatefulWidget {
  final CategoryEntity category;
  const BrandSelectionModal({super.key, required this.category});

  @override
  BrandSelectionModalState createState() => BrandSelectionModalState();
}

class BrandSelectionModalState extends State<BrandSelectionModal> {
  TextEditingController searchController = TextEditingController();

  List<BrandEntity> filteredBrands = [];

  @override
  void initState() {
    super.initState();
    filteredBrands = List.from(widget.category.brands!);
  }

  void filterBrands(String query) {
    setState(() {
      filteredBrands =
          widget.category.brands!
              .where(
                (brand) =>
                    brand.name!.toLowerCase().contains(query.toLowerCase()),
              )
              .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<RemoteProductsBloc>();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 13.0, vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: const Text(
                  "Sélectionnez votre véhicule",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  overflow:
                      TextOverflow
                          .ellipsis, // Gérer le débordement du texte si nécessaire
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.grey),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          Divider(color: Colors.grey.withValues(alpha: 0.3)),
          const SizedBox(height: 5),

          TextField(
            controller: searchController,
            onChanged: filterBrands,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.search, color: Colors.grey),
              hintText: "Rechercher une marque ...",
              hintStyle: TextStyle(color: Colors.grey, fontSize: 15),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(10),
              ),
              filled: true,
              fillColor: Colors.grey.withValues(alpha: 0.1),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 8,
                horizontal: 20,
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Theme.of(context).primaryColor,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 35),

          Wrap(
            spacing: 20,
            runSpacing: 20,
            children:
                filteredBrands.map((brand) {
                  return GestureDetector(
                    onTap:
                        () => {
                          bloc.add(
                            FilterProducts(
                              selectedCategories: [widget.category.id!],
                              selectedBrands: [brand.id!],
                              minPrice: 0,
                              maxPrice: 50000000,
                              isNew: false,
                              isUsed: false,
                            ),
                          ),
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (context) => const MainNavigation(initialIndex: 1),
                            ),
                            (route) => false,
                          ),
                        },
                    child: Column(
                      children: [
                        CachedNetworkImage(
                          imageUrl: brand.url!,
                          width: 50,
                          height: 50,
                          progressIndicatorBuilder:
                              (context, url, downloadProgress) => Lottie.asset(
                                'assets/animations/lottie/loading-image.json',
                                width: 15,
                              ),
                          errorWidget:
                              (context, url, error) => Lottie.asset(
                                'assets/animations/lottie/error-network.json',
                                width: 15,
                              ),
                        ),
                        Text(brand.name!, style: const TextStyle(fontSize: 14)),
                      ],
                    ),
                  );
                }).toList(),
          ),

          const SizedBox(height: 35),

          Row(
            children: [
              Text(
                "Catégorie sélectionnée: ",
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              Expanded(
                child: Text(
                  widget.category.name!,
                  softWrap: true,
                  overflow:
                      TextOverflow
                          .ellipsis, // Pour ajouter des "..." si le texte est trop long
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

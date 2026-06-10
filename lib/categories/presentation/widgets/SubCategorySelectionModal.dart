import 'package:auto/categories/domain/entities/category_entity.dart';
import 'package:auto/products/presentation/bloc/remote/remote_product_bloc.dart';
import 'package:auto/products/presentation/bloc/remote/remote_product_event.dart';
import 'package:auto/products/presentation/pages/ProductCatalogPage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SubCategorySelectionModal extends StatefulWidget {
  final CategoryEntity category;
  final RemoteProductsBloc bloc;

  const SubCategorySelectionModal({
    super.key,
    required this.category,
    required this.bloc,
  });

  @override
  State<SubCategorySelectionModal> createState() =>
      _SubCategorySelectionModalState();
}

class _SubCategorySelectionModalState extends State<SubCategorySelectionModal> {
  List<CategoryEntity> filteredSubCategories = [];
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialiser avec les sous-catégories, ou une liste vide si aucune
    filteredSubCategories = List.from(widget.category.subCategories ?? []);
  }

  void filterSubCategories(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredSubCategories = List.from(widget.category.subCategories ?? []);
      } else {
        filteredSubCategories =
            widget.category.subCategories!
                .where(
                  (sub) =>
                      sub.name!.toLowerCase().contains(query.toLowerCase()),
                )
                .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
                  "Sélectionnez une sous-catégorie",
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
            onChanged: filterSubCategories,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.search, color: Colors.grey),
              hintText: "Rechercher une sous-catégorie ...",
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

          // Afficher les sous-catégories ou un message si aucune
          if (filteredSubCategories.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Icon(
                    Icons.category_outlined,
                    size: 50,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.category.subCategories == null ||
                            widget.category.subCategories!.isEmpty
                        ? "Aucune sous-catégorie disponible"
                        : "Aucune sous-catégorie trouvée",
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
            Wrap(
              spacing: 20,
              runSpacing: 20,
              children:
                  filteredSubCategories.map((subCategory) {
                    return GestureDetector(
                      onTap: () {
                        // Appliquer le filtre
                        widget.bloc.add(
                          FilterProducts(
                            selectedCategories: [],
                            selectedSubCategories: [subCategory.id!],
                            selectedBrands: [],
                            minPrice: 0,
                            maxPrice: 50000000,
                            isNew: false,
                            isUsed: false,
                          ),
                        );
                        // Fermer le modal et revenir à la page principale
                        Navigator.of(context).pop();
                        // Naviguer vers la page catalogue en remplaçant la route actuelle
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const ProductCatalogPage(),
                          ),
                        );
                      },
                      child: Column(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Theme.of(
                                  context,
                                ).primaryColor.withValues(alpha: 0.3),
                                width: 1,
                              ),
                            ),
                            child: ClipOval(
                              child: CachedNetworkImage(
                                imageUrl: subCategory.url!,
                                width: 48,
                                height: 48,
                                fit: BoxFit.cover,
                                progressIndicatorBuilder:
                                    (
                                      context,
                                      url,
                                      downloadProgress,
                                    ) => Lottie.asset(
                                      'assets/animations/lottie/loading-image.json',
                                      width: 15,
                                    ),
                                errorWidget:
                                    (context, url, error) => Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.category,
                                        color: Colors.grey[400],
                                        size: 24,
                                      ),
                                    ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 5),
                          SizedBox(
                            width: 70,
                            child: Text(
                              subCategory.name!,
                              style: const TextStyle(fontSize: 14),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
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

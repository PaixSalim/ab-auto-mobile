import 'package:auto/products/presentation/bloc/remote/remote_product_bloc.dart';
import 'package:auto/products/presentation/bloc/remote/remote_product_event.dart';
import 'package:auto/products/presentation/bloc/remote/remote_product_state.dart';
import 'package:auto/products/presentation/widgets/ProductGridCard.dart';
import 'package:auto/products/presentation/widgets/MultiSelectFilterModal.dart';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProductCatalogPage extends StatefulWidget {
  const ProductCatalogPage({super.key});

  @override
  ProductCatalogPageState createState() => ProductCatalogPageState();
}

class ProductCatalogPageState extends State<ProductCatalogPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _scrollController = ScrollController();

  // Variables pour les filtres et tri
  String _selectedSortOption = 'name';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      context.read<RemoteProductsBloc>().add(const LoadMoreProducts());
    }
  }

  void openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      key: _scaffoldKey,
      body: Column(
        children: [
          // En-tête avec filtres et tri
          BlocBuilder<RemoteProductsBloc, RemoteProductState>(
            builder: (context, state) {
              if (state is RemoteProductsDone) {
                final currentState = state;
                return _buildHeader(context, currentState);
              }
              return const SizedBox.shrink();
            },
          ),
          // Contenu principal
          Expanded(
            child: BlocBuilder<RemoteProductsBloc, RemoteProductState>(
              builder: (context, state) {
                if (state is RemoteProductsDone) {
                  return state.displayedProducts!.isNotEmpty
                      ? RefreshIndicator(
                        onRefresh: () async {
                          context.read<RemoteProductsBloc>().add(
                            const RefreshProducts(),
                          );
                        },
                        child: GridView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(12),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                                childAspectRatio: 0.90,
                              ),
                          itemCount:
                              state.displayedProducts!.length +
                              (state.hasNextPage ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index >= state.displayedProducts!.length) {
                              return Center(
                                child:
                                    state.isLoadingMore
                                        ? const CupertinoActivityIndicator()
                                        : const SizedBox.shrink(),
                              );
                            }
                            return ProductGridCard(
                              product: state.displayedProducts![index],
                              index:
                                  index, // Passer l'index pour le tag Hero unique
                            );
                          },
                        ),
                      )
                      : Center(
                        child: const Text(
                          'Aucun produit ne correspond à ce filtre',
                        ),
                      );
                }
                if (state is RemoteProductsLoading) {
                  return Center(child: CupertinoActivityIndicator());
                }
                if (state is RemoteProductsError) {
                  return Center(
                    child: Text('Veuillez bien vouloir redémarrer l\'app svp'),
                  );
                }

                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }

  // Widget pour construire l'en-tête avec filtres
  Widget _buildHeader(BuildContext context, RemoteProductsDone state) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.7),
            border: Border(
              bottom: BorderSide(
                color: Colors.white.withValues(alpha: 0.5),
                width: 1,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 10,
            bottom: 12,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ligne des boutons déroulants (Filtres)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _buildDropdownFilter(
                      context,
                      title: 'Marque',
                      allOptions: state.availableBrands,
                      selectedOptions: state.selectedBrands,
                      onApply: (selected) {
                        context.read<RemoteProductsBloc>().add(
                          UpdateSpecificFilter(selectedBrands: selected),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    _buildDropdownFilter(
                      context,
                      title: 'Modèle',
                      allOptions: state.availableModels,
                      selectedOptions: state.selectedModels,
                      onApply: (selected) {
                        context.read<RemoteProductsBloc>().add(
                          UpdateSpecificFilter(selectedModels: selected),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    _buildDropdownFilter(
                      context,
                      title: 'Année',
                      allOptions: state.availableYears,
                      selectedOptions: state.selectedYears,
                      onApply: (selected) {
                        context.read<RemoteProductsBloc>().add(
                          UpdateSpecificFilter(selectedYears: selected),
                        );
                      },
                    ),
                    // L'utilisateur avait d'autres filtres dans la maquette, on peut les ajouter plus tard si besoin
                  ],
                ),
              ),

              // Ligne des filtres actifs (Chips)
              _buildActiveFilters(context, state),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownFilter(
    BuildContext context, {
    required String title,
    required List<String> allOptions,
    required List<String> selectedOptions,
    required Function(List<String>) onApply,
  }) {
    final primaryColor = Theme.of(context).primaryColor;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: primaryColor.withValues(alpha: 0.2)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            showDialog(
              context: context,
              builder:
                  (context) => Dialog(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: MultiSelectFilterModal(
                      title: title,
                      allOptions: allOptions,
                      selectedOptions: selectedOptions,
                      onApply: onApply,
                    ),
                  ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: primaryColor,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(width: 6),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 20,
                  color: primaryColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget pour afficher les filtres actifs sous forme de chips
  Widget _buildActiveFilters(BuildContext context, RemoteProductsDone state) {
    final activeFilters = <Map<String, String>>[];

    for (var brand in state.selectedBrands) {
      activeFilters.add({'type': 'brand', 'value': brand});
    }
    for (var model in state.selectedModels) {
      activeFilters.add({'type': 'model', 'value': model});
    }
    for (var year in state.selectedYears) {
      activeFilters.add({'type': 'year', 'value': year});
    }

    if (activeFilters.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            Text(
              'Suppri...',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            const SizedBox(width: 8),
            ...activeFilters.map((filter) {
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).primaryColor.withValues(alpha: 0.3),
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        filter['value']!,
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 4),
                      InkWell(
                        onTap: () {
                          context.read<RemoteProductsBloc>().add(
                            RemoveFilter(filter['type']!, filter['value']!),
                          );
                        },
                        child: Icon(
                          Icons.close,
                          size: 16,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  // Widget pour les options de tri
  Widget _buildSortOptions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Trier par:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _buildSortChip(context, 'name', 'Nom', Icons.sort_by_alpha),
              _buildSortChip(
                context,
                'price_low',
                'Prix croissant',
                Icons.arrow_upward,
              ),
              _buildSortChip(
                context,
                'price_high',
                'Prix décroissant',
                Icons.arrow_downward,
              ),
              _buildSortChip(
                context,
                'newest',
                'Nouveautés',
                Icons.new_releases,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSortChip(
    BuildContext context,
    String value,
    String label,
    IconData icon,
  ) {
    final isSelected = _selectedSortOption == value;
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: isSelected ? Colors.white : null),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedSortOption = value;
        });
        _applySorting(context);
      },
      backgroundColor: isSelected ? Theme.of(context).primaryColor : null,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : null,
        fontSize: 12,
      ),
    );
  }

  void _applySorting(BuildContext context) {
    final bloc = context.read<RemoteProductsBloc>();

    switch (_selectedSortOption) {
      case 'name':
        bloc.add(const SortByAlphabet(true));
        break;
      case 'price_low':
        bloc.add(const SortByPrice(true));
        break;
      case 'price_high':
        bloc.add(const SortByPrice(false));
        break;
      case 'newest':
        bloc.add(const SortByNewest());
        break;
    }
  }
}

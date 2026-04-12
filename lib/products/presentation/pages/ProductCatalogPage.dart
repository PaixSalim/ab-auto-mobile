import 'package:auto/products/presentation/bloc/remote/remote_product_bloc.dart';
import 'package:auto/products/presentation/bloc/remote/remote_product_event.dart';
import 'package:auto/products/presentation/bloc/remote/remote_product_state.dart';
import 'package:auto/products/presentation/widgets/ProductGridCard.dart';
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
  String _selectedSortOption = 'name'; // 'name', 'price_low', 'price_high', 'newest'
  bool _showFilters = false;

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
                            context.read<RemoteProductsBloc>().add(const RefreshProducts());
                          },
                          child: GridView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.all(12),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              childAspectRatio: 0.65,
                            ),
                            itemCount: state.displayedProducts!.length + (state.hasNextPage ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index >= state.displayedProducts!.length) {
                                return Center(
                                  child: state.isLoadingMore
                                        ? const CupertinoActivityIndicator()
                                        : const SizedBox.shrink(),
                                );
                              }
                              return ProductGridCard(
                                product: state.displayedProducts![index],
                                index: index, // Passer l'index pour le tag Hero unique
                              );
                            },
                          ),
                        )
                      : Center(child: const Text('Aucun produit ne correspond à ce filtre'));
                }
                if (state is RemoteProductsLoading) {
                  return Center(child: CupertinoActivityIndicator());
                }
                if (state is RemoteProductsError) {
                  return Center(child: Text('Veuillez bien vouloir redémarrer l\'app svp'));
                }

                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }

  // Widget pour construire l'en-tête avec filtres et tri
  Widget _buildHeader(BuildContext context, RemoteProductsDone state) {
    final hasActiveFilters = state.selectedCategories.isNotEmpty || 
                           state.selectedSubCategories.isNotEmpty || 
                           state.selectedBrands.isNotEmpty ||
                           state.minPrice > 0 ||
                           state.maxPrice < 50000000 ||
                           state.isNew ||
                           state.isUsed;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titre et filtres actifs
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Catalogue',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (hasActiveFilters)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Filtres actifs',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              // Bouton pour afficher/cacher les filtres
              IconButton(
                onPressed: () {
                  setState(() {
                    _showFilters = !_showFilters;
                  });
                },
                icon: Icon(
                  _showFilters ? Icons.filter_list_off : Icons.filter_list,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              // Bouton de rafraîchissement forcé
              IconButton(
                onPressed: () {
                  context.read<RemoteProductsBloc>().add(const RefreshProducts());
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Actualisation des produits en cours...'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                icon: Icon(
                  Icons.refresh,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
          
          // Section des filtres (affichée si _showFilters est true)
          if (_showFilters) ...[
            const SizedBox(height: 16),
            
            // Filtres actifs
            if (hasActiveFilters) ...[
              _buildActiveFilters(context, state),
              const SizedBox(height: 12),
            ],
            
            // Options de tri
            _buildSortOptions(context),
            const SizedBox(height: 12),
            
            // Boutons d'action
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      context.read<RemoteProductsBloc>().add(const ResetProductFilter());
                      setState(() {
                        _selectedSortOption = 'name';
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Réinitialiser'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _applyFilters(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Appliquer'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // Widget pour afficher les filtres actifs
  Widget _buildActiveFilters(BuildContext context, RemoteProductsDone state) {
    final filters = <String>[];
    
    if (state.selectedCategories.isNotEmpty) {
      filters.add('Catégories: ${state.selectedCategories.length}');
    }
    if (state.selectedSubCategories.isNotEmpty) {
      filters.add('Sous-catégories: ${state.selectedSubCategories.length}');
    }
    if (state.selectedBrands.isNotEmpty) {
      filters.add('Marques: ${state.selectedBrands.length}');
    }
    if (state.minPrice > 0 || state.maxPrice < 50000000) {
      filters.add('Prix: ${state.minPrice.toInt()} - ${state.maxPrice.toInt()}');
    }
    if (state.isNew) { filters.add('Nouveaux'); }
    if (state.isUsed) { filters.add('Occasions'); }

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
            'Filtres actifs:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: filters.map((filter) => Chip(
              label: Text(
                filter,
                style: const TextStyle(fontSize: 12),
              ),
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
              deleteIcon: const Icon(Icons.close, size: 16),
              onDeleted: () {
                // TODO: Implémenter la suppression individuelle de filtres
              },
            )).toList(),
          ),
        ],
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
              _buildSortChip(context, 'price_low', 'Prix croissant', Icons.arrow_upward),
              _buildSortChip(context, 'price_high', 'Prix décroissant', Icons.arrow_downward),
              _buildSortChip(context, 'newest', 'Nouveautés', Icons.new_releases),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSortChip(BuildContext context, String value, String label, IconData icon) {
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

  void _applyFilters(BuildContext context) {
    setState(() {
      _showFilters = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Filtres appliqués avec succès'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}

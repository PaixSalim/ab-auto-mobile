import 'package:auto/core/resources/data_state.dart';
import 'package:auto/products/domain/entities/product_entity.dart';
import 'package:auto/products/domain/usecases/get_product_usecase.dart';
import 'package:auto/products/presentation/bloc/remote/remote_product_state.dart';
import 'package:bloc/bloc.dart';

import 'remote_product_event.dart';

class RemoteProductsBloc extends Bloc<RemoteProductsEvent, RemoteProductState> {
  final GetProductUseCase _getProductUseCase;
  final GetProductsPaginatedUseCase _getProductsPaginatedUseCase;
  int _currentPage = 1;
  final int _limit = 20;

  RemoteProductsBloc(
    this._getProductUseCase,
    this._getProductsPaginatedUseCase,
  ) : super(const RemoteProductsLoading()) {
    on<GetProducts>(onGetProducts);
    on<SearchProducts>(_onSearchProducts);
    on<ResetProductFilter>(_onResetProductFilter);
    on<FilterProducts>(_onFilterProducts);
    on<SortByAlphabet>(_onSortByAlphabet);
    on<SortByPrice>(_onSortByPrice);
    on<SortByNewest>(_onSortByNewest);
    on<LoadMoreProducts>(_onLoadMoreProducts);
    on<RefreshProducts>(_onRefreshProducts);
  }

  Future<void> onGetProducts(
    GetProducts event,
    Emitter<RemoteProductState> emit,
  ) async {
    _currentPage = 1;
    final dataState = await _getProductsPaginatedUseCase(
      params: {'page': _currentPage, 'limit': _limit},
    );
    
    if (dataState is DataSuccess && dataState.data != null) {
      final responseData = dataState.data!;
      final products = responseData['products'] as List<ProductEntity>;
      
      emit(
        RemoteProductsDone(
          products,
          products,
          '',
          [],
          [],
          [],
          0,
          50000000,
          false,
          false,
          currentPage: responseData['page'] ?? 1,
          totalPages: responseData['totalPages'] ?? 1,
          hasNextPage: responseData['hasNextPage'] ?? false,
        ),
      );
    }

    if (dataState is DataFailed) {
      emit(RemoteProductsError(dataState.error!));
    }
  }

  void _onSearchProducts(
    SearchProducts event,
    Emitter<RemoteProductState> emit,
  ) {
    if (state is RemoteProductsDone) {
      final allProducts = (state as RemoteProductsDone).allProducts ?? [];
      final query = event.query.toLowerCase();

      final filteredProducts =
          allProducts.where((product) {
            return product.name!.toLowerCase().contains(query) ||
                product.brand!.name!.toLowerCase().contains(query) ||
                product.description!.toLowerCase().contains(query) ||
                product.category!.name!.toLowerCase().contains(query);
          }).toList();

      emit(
        RemoteProductsDone(
          allProducts,
          filteredProducts,
          query,
          [],
          [],
          [],
          0,
          50000000,
          false,
          false,
        ),
      );
    }
  }

  void _onResetProductFilter(
    ResetProductFilter event,
    Emitter<RemoteProductState> emit,
  ) {
    if (state is RemoteProductsDone) {
      final allProducts = (state as RemoteProductsDone).allProducts ?? [];
      emit(
        RemoteProductsDone(
          allProducts,
          allProducts,
          '',
          [],
          [],
          [],
          0,
          50000000,
          false,
          false,
        ),
      );
    }
  }

  void _onFilterProducts(
    FilterProducts event,
    Emitter<RemoteProductState> emit,
  ) {
    if (state is RemoteProductsDone) {
      final currentState = state as RemoteProductsDone;
      
      final filteredProducts =
          currentState.allProducts!.where((product) {
            final categoryMatch =
                event.selectedCategories.isEmpty ||
                event.selectedCategories.contains(product.category!.id);
            final subCategoryMatch =
                event.selectedSubCategories.isEmpty ||
                (product.subCategoryId != null && event.selectedSubCategories.contains(product.subCategoryId!));
            final brandMatch =
                event.selectedBrands.isEmpty ||
                (product.brand != null && event.selectedBrands.contains(product.brand!.id));
            final priceMatch =
                product.price! >= event.minPrice &&
                product.price! <= event.maxPrice;
            final stateMatch =
                (!event.isNew && !event.isUsed) ||
                (event.isNew && (product.state == 'new') ||
                    (event.isUsed && !(product.state == 'new')));

            return categoryMatch && subCategoryMatch && brandMatch && priceMatch && stateMatch;
          }).toList();

      emit(
        currentState.copyWith(
          displayedProducts: filteredProducts,
          selectedCategories: event.selectedCategories,
          selectedSubCategories: event.selectedSubCategories,
          selectedBrands: event.selectedBrands,
          minPrice: event.minPrice,
          maxPrice: event.maxPrice,
          isNew: event.isNew,
          isUsed: event.isUsed,
        ),
      );
    }
  }

  void _onSortByAlphabet(
    SortByAlphabet event,
    Emitter<RemoteProductState> emit,
  ) {
    if (state is RemoteProductsDone) {
      final currentState = state as RemoteProductsDone;

      final sortedProducts = List<ProductEntity>.from(
        currentState.displayedProducts!,
      )..sort(
        (a, b) =>
            event.ascending
                ? a.name!.compareTo(b.name!)
                : b.name!.compareTo(a.name!),
      );

      emit(currentState.copyWith(displayedProducts: sortedProducts));
    }
  }

  void _onSortByPrice(
    SortByPrice event,
    Emitter<RemoteProductState> emit,
  ) {
    if (state is RemoteProductsDone) {
      final currentState = state as RemoteProductsDone;

      final sortedProducts = List<ProductEntity>.from(
        currentState.displayedProducts!,
      )..sort(
        (a, b) => event.ascending
            ? (a.price ?? 0).compareTo(b.price ?? 0)
            : (b.price ?? 0).compareTo(a.price ?? 0),
      );

      emit(currentState.copyWith(displayedProducts: sortedProducts));
    }
  }

  void _onSortByNewest(
    SortByNewest event,
    Emitter<RemoteProductState> emit,
  ) {
    if (state is RemoteProductsDone) {
      final currentState = state as RemoteProductsDone;

      final sortedProducts = List<ProductEntity>.from(
        currentState.displayedProducts!,
      )..sort((a, b) {
        // Prioriser les produits neufs (state == 'new')
        final aIsNew = a.state == 'new';
        final bIsNew = b.state == 'new';
        
        if (aIsNew && !bIsNew) return -1;
        if (!aIsNew && bIsNew) return 1;
        
        // Si les deux sont neufs ou les deux ne sont pas neufs, trier par nom
        return a.name!.compareTo(b.name!);
      });

      emit(currentState.copyWith(displayedProducts: sortedProducts));
    }
  }

  Future<void> _onLoadMoreProducts(
    LoadMoreProducts event,
    Emitter<RemoteProductState> emit,
  ) async {
    if (state is RemoteProductsDone) {
      final currentState = state as RemoteProductsDone;
      
      if (!currentState.hasNextPage || currentState.isLoadingMore) {
        return;
      }

      emit(currentState.copyWith(isLoadingMore: true));

      _currentPage++;
      final dataState = await _getProductsPaginatedUseCase(
        params: {'page': _currentPage, 'limit': _limit},
      );

      if (dataState is DataSuccess && dataState.data != null) {
        final responseData = dataState.data!;
        final newProducts = responseData['products'] as List<ProductEntity>;
        
        final allProducts = List<ProductEntity>.from(currentState.allProducts!);
        
        // Éviter les doublons en filtrant par ID
        final existingIds = allProducts.map((p) => p.id).toSet();
        final uniqueNewProducts = newProducts.where((p) => !existingIds.contains(p.id)).toList();
        
        allProducts.addAll(uniqueNewProducts);

        // Recalculer displayedProducts en appliquant les filtres actuels
        List<ProductEntity> displayedProducts = List.from(allProducts);
        
        // Appliquer les filtres s'ils existent
        if (currentState.selectedCategories.isNotEmpty) {
          displayedProducts = displayedProducts.where((p) => 
            p.category?.id != null && currentState.selectedCategories.contains(p.category?.id)
          ).toList();
        }
        
        if (currentState.selectedBrands.isNotEmpty) {
          displayedProducts = displayedProducts.where((p) => 
            p.brand?.id != null && currentState.selectedBrands.contains(p.brand?.id)
          ).toList();
        }
        
        if (currentState.minPrice > 0) {
          displayedProducts = displayedProducts.where((p) => 
            (p.price ?? 0) >= currentState.minPrice
          ).toList();
        }
        
        if (currentState.maxPrice < 50000000) {
          displayedProducts = displayedProducts.where((p) => 
            (p.price ?? 0) <= currentState.maxPrice
          ).toList();
        }
        
        if (currentState.isNew) {
          displayedProducts = displayedProducts.where((p) => p.state == 'new').toList();
        }
        
        if (currentState.isUsed) {
          displayedProducts = displayedProducts.where((p) => p.state == 'used' || p.state == 'old').toList();
        }
        
        if (currentState.query != null && currentState.query!.isNotEmpty) {
          final query = currentState.query!.toLowerCase();
          displayedProducts = displayedProducts.where((p) => 
            (p.name?.toLowerCase().contains(query) ?? false) ||
            (p.description?.toLowerCase().contains(query) ?? false)
          ).toList();
        }

        emit(
          RemoteProductsDone(
            allProducts,
            displayedProducts, 
            currentState.query ?? '',
            currentState.selectedCategories,
            currentState.selectedSubCategories ?? [],
            currentState.selectedBrands,
            currentState.minPrice,
            currentState.maxPrice,
            currentState.isNew,
            currentState.isUsed,
            currentPage: responseData['page'] ?? _currentPage,
            totalPages: responseData['totalPages'] ?? currentState.totalPages,
            hasNextPage: responseData['hasNextPage'] ?? currentState.hasNextPage,
            isLoadingMore: false,
          ),
        );
      } else {
        _currentPage--;
        emit(currentState.copyWith(isLoadingMore: false));
      }
    }
  }

  Future<void> _onRefreshProducts(
    RefreshProducts event,
    Emitter<RemoteProductState> emit,
  ) async {
    _currentPage = 1;
    final dataState = await _getProductsPaginatedUseCase(
      params: {'page': _currentPage, 'limit': _limit},
    );
    
    if (dataState is DataSuccess && dataState.data != null) {
      final responseData = dataState.data!;
      final products = responseData['products'] as List<ProductEntity>;
      
      emit(
        RemoteProductsDone(
          products,
          products,
          '',
          [],
          [],
          [],
          0,
          50000000,
          false,
          false,
          currentPage: responseData['page'] ?? 1,
          totalPages: responseData['totalPages'] ?? 1,
          hasNextPage: responseData['hasNextPage'] ?? false,
        ),
      );
    }

    if (dataState is DataFailed) {
      emit(RemoteProductsError(dataState.error!));
    }
  }
}

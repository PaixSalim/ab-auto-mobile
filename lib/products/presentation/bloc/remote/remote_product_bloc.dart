import 'package:auto/core/resources/data_state.dart';
import 'package:auto/products/domain/entities/product_entity.dart';
import 'package:auto/products/domain/usecases/get_product_usecase.dart';
import 'package:auto/products/presentation/bloc/remote/remote_product_state.dart';
import 'package:bloc/bloc.dart';

import 'remote_product_event.dart';

class RemoteProductsBloc extends Bloc<RemoteProductsEvent, RemoteProductState> {
  final GetProductUseCase _getProductUseCase;

  RemoteProductsBloc(this._getProductUseCase)
    : super(const RemoteProductsLoading()) {
    on<GetProducts>(onGetProducts);
    on<SearchProducts>(_onSearchProducts);
    on<ResetProductFilter>(_onResetProductFilter);
    on<FilterProducts>(_onFilterProducts);
    on<SortByAlphabet>(_onSortByAlphabet);
  }

  Future<void> onGetProducts(
    GetProducts event,
    Emitter<RemoteProductState> emit,
  ) async {
    final dataState = await _getProductUseCase();
    if (dataState is DataSuccess && dataState.data!.isNotEmpty) {
      emit(
        RemoteProductsDone(
          dataState.data!,
          dataState.data!,
          '',
          [],
          [],
          0,
          50000000,
          false,
          false,
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
            final brandMatch =
                event.selectedBrands.isEmpty ||
                event.selectedBrands.contains(product.brand!.id);
            final priceMatch =
                product.price! >= event.minPrice &&
                product.price! <= event.maxPrice;
            final stateMatch =
                (!event.isNew && !event.isUsed) ||
                (event.isNew && (product.state == 'new') ||
                    (event.isUsed && !(product.state == 'new')));

            return categoryMatch && brandMatch && priceMatch && stateMatch;
          }).toList();

      emit(
        currentState.copyWith(
          displayedProducts: filteredProducts,
          selectedCategories: event.selectedCategories,
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
}

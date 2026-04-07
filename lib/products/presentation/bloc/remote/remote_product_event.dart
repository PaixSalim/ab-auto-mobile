abstract class RemoteProductsEvent {
  const RemoteProductsEvent();
}

class GetProducts extends RemoteProductsEvent {
  const GetProducts();
}

class SearchProducts extends RemoteProductsEvent {
  final String query;
  SearchProducts(this.query);
}

class FilterProducts extends RemoteProductsEvent {
  final List<String> selectedCategories;
  final List<String> selectedBrands;
  final double minPrice;
  final double maxPrice;
  final bool isNew;
  final bool isUsed;

  const FilterProducts({
    required this.selectedCategories,
    required this.selectedBrands,
    required this.minPrice,
    required this.maxPrice,
    required this.isNew,
    required this.isUsed,
  });
}

class SortByAlphabet extends RemoteProductsEvent {
  final bool ascending;
  const SortByAlphabet(this.ascending);
}

class ResetProductFilter extends RemoteProductsEvent {
  const ResetProductFilter();
}

class LoadMoreProducts extends RemoteProductsEvent {
  const LoadMoreProducts();
}

class RefreshProducts extends RemoteProductsEvent {
  const RefreshProducts();
}

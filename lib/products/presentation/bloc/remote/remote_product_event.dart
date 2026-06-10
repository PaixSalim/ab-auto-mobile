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
  final List<String> selectedSubCategories;
  final List<String> selectedBrands;
  final List<String> selectedModels;
  final List<String> selectedYears;
  final double minPrice;
  final double maxPrice;
  final bool isNew;
  final bool isUsed;

  const FilterProducts({
    required this.selectedCategories,
    this.selectedSubCategories = const [],
    required this.selectedBrands,
    this.selectedModels = const [],
    this.selectedYears = const [],
    required this.minPrice,
    required this.maxPrice,
    required this.isNew,
    required this.isUsed,
  });
}

class UpdateSpecificFilter extends RemoteProductsEvent {
  final List<String>? selectedBrands;
  final List<String>? selectedModels;
  final List<String>? selectedYears;
  
  const UpdateSpecificFilter({
    this.selectedBrands,
    this.selectedModels,
    this.selectedYears,
  });
}

class RemoveFilter extends RemoteProductsEvent {
  final String filterType; // 'brand', 'model', 'year'
  final String value;
  const RemoveFilter(this.filterType, this.value);
}

class SortByAlphabet extends RemoteProductsEvent {
  final bool ascending;
  const SortByAlphabet(this.ascending);
}

class SortByPrice extends RemoteProductsEvent {
  final bool ascending;
  const SortByPrice(this.ascending);
}

class SortByNewest extends RemoteProductsEvent {
  const SortByNewest();
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

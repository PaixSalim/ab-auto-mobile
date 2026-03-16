import 'package:auto/brands/domain/entities/brand_entity.dart';
import 'package:auto/brands/presentation/bloc/remote/remote_brand_bloc.dart';
import 'package:auto/categories/domain/entities/category_entity.dart';
import 'package:auto/categories/presentation/bloc/remote/remote_category_bloc.dart';
import 'package:auto/products/presentation/bloc/remote/remote_product_bloc.dart';
import 'package:auto/products/presentation/bloc/remote/remote_product_event.dart';
import 'package:auto/products/presentation/bloc/remote/remote_product_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FilterDrawer extends StatefulWidget {
  @override
  _FilterDrawerState createState() => _FilterDrawerState();
}

class _FilterDrawerState extends State<FilterDrawer> {
  Map<String, bool> selectedCategories = {};
  Map<String, bool> selectedBrands = {};
  double _minPrice = 0;
  double _maxPrice = 50000000;
  bool isNew = false;
  bool isUsed = false;

  @override
  void initState() {
    super.initState();
    // Récupérer l'état actuel du BLoC lors de l'ouverture du filtre
    final state = context.read<RemoteProductsBloc>().state;
    if (state is RemoteProductsDone) {
      setState(() {
        selectedCategories = {
          for (var id in state.selectedCategories) id.toString(): true,
        };
        selectedBrands = {
          for (var id in state.selectedBrands) id.toString(): true,
        };
        _minPrice = state.minPrice;
        _maxPrice = state.maxPrice;
        isNew = state.isNew;
        isUsed = state.isUsed;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ListView(
                shrinkWrap: true,
                children: [
                  _buildSectionTitle("Catégorie"),
                  BlocBuilder<RemoteCategoryBloc, RemoteCategoryState>(
                    builder: (context, state) {
                      if (state is RemoteCategoryLoading) {
                        return CupertinoActivityIndicator();
                      }
                      if (state is RemoteCategoryDone) {
                        return _buildCheckboxCategoryList(
                          state.categories!,
                          selectedCategories,
                          (id, value) {
                            setState(() {
                              selectedCategories[id.toString()] = value!;
                              //context.read<RemoteProductsBloc>().add(ShortByCategory(id),);
                            });
                          },
                        );
                      }
                      return Text(
                        'Aucune catégorie de tri disponible pour le moment',
                      );
                    },
                  ),

                  Divider(),
                  _buildSectionTitle("Marque"),
                  BlocBuilder<RemoteBrandBloc, RemoteBrandState>(
                    builder: (context, state) {
                      if (state is RemoteBrandLoading) {
                        return CupertinoActivityIndicator();
                      }
                      if (state is RemoteBrandDone) {
                        return _buildCheckboxBrandList(
                          state.brands!,
                          selectedBrands,
                          (id, value) {
                            setState(() {
                              selectedBrands[id.toString()] = value!;
                            });
                          },
                        );
                      }
                      return Text(
                        'Aucune marque de tri disponible pour le moment',
                      );
                    },
                  ),
                  Divider(),

                  _buildSectionTitle("État"),
                  _buildCheckboxTile("Neuf", isNew, (value) {
                    setState(() {
                      isNew = value!;
                    });
                  }),
                  _buildCheckboxTile("Occasion", isUsed, (value) {
                    setState(() {
                      isUsed = value!;
                    });
                  }),

                  _buildSectionTitle("Prix"),
                  Slider(
                    value: _maxPrice,
                    min: 0,
                    max: 50000000,
                    divisions: 100,
                    label: _maxPrice.toStringAsFixed(0),
                    activeColor: Theme.of(context).primaryColor,
                    onChanged: (value) {
                      setState(() {
                        _maxPrice = value;
                      });
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${_minPrice.toInt()} Fcfa",
                        style: TextStyle(fontSize: 14),
                      ),
                      Text(
                        "${_maxPrice.toInt()} Fcfa",
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                  Divider(),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      minimumSize: Size(double.infinity, 40),
                      padding: EdgeInsets.symmetric(vertical: 10),
                    ).copyWith(
                      shape: WidgetStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    onPressed: () {
                      final selectedCategoryIds =
                          selectedCategories.entries
                              .where((entry) => entry.value)
                              .map((entry) => int.parse(entry.key))
                              .toList();

                      final selectedBrandIds =
                          selectedBrands.entries
                              .where((entry) => entry.value)
                              .map((entry) => int.parse(entry.key))
                              .toList();

                      context.read<RemoteProductsBloc>().add(
                        FilterProducts(
                          selectedCategories: selectedCategoryIds,
                          selectedBrands: selectedBrandIds,
                          minPrice: _minPrice,
                          maxPrice: _maxPrice,
                          isNew: isNew,
                          isUsed: isUsed,
                        ),
                      );

                      Navigator.pop(context);
                    },
                    child: Text(
                      "Appliquer les filtres",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  SizedBox(height: 5),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Text(
        title,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildCheckboxCategoryList(
    List<CategoryEntity> items,
    Map<String, bool> selectedItems,
    Function(int, bool?) onChanged,
  ) {
    return Column(
      children:
          items.map((item) {
            return _buildCheckboxTile(
              item.name ?? "N/A",
              selectedItems[item.id.toString()] ?? false,
              (value) {
                onChanged(item.id!, value);
              },
            );
          }).toList(),
    );
  }

  Widget _buildCheckboxBrandList(
    List<BrandEntity> brands,
    Map<String, bool> selectedItems,
    Function(int, bool?) onChanged,
  ) {
    return Column(
      children:
          brands.map((item) {
            return _buildCheckboxTile(
              item.name ?? "N/A",
              selectedItems[item.id.toString()] ?? false,
              (value) {
                onChanged(item.id!, value);
              },
            );
          }).toList(),
    );
  }

  Widget _buildCheckboxTile(
    String title,
    bool value,
    Function(bool?) onChanged,
  ) {
    return CheckboxListTile(
      dense: true,
      activeColor: Theme.of(context).primaryColor,
      visualDensity: VisualDensity.compact,
      title: Text(title, style: TextStyle(fontSize: 14)),
      value: value,
      onChanged: onChanged,
    );
  }
}

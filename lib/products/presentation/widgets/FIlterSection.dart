import 'package:auto/products/presentation/bloc/remote/remote_product_bloc.dart';
import 'package:auto/products/presentation/bloc/remote/remote_product_event.dart';
import 'package:auto/products/presentation/bloc/remote/remote_product_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';

class FilterSection extends StatelessWidget {
  final VoidCallback openDrawer;

  const FilterSection({super.key, required this.openDrawer});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RemoteProductsBloc, RemoteProductState>(
      builder: (context, state) {
        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(
                        color: Colors.grey.shade300, // Couleur de la bordure
                        width: 1, // Épaisseur de la bordure
                      ),
                    ),
                  ),
                  onPressed: openDrawer,
                  icon: Icon(Icons.filter_alt_outlined, color: Colors.black),
                  label: Row(
                    children: [
                      Text("Filtres ", style: TextStyle(color: Colors.black)),
                      if (state is RemoteProductsDone)
                        Text(
                          (state.selectedCategories.length +
                                  state.selectedBrands.length +
                                  (state.isNew ? 1 : 0) +
                                  (state.isUsed ? 1 : 0) +
                                  (state.maxPrice != 50000000 ? 1 : 0))
                              .toString(),
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: Colors.grey.shade300, width: 1),
                    ),
                  ),
                  onPressed: () {
                    context.read<RemoteProductsBloc>().add(
                      SortByAlphabet(true),
                    );
                  },
                  icon: Icon(
                    LucideIcons.arrowDownAZ,
                    color: Colors.black.withValues(alpha: 0.6),
                  ),
                ),
                IconButton(
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: Colors.grey.shade300, width: 1),
                    ),
                  ),
                  onPressed: () {
                    context.read<RemoteProductsBloc>().add(
                      SortByAlphabet(false),
                    );
                  },
                  icon: Icon(
                    LucideIcons.arrowUpAZ,
                    color: Colors.black.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

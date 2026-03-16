import 'package:auto/products/presentation/bloc/remote/remote_product_bloc.dart';
import 'package:auto/products/presentation/bloc/remote/remote_product_event.dart';
import 'package:auto/products/presentation/bloc/remote/remote_product_state.dart';
import 'package:auto/products/presentation/widgets/FIlterSection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SearchAndFilterSection extends StatelessWidget {
  final VoidCallback openDrawer;
  const SearchAndFilterSection({super.key, required this.openDrawer});

  @override
  Widget build(BuildContext context) {
    final TextEditingController textEditingController = TextEditingController();
    final bloc = context.read<RemoteProductsBloc>();
    textEditingController.text = bloc.state.searchValue ?? '';
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          BlocBuilder<RemoteProductsBloc, RemoteProductState>(
            builder: (context, state) {
              return TextField(
                onChanged: (value) {
                  bloc.add(SearchProducts(value));
                },
                controller: textEditingController,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  suffixIcon:
                      state.searchValue != ""
                          ? IconButton(
                            onPressed: () {
                              bloc.add(ResetProductFilter());
                              textEditingController.clear();
                            },
                            icon: Icon(Icons.close, color: Colors.grey),
                          )
                          : null,
                  hintText: "Rechercher une pièce, marque ...",
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 15),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.9),
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
              );
            },
          ),
          SizedBox(height: 3),
          FilterSection(openDrawer: openDrawer),
        ],
      ),
    );
  }
}

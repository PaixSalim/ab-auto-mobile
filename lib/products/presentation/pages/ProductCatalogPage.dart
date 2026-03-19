import 'package:auto/products/presentation/bloc/remote/remote_product_bloc.dart';
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

  void openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: BlocBuilder<RemoteProductsBloc, RemoteProductState>(
            builder: (context, state) {
              if (state is RemoteProductsDone) {
                return state.displayedProducts!.isNotEmpty
                    ? GridView.builder(
                      padding: const EdgeInsets.all(12),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 0.65, // Adjust this ratio as needed
                      ),
                      itemCount: state.displayedProducts!.length,
                      itemBuilder: (context, index) {
                        return ProductGridCard(
                          product: state.displayedProducts![index],
                        );
                      },
                    )
                    : Center(child: const Text('Aucun produit ne correspond à ce filtre'));
              }
              if (state is RemoteProductsLoading) {
                return Center(child: CupertinoActivityIndicator());
              }
              if (state is RemoteProductsError) {
                return Center(child: Text('Veuillez bien vouloir rédemarrer l\'app svp'));
              }

              return SizedBox();
            },
          ),
        ),
      ],
    );
  }
}

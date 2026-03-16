import 'package:auto/products/presentation/bloc/remote/remote_product_bloc.dart';
import 'package:auto/products/presentation/bloc/remote/remote_product_state.dart';
import 'package:auto/products/presentation/widgets/FilterDrawer.dart';
import 'package:auto/products/presentation/widgets/ProductCard.dart';
import 'package:auto/products/presentation/widgets/SearchAndFilterSection.dart';
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
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          "Catalogue des produits",
          style: TextStyle(fontWeight: FontWeight.w400),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.arrow_back_ios),
        ),
      ),
      drawer: FilterDrawer(),
      body: Column(
        children: [
          SearchAndFilterSection(openDrawer: openDrawer),
          Expanded(
            child: BlocBuilder<RemoteProductsBloc, RemoteProductState>(
              builder: (context, state) {
                if (state is RemoteProductsDone) {
                  return state.displayedProducts!.isNotEmpty
                      ? ListView.builder(
                        itemCount: state.displayedProducts!.length,
                        itemBuilder: (context, index) {
                          return ProductCard(
                            product: state.displayedProducts![index],
                          );
                        },
                      )
                      : Text('Aucun produit ne correspond à ce filtre');
                }
                if (state is RemoteProductsLoading) {
                  return CupertinoActivityIndicator();
                }
                if (state is RemoteProductsError) {
                  return Text('Veuillez bien vouloir rédemarrer l\'app svp');
                }

                return SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }
}

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
  final ScrollController _scrollController = ScrollController();

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
    return Column(
      children: [
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
    );
  }
}

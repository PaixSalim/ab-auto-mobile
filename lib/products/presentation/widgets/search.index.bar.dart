import 'package:auto/products/domain/entities/product_entity.dart';
import 'package:auto/products/presentation/bloc/remote/remote_product_bloc.dart';
import 'package:auto/products/presentation/bloc/remote/remote_product_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'ActionSearchBar.dart';

class HomeSearchbar extends StatelessWidget {
  const HomeSearchbar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RemoteProductsBloc, RemoteProductState>(
      builder: (_, state) {
        final List<ProductEntity> products = [];
        if (state is RemoteProductsError) {
          return Row(
            children: [Expanded(child: ActionSearchBar(products: products))],
          );
        }
        if (state is RemoteProductsLoading) {
          return Row(
            children: [
              Expanded(child: ActionSearchBar(products: products)),
              //Brand(Brands.whatsapp),
            ],
          );
        }
        if (state is RemoteProductsDone) {
          return Row(
            children: [
              Expanded(child: ActionSearchBar(products: state.allProducts!)),
              //Brand(Brands.whatsapp),
            ],
          );
        }
        return SizedBox();
      },
    );
  }
}

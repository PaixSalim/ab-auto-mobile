import 'package:auto/products/domain/entities/product_entity.dart';
import 'package:flutter/material.dart';

import 'DeliveryDetails.dart';
import 'DescriptionDetails.dart';

class ProductTabs extends StatelessWidget {
  final ProductEntity product;
  const ProductTabs({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            tabs: [Tab(text: "Description"), Tab(text: "Livraison")],
            labelColor: Theme.of(context).primaryColor,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Theme.of(context).primaryColor,
          ),
          SizedBox(
            //
            height: product.features!.isNotEmpty ? 650 : 400,
            child: TabBarView(
              children: [
                SingleChildScrollView(
                  physics: NeverScrollableScrollPhysics(),
                  child: DescriptionDetails(product: product),
                ),
                DeliveryDetails(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:auto/products/domain/entities/product_entity.dart';
import 'package:flutter/material.dart';

class DescriptionDetails extends StatelessWidget {
  const DescriptionDetails({super.key, required this.product});

  final ProductEntity product;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 10),
          Text(
            "Description du produit",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 15),
          Text(
            product.description!.length > 600
                ? product.description!.substring(0, 600)
                : product.description!,
          ),
          SizedBox(height: 15),
          if (product.features!.isNotEmpty)
            Text("Caractéristiques", style: TextStyle(fontSize: 17)),

          if (product.features!.isNotEmpty) SizedBox(height: 10),

          if (product.features!.isNotEmpty)
            ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap:
                  true, // Le ListView ne prendra que l'espace nécessaire
              itemCount: product.features!.length,
              itemBuilder: (context, index) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.circle,
                      size: 8,
                      color: Theme.of(context).primaryColor,
                    ),
                    SizedBox(width: 8),
                    Expanded(child: Text(product.features![index])),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}

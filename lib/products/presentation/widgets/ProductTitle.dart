import 'package:auto/products/data/utils/getProductPrice.dart';
import 'package:auto/products/presentation/pages/ProductDetailPage.dart';
import 'package:flutter/material.dart';

class ProductTitle extends StatelessWidget {
  const ProductTitle({super.key, required this.widget});

  final ProductDetailPage widget;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.product.name!,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            if (widget.product.cta!.isNotEmpty)
              Text(
                widget.product.cta!,
                style: TextStyle(
                  fontSize: 22,
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            if (widget.product.cta!.isEmpty)
              Text(
                "${getProductPrice(widget.product.price!, widget.product.discount!)} Fcfa",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            SizedBox(width: 10),
            if (widget.product.discount! > 0)
              Container(
                padding: EdgeInsets.all(2),
                decoration: BoxDecoration(
                  //color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Theme.of(context).primaryColor),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Text(
                    "Prix promo",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 15),
      ],
    );
  }
}

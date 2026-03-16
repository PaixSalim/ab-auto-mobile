import 'package:auto/products/presentation/pages/ProductDetailPage.dart';
import 'package:flutter/material.dart';

class ToggleState extends StatelessWidget {
  const ToggleState({super.key, required this.widget});

  final ProductDetailPage widget;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ToggleButtons(
            borderRadius: BorderRadius.circular(8),
            isSelected: [
              widget.product.state == "new",
              !(widget.product.state == "new"),
            ],
            selectedColor: Colors.white,
            fillColor: Theme.of(context).primaryColor,
            color: Colors.black,
            children: const [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text("Neuf"),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text("Occasion"),
              ),
            ],
            onPressed: (index) {},
          ),
        ],
      ),
    );
  }
}

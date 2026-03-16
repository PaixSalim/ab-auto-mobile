import 'package:auto/comments/presentation/widgets/CommentWidget.dart';
import 'package:auto/products/domain/entities/product_entity.dart';
import 'package:auto/products/presentation/bloc/remote/remote_product_bloc.dart';
import 'package:auto/products/presentation/bloc/remote/remote_product_state.dart';
import 'package:auto/products/presentation/widgets/similar/SimilarProductsSection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/media_model.dart';
import '../widgets/ActionButtons.dart';
import '../widgets/ProductInfo.dart';
import '../widgets/ProductMediaGallery.dart';
import '../widgets/ProductTabs.dart';
import '../widgets/ProductTitle.dart';
import '../widgets/QuantitySelector.dart';
import '../widgets/ToggleState.dart';

class ProductDetailPage extends StatefulWidget {
  final ProductEntity product;

  const ProductDetailPage({super.key, required this.product});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int quantity = 1;

  @override
  Widget build(BuildContext context) {
    final List<ProductMediaModel> mediaItems =
        ProductMediaModel.parseProductMedias(widget.product.medias!);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Détail du produit"),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //ProductImages(images: widget.product.medias!),
            ProductMediaGallery(
              mediaItems: mediaItems,
              product: widget.product,
            ),

            ProductTitle(widget: widget),

            const Text(
              "État du produit :",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ToggleState(widget: widget),

            QuantitySelector(
              quantity: quantity,
              onQuantityChanged: (newQuantity) {
                setState(() {
                  quantity = newQuantity;
                });
              },
            ),

            ActionButtons(product: widget.product, quantity: quantity),

            ProductInfo(product: widget.product),

            ProductTabs(product: widget.product),

            ProductCommentsSection(productId: widget.product.id!),

            BlocBuilder<RemoteProductsBloc, RemoteProductState>(
              builder: (context, state) {
                if (state is! RemoteProductsDone) return const SizedBox();
                final similarProducts = state.allProducts!.where((p) {
                  return p.category?.id == widget.product.category?.id &&
                      p.id != widget.product.id;
                }).toList();
                if (similarProducts.isEmpty) return const SizedBox();
                return SimilarProductsSection(similarProducts: similarProducts);
              },
            ),
          ],
        ),
      ),
    );
  }
}

// 📌 Composant Description et Livraison

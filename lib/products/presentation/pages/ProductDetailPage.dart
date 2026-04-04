import 'package:auto/comments/presentation/widgets/CommentWidget.dart';
import 'package:auto/products/domain/entities/product_entity.dart';
import 'package:auto/products/presentation/bloc/remote/remote_product_bloc.dart';
import 'package:auto/products/presentation/bloc/remote/remote_product_state.dart';
import 'package:auto/products/presentation/widgets/similar/SimilarProductsSection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Import des nouveaux widgets modernes
import '../widgets/ProductBreadcrumb.dart';
import '../widgets/ModernProductGallery.dart';
import '../widgets/ProductPriceSection.dart';
import '../widgets/ProductStateSelector.dart';
import '../widgets/ProductActionButtons.dart';
import '../widgets/ProductAdditionalInfo.dart';
import '../widgets/ProductDetailTabs.dart';

class ProductDetailPage extends StatefulWidget {
  final ProductEntity product;

  const ProductDetailPage({super.key, required this.product});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  String? selectedState = 'new';
  int quantity = 1;

  @override
  Widget build(BuildContext context) {
    // Debug logs pour vérifier les données du produit
    print('=== PRODUCT DETAIL PAGE DEBUG ===');
    print('Product ID: ${widget.product.id}');
    print('Product name: ${widget.product.name}');
    print('Product category: ${widget.product.category?.name}');
    print('Product brand: ${widget.product.brand?.name}');
    print('Product seller: ${widget.product.seller?.fullName}');
    print('Product medias count: ${widget.product.medias?.length}');
    print('=====================================');

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text("Détail du produit"),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Breadcrumb
            ProductBreadcrumb(product: widget.product),
            
            // Main content container
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Gallery and info in a responsive layout
                  LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth > 800) {
                        // Desktop layout
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 2,
                              child: ModernProductGallery(product: widget.product),
                            ),
                            const SizedBox(width: 32),
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ProductPriceSection(product: widget.product),
                                  ProductStateSelector(
                                    initialState: selectedState,
                                    onStateChanged: (state) {
                                      setState(() {
                                        selectedState = state;
                                      });
                                    },
                                  ),
                                  ProductActionButtons(
                                    product: widget.product,
                                    selectedState: selectedState,
                                    quantity: quantity,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      } else {
                        // Mobile layout
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ModernProductGallery(product: widget.product),
                            const SizedBox(height: 24),
                            ProductPriceSection(product: widget.product),
                            ProductStateSelector(
                              initialState: selectedState,
                              onStateChanged: (state) {
                                setState(() {
                                  selectedState = state;
                                });
                              },
                            ),
                            ProductActionButtons(
                              product: widget.product,
                              selectedState: selectedState,
                              quantity: quantity,
                            ),
                          ],
                        );
                      }
                    },
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Additional info
                  ProductAdditionalInfo(product: widget.product),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Tabs
            ProductDetailTabs(product: widget.product),
            
            const SizedBox(height: 24),
            
            // Comments section - utilise directement l'UUID en String
            ProductCommentsSection(productId: widget.product.id ?? ''),
            
            // Similar products
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

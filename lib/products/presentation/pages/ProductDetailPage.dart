import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:auto/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

import 'package:icons_plus/icons_plus.dart';

import 'package:auto/auth/presentation/widgets/auth_bottom_sheet.dart';
import 'package:auto/products/domain/entities/product_entity.dart';
import 'package:auto/products/presentation/bloc/remote/remote_product_bloc.dart';
import 'package:auto/products/presentation/bloc/remote/remote_product_state.dart';
import 'package:auto/comments/presentation/widgets/CommentWidget.dart';
import 'package:auto/products/presentation/widgets/similar/SimilarProductsSection.dart';
import 'package:auto/promotions/presentation/bloc/remote/remote_promoted_product_bloc.dart';

class ProductDetailPage extends StatefulWidget {
  final ProductEntity product;

  const ProductDetailPage({super.key, required this.product});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int _currentImageIndex = 0;

  double _getRealPrice(double price, double? discount) {
    if (discount == null || discount == 0) return price;
    return price * (1 - discount / 100);
  }

  String _formatPrice(double price) {
    return '${price.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]} ')} Fcfa';
  }

  bool _isValidCta(String? cta) {
    if (cta == null || cta.trim().isEmpty) return false;
    final lower = cta.toLowerCase().trim();
    if (lower == 'none' || lower == 'null') return false;
    return true;
  }

  Future<void> _handleDiscuss() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      _launchWhatsApp();
    } else {
      AuthBottomSheet.show(
        context,
        message:
            'Vous devez être connecté pour contacter le vendeur et discuter de ce produit sur WhatsApp.',
        onSuccess: () {
          _launchWhatsApp();
        },
      );
    }
  }

  Future<void> _launchWhatsApp() async {
    final sellerPhone = widget.product.seller?.phone ?? '22607513333';
    final stateStr = widget.product.state == 'used' ? 'Occasion' : 'Neuf';
    final message = Uri.encodeComponent(
      'Bonjour, je suis intéressé(e) par votre produit "${widget.product.name ?? 'ce produit'}".\n'
      'État: $stateStr.\n'
      'Pourriez-vous me donner plus d\'informations ?',
    );

    final url = 'https://wa.me/$sellerPhone?text=$message';

    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Impossible d\'ouvrir WhatsApp')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors de l\'ouverture de WhatsApp'),
          ),
        );
      }
    }
  }

  Future<void> _shareProduct() async {
    final productUrl = 'https://ab-autox.com/products/${widget.product.id}';
    final playStoreLink =
        'https://play.google.com/store/apps/details?id=com.abautoxapp.mobile&pcampaignid=web_share';
    final shareText =
        'Découvre ce produit sur AB Auto : ${widget.product.name}\n\n'
        'Lien du produit: $productUrl\n\n'
        'Télécharge notre application sur le Play Store :\n$playStoreLink';

    try {
      await Share.share(shareText);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Erreur lors du partage')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final medias = widget.product.medias ?? [];

    double activeDiscount = widget.product.discount ?? 0.0;
    try {
      final promoState = context.watch<RemotePromotedProductBloc>().state;
      if (promoState is RemotePromotedProductDone &&
          promoState.promotedProducts != null) {
        final activePromo = promoState.promotedProducts!.firstWhere(
          (promo) => promo.productId == widget.product.id,
        );
        if (activePromo.discountPercent != null) {
          activeDiscount =
              double.tryParse(activePromo.discountPercent!) ?? activeDiscount;
        }
      }
    } catch (_) {}

    final hasDiscount = activeDiscount > 0;
    final realPrice = _getRealPrice(widget.product.price ?? 0, activeDiscount);
    final hasCta = _isValidCta(widget.product.cta);
    final isUsed = widget.product.state == 'used';

    return Scaffold(
      backgroundColor: const Color(
        0xFFF9FAFB,
      ), // Un gris très clair pour faire ressortir les cartes blanches
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1, // Léger shadow au scroll
        iconTheme: const IconThemeData(color: Colors.black87),
        title: const Text(
          "Détail du produit",
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.ios_share_rounded,
              color: Colors.black87,
              size: 22,
            ),
            onPressed: _shareProduct,
          ),
          const SizedBox(width: 8),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(hasCta, realPrice),
      body: CustomScrollView(
        slivers: [
          // 1. Galerie d'images dans un container stylisé (BoxAdapter)
          SliverToBoxAdapter(
            child: Container(
              height: 240,
              margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: _buildImageGallery(medias, hasDiscount, activeDiscount),
            ),
          ),

          // 2. Main Info Section (Titre, Prix, Badges)
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              padding: const EdgeInsets.all(16), // Réduction de 24 à 16
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // État et Garantie en haut
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color:
                              isUsed
                                  ? const Color(0xFFFFF7ED)
                                  : Theme.of(
                                    context,
                                  ).primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color:
                                isUsed
                                    ? const Color(0xFFF97316)
                                    : Theme.of(context).primaryColor,
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          isUsed ? 'Occasion' : 'Neuf',
                          style: TextStyle(
                            color:
                                isUsed
                                    ? const Color(0xFFC2410C)
                                    : Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      if (widget.product.warranty != null &&
                          widget.product.warranty!.trim().isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0FDF4),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.shield_rounded,
                                color: Color(0xFF15803D),
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Garantie: ${widget.product.warranty!}',
                                style: const TextStyle(
                                  color: Color(0xFF15803D),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12), // Réduit de 16 à 12
                  // Titre du produit
                  Text(
                    widget.product.name ?? 'Produit sans nom',
                    style: const TextStyle(
                      fontSize: 20, // Légèrement plus petit
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF111827),
                      height: 1.3,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 10), // Réduit de 16 à 10
                  // Prix
                  if (hasCta)
                    Text(
                      widget.product.cta!,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: Theme.of(context).primaryColor,
                      ),
                    )
                  else
                    Wrap(
                      // Utilisation de Wrap au lieu de Row pour éviter les dépassements d'écran
                      crossAxisAlignment: WrapCrossAlignment.end,
                      spacing: 12,
                      runSpacing: 4,
                      children: [
                        Text(
                          _formatPrice(realPrice),
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: Theme.of(context).primaryColor,
                            letterSpacing: -0.5,
                          ),
                        ),
                        if (hasDiscount)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4.0),
                            child: Text(
                              _formatPrice(widget.product.price ?? 0),
                              style: const TextStyle(
                                fontSize: 16,
                                color: Color(0xFF9CA3AF),
                                decoration: TextDecoration.lineThrough,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                ],
              ),
            ),
          ),

          // 3. Spécifications (Marque, Modèle, Année)
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Caractéristiques',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildSpecsGrid(),
                ],
              ),
            ),
          ),

          // 4. Description
          if (widget.product.description != null &&
              widget.product.description!.trim().isNotEmpty)
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.product.description!,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF4B5563),
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // 5. Sections Vendeur & Livraison (Expansion Tiles)
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Column(
                  children: [
                    Theme(
                      data: Theme.of(
                        context,
                      ).copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        tilePadding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 8,
                        ),
                        title: const Text(
                          'Informations du vendeur',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: Color(0xFF111827),
                          ),
                        ),
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.storefront_rounded,
                            color: Theme.of(context).primaryColor,
                            size: 20,
                          ),
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                            child: _buildSellerInfo(),
                          ),
                        ],
                      ),
                    ),
                    const Divider(
                      height: 1,
                      indent: 24,
                      endIndent: 24,
                      color: Color(0xFFE5E7EB),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 6. Commentaires
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: ProductCommentsSection(productId: widget.product.id ?? ''),
            ),
          ),

          // 7. Produits similaires
          SliverToBoxAdapter(
            child: BlocBuilder<RemoteProductsBloc, RemoteProductState>(
              builder: (context, state) {
                if (state is! RemoteProductsDone) return const SizedBox();
                var similarProducts =
                    state.allProducts!.where((p) {
                      final sameCategory =
                          p.category?.id != null &&
                          p.category?.id == widget.product.category?.id;
                      final sameBrand =
                          p.brand?.id != null &&
                          p.brand?.id == widget.product.brand?.id;
                      return (sameCategory || sameBrand) &&
                          p.id != widget.product.id;
                    }).toList();

                if (similarProducts.isEmpty && state.allProducts!.length > 1) {
                  final fallbackList = List.of(state.allProducts!);
                  fallbackList.shuffle();
                  similarProducts =
                      fallbackList
                          .where((p) => p.id != widget.product.id)
                          .take(6)
                          .toList();
                }

                if (similarProducts.isEmpty) return const SizedBox();
                return Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: SimilarProductsSection(
                    similarProducts: similarProducts,
                  ),
                );
              },
            ),
          ),

          // Espace en bas pour ne pas cacher le contenu sous la BottomNavigationBar
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
    );
  }

  // ==== Widgets Extrait ====

  Widget _buildImageGallery(
    List<String> medias,
    bool hasDiscount,
    double activeDiscount,
  ) {
    if (medias.isEmpty) {
      return Container(
        color: const Color(0xFFF3F4F6),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.image_not_supported_outlined,
                size: 48,
                color: Color(0xFF9CA3AF),
              ),
              SizedBox(height: 12),
              Text("Aucune image", style: TextStyle(color: Color(0xFF6B7280))),
            ],
          ),
        ),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        PageView.builder(
          itemCount: medias.length,
          onPageChanged: (index) {
            setState(() {
              _currentImageIndex = index;
            });
          },
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () => _showLightbox(medias, index),
              child: Image.network(
                medias[index],
                fit: BoxFit.cover,
                errorBuilder:
                    (c, e, s) => Container(
                      color: const Color(0xFFF3F4F6),
                      child: const Center(
                        child: Icon(
                          Icons.broken_image_outlined,
                          size: 48,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                    ),
              ),
            );
          },
        ),
        // Gradient pour faire ressortir les points
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: 60,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Colors.black.withOpacity(0.4), Colors.transparent],
              ),
            ),
          ),
        ),
        // Indicateur de page (Dots)
        if (medias.length > 1)
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                medias.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentImageIndex == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color:
                        _currentImageIndex == index
                            ? Colors.white
                            : Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
        // Badge promo superposé sur l'image
        if (hasDiscount)
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFDC2626), // Rouge vif
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFDC2626).withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.local_offer_rounded,
                    color: Colors.white,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '-${activeDiscount.toInt()}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildBottomNavigationBar(bool hasCta, double realPrice) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(30),
        topRight: Radius.circular(30),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.8),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
            border: Border(
              top: BorderSide(
                color: Colors.white.withValues(alpha: 0.4),
                width: 1,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: SafeArea(
            child: Row(
              children: [
                // Affichage du prix dans la navbar
                Expanded(
                  flex: 3, // Moins de place pour le prix
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total à payer',
                        style: TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      hasCta
                          ? Text(
                            widget.product.cta!,
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF111827),
                              fontSize: 16,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          )
                          : FittedBox(
                            // Empêche le prix d'être coupé
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              _formatPrice(realPrice),
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 20,
                                color: Color(0xFF111827),
                              ),
                            ),
                          ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Bouton WhatsApp géant amélioré
                Expanded(
                  flex: 4, // Plus de place pour le bouton
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF25D366), Color(0xFF128C7E)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF25D366).withOpacity(0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: _handleDiscuss,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(
                                Bootstrap.whatsapp,
                                color: Colors.white,
                                size: 22,
                              ),
                              SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'Discuter avec le vendeur',
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    height: 1.2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSpecsGrid() {
    final features = widget.product.features ?? [];

    final List<Widget> items = [
      _buildSpecItem(
        Icons.branding_watermark_rounded,
        'Marque',
        widget.product.brand?.name ?? 'Non spécifié',
      ),
      _buildSpecItem(
        Icons.directions_car_rounded,
        'Modèle',
        widget.product.model?.name ?? 'Non spécifié',
      ),
      _buildSpecItem(
        Icons.event_rounded,
        'Année',
        widget.product.year?.name ?? 'Non spécifié',
      ),
      if (features.isNotEmpty)
        _buildSpecItem(
          Icons.settings_suggest_rounded,
          'Spécif.',
          features.first,
        )
      else
        _buildSpecItem(
          Icons.category_rounded,
          'Catégorie',
          widget.product.category?.name ?? 'Non spécifié',
        ),
      if (features.length > 1)
        _buildSpecItem(Icons.info_rounded, 'Info', features[1]),
    ];

    // Affichage en colonnes sans contrainte de ratio pour éviter que le texte ne se coupe
    final List<Widget> rows = [];
    for (int i = 0; i < items.length; i += 2) {
      rows.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: items[i]),
            const SizedBox(width: 16),
            Expanded(
              child: i + 1 < items.length ? items[i + 1] : const SizedBox(),
            ),
          ],
        ),
      );
      if (i + 2 < items.length) {
        rows.add(const SizedBox(height: 16));
      }
    }

    return Column(children: rows);
  }

  Widget _buildSpecItem(IconData icon, String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFF4B5563), size: 20),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                ),
                maxLines:
                    3, // Permet au texte long (ex: modèle complet) de s'afficher sur 3 lignes
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSellerInfo() {
    final seller = widget.product.seller;
    final sellerName = seller?.fullName ?? 'AB Auto Vente';
    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).primaryColor.withValues(alpha: 0.8),
                Theme.of(context).primaryColor,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              sellerName.isNotEmpty ? sellerName[0].toUpperCase() : 'V',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                sellerName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(
                    Icons.verified_rounded,
                    color: Color(0xFF10B981),
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Vendeur professionnel',
                    style: TextStyle(
                      color: Color(0xFF10B981),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              if (seller?.city != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6.0),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.location_on_rounded,
                        color: Color(0xFF9CA3AF),
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        seller!.city!,
                        style: const TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  void _showLightbox(List<String> medias, int initialIndex) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.9),
      builder:
          (context) => Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: EdgeInsets.zero,
            child: Stack(
              children: [
                PageView.builder(
                  controller: PageController(initialPage: initialIndex),
                  itemCount: medias.length,
                  itemBuilder: (context, index) {
                    return InteractiveViewer(
                      panEnabled: true,
                      minScale: 1,
                      maxScale: 4,
                      child: Center(
                        child: Image.network(
                          medias[index],
                          fit: BoxFit.contain,
                        ),
                      ),
                    );
                  },
                ),
                Positioned(
                  top: MediaQuery.of(context).padding.top + 16,
                  right: 16,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }
}

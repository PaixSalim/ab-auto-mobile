// Widget principal pour afficher les marques partenaires
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class Brand {
  final String id;
  final String name;
  final String logoUrl;
  final String? websiteUrl;
  final String? description;

  const Brand({
    required this.id,
    required this.name,
    required this.logoUrl,
    this.websiteUrl,
    this.description,
  });

  List<Object?> get props => [id, name, logoUrl, websiteUrl, description];
}

class PartnerBrandsWidget extends StatelessWidget {
  final String title;
  final String? subtitle;
  final double logoHeight;
  final double spacing;
  final double runSpacing;
  final bool showBrandNames;
  final bool useCarousel;
  final VoidCallback? onSeeAllPressed;

  const PartnerBrandsWidget({
    super.key,
    this.title = 'Nos marques partenaires',
    this.subtitle,
    this.logoHeight = 60,
    this.spacing = 16,
    this.runSpacing = 24,
    this.showBrandNames = false,
    this.useCarousel = false,
    this.onSeeAllPressed,
  });

  @override
  Widget build(BuildContext context) {
    final brands = [
      const Brand(
        id: '1',
        name: 'Jetour',
        logoUrl: 'https://auto-cdn.uvatis.com/brands/jetour.png',
        description: '',
      ),
      const Brand(
        id: '2',
        name: 'Changan',
        logoUrl: 'https://auto-cdn.uvatis.com/brands/changan.png',
        description: '',
      ),
      const Brand(
        id: '3',
        name: 'Geely',
        logoUrl: 'https://auto-cdn.uvatis.com/brands/geely.png',
        description: '',
      ),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 16),
          useCarousel
              ? _buildCarousel(context, brands)
              : _buildGrid(context, brands),
          SizedBox(height: 60),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment:
          CrossAxisAlignment.start, // important pour bien aligner en haut
      children: [
        Expanded(
          // <-- AJOUT ICI
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: TextStyle(color: Colors.grey[600]),
                  softWrap: true,
                ),
            ],
          ),
        ),
        if (onSeeAllPressed != null)
          TextButton(
            onPressed: onSeeAllPressed,
            child: Row(
              children: const [
                Text('Voir tout'),
                SizedBox(width: 4),
                Icon(Icons.arrow_forward, size: 16),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildLoadingIndicator() {
    return SizedBox(
      height: logoHeight + (showBrandNames ? 40 : 0),
      child: Center(
        child: CircularProgressIndicator(
          color: const Color(0xFFFF4D00),
          strokeWidth: 3,
        ),
      ),
    );
  }

  Widget _buildGrid(BuildContext context, List<Brand> brands) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculer le nombre d'éléments par ligne en fonction de la largeur disponible
        final double availableWidth = constraints.maxWidth;
        final double itemWidth = logoHeight * 2.5;

        return Wrap(
          spacing: spacing,
          runSpacing: runSpacing,
          alignment: WrapAlignment.start,
          children:
              brands.map((brand) => _buildBrandItem(context, brand)).toList(),
        );
      },
    );
  }

  Widget _buildCarousel(BuildContext context, List<Brand> brands) {
    return SizedBox(
      height: logoHeight + (showBrandNames ? 40 : 0),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: brands.length,
        separatorBuilder: (context, index) => SizedBox(width: spacing),
        itemBuilder:
            (context, index) => _buildBrandItem(context, brands[index]),
      ),
    );
  }

  Widget _buildBrandItem(BuildContext context, Brand brand) {
    return GestureDetector(
      onTap: () {},
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildBrandLogo(brand),
          if (showBrandNames) ...[
            const SizedBox(height: 8),
            Text(
              brand.name,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBrandLogo(Brand brand) {
    return Hero(
      tag: 'brand-logo-${brand.id}',
      child: Container(
        height: logoHeight,
        width: logoHeight,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: CachedNetworkImage(
          imageUrl: brand.logoUrl,
          fit: BoxFit.contain,
          placeholder:
              (context, url) => const Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
          errorWidget: (context, url, error) => const Icon(Icons.error),
        ),
      ),
    );
  }

  Widget _buildErrorWidget(String message) {
    return Container(
      height: logoHeight + 40,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 32),
          const SizedBox(height: 8),
          Text(
            'Impossible de charger les marques',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            message,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

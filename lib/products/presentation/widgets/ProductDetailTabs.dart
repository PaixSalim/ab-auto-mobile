import 'package:flutter/material.dart';
import 'package:auto/products/domain/entities/product_entity.dart';
import 'package:url_launcher/url_launcher.dart';

class ProductDetailTabs extends StatefulWidget {
  final ProductEntity product;

  const ProductDetailTabs({
    super.key,
    required this.product,
  });

  @override
  State<ProductDetailTabs> createState() => _ProductDetailTabsState();
}

class _ProductDetailTabsState extends State<ProductDetailTabs>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          // Tab bar
          Container(
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorColor: const Color(0xFF3B82F6),
              labelColor: const Color(0xFF3B82F6),
              unselectedLabelColor: const Color(0xFF6B7280),
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
              indicatorWeight: 2,
              tabs: const [
                Tab(text: 'Description'),
                Tab(text: 'Livraison'),
                Tab(text: 'Vendeur'),
              ],
            ),
          ),
          
          // Tab content
          SizedBox(
            height: 400,
            child: TabBarView(
              controller: _tabController,
              children: [
                _DescriptionTab(product: widget.product),
                _ShippingTab(product: widget.product),
                _SellerTab(product: widget.product),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DescriptionTab extends StatelessWidget {
  final ProductEntity product;

  const _DescriptionTab({required this.product});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Description du produit',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 16),
          
          Text(
            product.description ?? 'Aucune description disponible',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF4B5563),
              height: 1.5,
            ),
          ),
          
          // Features section
          if (product.features != null && product.features!.isNotEmpty) ...[
            const SizedBox(height: 24),
            const Text(
              'Caractéristiques',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 12),
            
            ...product.features!.map((feature) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 16,
                    color: Colors.green[600],
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      feature,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF4B5563),
                      ),
                    ),
                  ),
                ],
              ),
            )).toList(),
          ],
          
          const SizedBox(height: 24),
          
          // Security advice
          _SecurityAdvice(),
        ],
      ),
    );
  }
}

class _ShippingTab extends StatelessWidget {
  final ProductEntity product;

  const _ShippingTab({required this.product});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Informations de livraison',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 16),
          
          // Delivery info card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.store_outlined,
                    color: Color(0xFF3B82F6),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Contactez le vendeur',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Pour plus d\'informations sur la livraison, veuillez contacter directement le vendeur.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Disponibilité et modalités sur demande',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Security advice
          _SecurityAdvice(),
        ],
      ),
    );
  }
}

class _SellerTab extends StatelessWidget {
  final ProductEntity product;

  const _SellerTab({required this.product});

  @override
  Widget build(BuildContext context) {
    final seller = product.seller ?? SellerEntity(
      fullName: 'AB Auto Vente',
      email: 'contact@abauto.bf',
      phone: '22607513333',
      city: 'Ouagadougou',
    );
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Informations du vendeur',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 16),
          
          // Seller header
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                  ),
                  borderRadius: BorderRadius.circular(32),
                ),
                child: Center(
                  child: Text(
                    seller.fullName?.isNotEmpty == true
                        ? seller.fullName![0].toUpperCase()
                        : 'V',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
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
                      seller.fullName ?? 'Vendeur',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.verified,
                            size: 12,
                            color: Colors.green[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Vendeur vérifié',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Vendeur professionnel',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Contact info grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [
              _ContactCard(
                icon: Icons.phone_outlined,
                label: 'Téléphone',
                value: seller.phone ?? 'Non disponible',
                iconColor: const Color(0xFF3B82F6),
                fontSize: 12, // Taille réduite
              ),
              _ContactCard(
                icon: Icons.email_outlined,
                label: 'Email',
                value: seller.email ?? 'Non disponible',
                iconColor: const Color(0xFF10B981),
                fontSize: 12, // Taille réduite
              ),
              _ContactCard(
                icon: Icons.location_on_outlined,
                label: 'Ville',
                value: seller.city ?? 'Non spécifiée',
                iconColor: const Color(0xFFF59E0B),
                fontSize: 12, // Taille réduite
              ),
              _ContactCard(
                icon: Icons.store_outlined,
                label: 'Type de compte',
                value: 'Vendeur professionnel',
                iconColor: const Color(0xFF8B5CF6),
                fontSize: 12, // Taille réduite
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Contact actions
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _launchWhatsApp(seller.phone),
                  icon: const Icon(Icons.phone, size: 18),
                  label: const Text('Contacter par WhatsApp'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF25D366),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              //   const SizedBox(width: 12),
              //   Expanded(
              //     child: OutlinedButton.icon(
              //       onPressed: () => _sendMessage(seller.email),
              //       icon: const Icon(Icons.message, size: 18),
              //       label: const Text('Envoyer un message'),
              //       style: OutlinedButton.styleFrom(
              //         foregroundColor: const Color(0xFF3B82F6),
              //         side: const BorderSide(color: Color(0xFF3B82F6)),
              //         padding: const EdgeInsets.symmetric(vertical: 12),
              //         shape: RoundedRectangleBorder(
              //           borderRadius: BorderRadius.circular(8),
              //         ),
              //       ),
              //     ),
              // ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Security advice
          _SecurityAdvice(),
        ],
      ),
    );
  }

  void _launchWhatsApp(String? phone) async {
    final phoneNumber = phone ?? '22607513333'; // Default phone number
    final url = 'https://api.whatsapp.com/send?phone=$phoneNumber';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  void _sendMessage(String? email) async {
    if (email == null) return;
    
    final subject = Uri.encodeComponent('Question concernant: ${product.name}');
    final body = Uri.encodeComponent(
      'Bonjour,\n\nJe suis intéressé(e) par votre produit "${product.name}".\n\nPourriez-vous me donner plus d\'informations ?\n\nCordialement.'
    );
    final url = 'mailto:$email?subject=$subject&body=$body';
    
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }
}

class _ContactCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color iconColor;
  final double? fontSize; // Paramètre optionnel pour la taille du texte

  const _ContactCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.iconColor,
    this.fontSize, // Paramètre optionnel
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: fontSize ?? 12, // Utilise fontSize ou 12 par défaut
                    color: const Color(0xFF6B7280),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: (fontSize != null ? fontSize! - 2 : 12), // Valeur légèrement plus petit
                    color: const Color(0xFF1F2937),
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SecurityAdvice extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.shield,
            color: Colors.green[600],
            size: 24,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Conseil de sécurité',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF065F46),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '• Éviter d\'envoyer des paiements anticipés\n'
                  '• Rencontrez le vendeur dans un lieu public sécurisé\n'
                  '• Inspectez ce que vous allez acheter\n'
                  '• Vérifiez tous les documents avant de payer',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF047857),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

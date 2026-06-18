import 'package:flutter/material.dart';
import 'package:auto/products/domain/entities/product_entity.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';

class ProductActionButtons extends StatelessWidget {
  final ProductEntity product;
  final String? selectedState;
  final int quantity;

  const ProductActionButtons({
    super.key,
    required this.product,
    this.selectedState,
    this.quantity = 1,
  });

  Future<void> _launchWhatsApp(BuildContext context) async {
    final sellerPhone = product.seller?.phone ?? '22607513333';
    final message = Uri.encodeComponent(
      'Bonjour, je suis intéressé(e) par votre produit "${product.name ?? 'ce produit'}". '
      'État: ${selectedState == 'used' ? 'Occasion' : 'Neuf'}, Quantité: $quantity. '
      'Pourriez-vous me donner plus d\'informations ?',
    );

    final url = 'https://wa.me/$sellerPhone?text=$message';

    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Impossible d\'ouvrir WhatsApp')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors de l\'ouverture de WhatsApp'),
          ),
        );
      }
    }
  }

  Future<void> _launchEmail(BuildContext context) async {
    final sellerEmail = product.seller?.email;
    if (sellerEmail == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email du vendeur non disponible')),
        );
      }
      return;
    }

    final subject = Uri.encodeComponent(
      'Question concernant: ${product.name ?? 'ce produit'}',
    );
    final body = Uri.encodeComponent(
      'Bonjour,\n\nJe suis intéressé(e) par votre produit "${product.name ?? 'ce produit'}".\n'
      'État: ${selectedState == 'used' ? 'Occasion' : 'Neuf'}\n'
      'Quantité: $quantity\n\n'
      'Pourriez-vous me donner plus d\'informations ?\n\nCordialement.',
    );

    final url = 'mailto:$sellerEmail?subject=$subject&body=$body';

    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Impossible d\'ouvrir l\'application email'),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors de l\'ouverture de l\'email'),
          ),
        );
      }
    }
  }

  Future<void> _shareProduct(BuildContext context) async {
    final productUrl = 'https://ab-autox.com/products/${product.id}';

    try {
      await Clipboard.setData(ClipboardData(text: productUrl));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lien du produit copié dans le presse-papiers'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors de la copie du lien')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        children: [
          // Primary action buttons
          Row(
            children: [
              // Contact button
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _launchWhatsApp(context),
                  icon: const Icon(Icons.phone_outlined, size: 20),
                  label: const Text(
                    'Contacter le vendeur',
                    style: TextStyle(fontSize: 14),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                ),
              ),

              const SizedBox(width: 15),

              // Share button
              OutlinedButton.icon(
                onPressed: () => _shareProduct(context),
                icon: const Icon(Icons.share_outlined, size: 20),
                label: const Text('Partager'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF6B7280),
                  side: const BorderSide(color: Color(0xFFE5E7EB)),
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 20,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),

          // const SizedBox(height: 12),

          // // Secondary contact option
          // SizedBox(
          //   width: double.infinity,
          //   child: OutlinedButton.icon(
          //     onPressed: () => _launchEmail(context),
          //     icon: const Icon(Icons.email_outlined, size: 20),
          //     label: const Text('Envoyer un message email'),
          //     style: OutlinedButton.styleFrom(
          //       foregroundColor: const Color(0xFF3B82F6),
          //       side: const BorderSide(color: Color(0xFF3B82F6)),
          //       padding: const EdgeInsets.symmetric(vertical: 12),
          //       shape: RoundedRectangleBorder(
          //         borderRadius: BorderRadius.circular(8),
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}

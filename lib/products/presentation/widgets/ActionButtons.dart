import 'package:auto/auth/presentation/pages/login_page.dart';
import 'package:auto/core/resources/local_storage_service.dart';
import 'package:auto/products/domain/entities/product_entity.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'OrderModal.dart';

class ActionButtons extends StatelessWidget {
  final ProductEntity product;
  final int quantity;
  const ActionButtons({
    super.key,
    required this.product,
    required this.quantity,
  });

  void _showLoginRequired(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Connexion requise'),
        content: const Text('Vous devez être connecté pour passer une commande.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            },
            child: const Text('Se connecter'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (product.cta!.isEmpty)
          ElevatedButton.icon(
            onPressed: () {
              if (!LocalStorageService.isLoggedIn) {
                _showLoginRequired(context);
                return;
              }
              showOrderModal(context, product, quantity);
            },
            icon: const Icon(Icons.shopping_cart),
            label: const Text("Lancer la commande"),
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
            ),
          ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: () async {
            final uri = Uri.parse('https://www.abauto.pro/whatsapp');
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            }
            //_makePhoneCall('+22607513333');
          },
          icon: Icon(Icons.phone, color: Theme.of(context).primaryColor),
          label: Text(
            "Contacter un commercial",
            style: TextStyle(color: Theme.of(context).primaryColor),
          ),
          style: OutlinedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            side: BorderSide(color: Theme.of(context).primaryColor),
            minimumSize: const Size(double.infinity, 50),
          ),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: () async {
            await Share.share(
              'Découvrez ${product.name} à prix réduit sur AB AUTO : https://www.abauto.pro/catalogue/product/${product.slug}',
            );
          },
          icon: const Icon(Icons.share, color: Colors.black),
          label: const Text("Partager", style: TextStyle(color: Colors.black)),
          style: OutlinedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            side: BorderSide(color: Colors.grey.shade300),
            minimumSize: const Size(double.infinity, 50),
          ),
        ),

        const SizedBox(height: 20),
      ],
    );
  }
}

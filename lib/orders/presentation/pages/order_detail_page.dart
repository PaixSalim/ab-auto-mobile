import 'package:auto/orders/domain/entities/my_order_entity.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderDetailPage extends StatelessWidget {
  final MyOrderEntity order;
  const OrderDetailPage({super.key, required this.order});

  Color _statusColor(String status) {
    switch (status) {
      case 'delivered':
      case 'Livrée':
        return Colors.green;
      case 'cancelled':
      case 'Annulée':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'delivered':
        return 'Livrée';
      case 'cancelled':
        return 'Annulée';
      case 'pending':
        return 'En attente';
      default:
        return status;
    }
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd MMMM yyyy à HH:mm', 'fr_FR').format(date);
    } catch (_) {
      return dateStr;
    }
  }

  Widget _infoRow(String label, String value, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: Colors.grey[600]),
            const SizedBox(width: 8),
          ],
          SizedBox(
            width: 120,
            child: Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductImage() {
  // Validation de l'URL
  if (order.productImage.isEmpty) {
    return _buildImagePlaceholder();
  }

  // Vérification si l'URL est valide
  final uri = Uri.tryParse(order.productImage);
  if (uri == null || !uri.hasScheme || (!uri.scheme.startsWith('http'))) {
    return _buildImagePlaceholder();
  }

  // Liste des domaines problématiques à éviter
  final problematicDomains = ['auto-cdn.uvatis.com'];
  if (problematicDomains.any((domain) => uri.host.contains(domain))) {
    return _buildImagePlaceholder();
  }

  return CachedNetworkImage(
    imageUrl: order.productImage,
    width: 80,
    height: 80,
    fit: BoxFit.cover,
    placeholder: (_, __) => Container(
      width: 80,
      height: 80,
      color: Colors.grey[200],
      child: const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    ),
    errorWidget: (_, __, ___) => _buildImagePlaceholder(),
  );
}

Widget _buildImagePlaceholder() {
  return Container(
    width: 80,
    height: 80,
    decoration: BoxDecoration(
      color: Colors.grey[200],
      borderRadius: BorderRadius.circular(8),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.image_not_supported,
          size: 24,
          color: Colors.grey[400],
        ),
        const SizedBox(height: 4),
        Text(
          'Image',
          style: TextStyle(
            fontSize: 8,
            color: Colors.grey[500],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    final statusLabel = _statusLabel(order.status);
    final statusColor = _statusColor(order.status);

    // Debug: Afficher les données de la commande
    print('DEBUG: OrderDetailPage - Order ID: ${order.id}');
    print('DEBUG: OrderDetailPage - Product Name: ${order.productName}');
    print('DEBUG: OrderDetailPage - Product Price: ${order.productPrice}');
    print('DEBUG: OrderDetailPage - Customer Name: ${order.customerName}');
    print('DEBUG: OrderDetailPage - Phone: ${order.phoneNumber}');
    print('DEBUG: OrderDetailPage - City: ${order.city}');
    print('DEBUG: OrderDetailPage - Status: ${order.status}');
    print('DEBUG: OrderDetailPage - Created At: ${order.createdAt}');

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Commande #${order.id}'),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Statut
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: statusColor.withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  Icon(
                    statusLabel == 'Livrée'
                        ? Icons.check_circle
                        : statusLabel == 'Annulée'
                            ? Icons.cancel
                            : Icons.access_time,
                    color: statusColor,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    statusLabel,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _formatDate(order.createdAt),
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Produit
            Card(
              elevation: 1,
              color: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: _buildProductImage(),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.productName,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${order.productPrice.toStringAsFixed(0)} FCFA',
                            style: TextStyle(
                              color: primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Quantité : ${order.quantity}',
                            style: const TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Infos client
            Card(
              elevation: 1,
              color: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Informations de livraison',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    const Divider(height: 20),
                    _infoRow('Nom', order.customerName, icon: Icons.person_outline),
                    _infoRow('Ville', order.city, icon: Icons.location_city_outlined),
                    _infoRow('Téléphone', order.phoneNumber, icon: Icons.phone_outlined),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Récapitulatif prix
            Card(
              elevation: 1,
              color: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Récapitulatif',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Prix unitaire', style: TextStyle(color: Colors.grey)),
                        Text('${order.productPrice.toStringAsFixed(0)} FCFA'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Quantité', style: TextStyle(color: Colors.grey)),
                        Text('× ${order.quantity}'),
                      ],
                    ),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(
                          '${(order.productPrice * order.quantity).toStringAsFixed(0)} FCFA',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: primary,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Bouton contacter
            OutlinedButton.icon(
              onPressed: () async {
                final uri = Uri(scheme: 'tel', path: order.phoneNumber);
                if (await canLaunchUrl(uri)) await launchUrl(uri);
              },
              icon: Icon(Icons.phone, color: primary),
              label: Text('Appeler ${order.customerName}',
                  style: TextStyle(color: primary)),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                side: BorderSide(color: primary),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

import 'package:auto/config/theme/builldInputDecoration.dart';
import 'package:auto/config/theme/customToast.dart';
import 'package:auto/core/resources/local_storage_service.dart';
import 'package:auto/core/resources/network_info.dart';
import 'package:auto/products/data/utils/getCartPrice.dart';
import 'package:auto/products/data/utils/getProductPrice.dart';
import 'package:auto/products/domain/entities/order_entity.dart';
import 'package:auto/products/domain/entities/product_entity.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:lottie/lottie.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../bloc/remote/order/remote_order_bloc.dart';

void showOrderModal(BuildContext context, ProductEntity product, int quantity) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    builder:
        (context) =>
            OrderConfirmationModal(product: product, quantity: quantity),
  );
}

class OrderConfirmationModal extends StatefulWidget {
  final ProductEntity product;
  final int quantity;

  const OrderConfirmationModal({
    super.key,
    required this.product,
    required this.quantity,
  });

  @override
  _OrderConfirmationModalState createState() => _OrderConfirmationModalState();
}

class _OrderConfirmationModalState extends State<OrderConfirmationModal> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  bool _isButtonEnabled = false;

  void _validateInputs() {
    setState(() {
      _isButtonEnabled =
          _nameController.text.isNotEmpty &&
          _cityController.text.isNotEmpty &&
          _phoneController.text.length >= 8;
    });
  }

  @override
  void initState() {
    super.initState();
    _nameController.text = LocalStorageService.userFullName ?? '';
    _nameController.addListener(_validateInputs);
    _phoneController.addListener(_validateInputs);
  }

  @override
  void dispose() {
    _nameController.removeListener(_validateInputs);
    _phoneController.removeListener(_validateInputs);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Finaliser votre commande",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              "Veuillez renseigner vos coordonnées pour que nous puissions vous contacter et confirmer votre commande.",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(
                          imageUrl: widget.product.medias![0],
                          fit: BoxFit.cover,
                          width: 60,
                          height: 60,
                          progressIndicatorBuilder:
                              (context, url, downloadProgress) => Lottie.asset(
                                'assets/animations/lottie/loading-image.json',
                              ),
                          errorWidget:
                              (context, url, error) => Lottie.asset(
                                'assets/animations/lottie/error-network.json',
                              ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.product.name!,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "${widget.product.state == "new" ? 'Neuf' : 'Ocassion'} • Quantité: ${widget.quantity}",
                              style: TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(height: 5),
                            Row(
                              children: [
                                Text(
                                  "${getProductPrice(widget.product.price!, widget.product.discount!)} Fcfa",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                SizedBox(width: 10),
                                if (widget.product.discount! > 0)
                                  Container(
                                    padding: EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Text(
                                        "Prix promo",
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Divider(color: Colors.grey.shade300),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total:'),
                        Text(
                          "${getCartPrice(widget.product.price!, widget.product.discount!, widget.quantity)} Fcfa",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            const Text(
              "Nom complet *",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            TextField(
              controller: _nameController,
              decoration: buildInputDecoration(
                context,
                'Entrez votre nom complet',
                Icon(LucideIcons.user),
              ),
            ),
            const SizedBox(height: 10),

            const Text(
              "Numéro WhatsApp *",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),

            TextField(
              keyboardType: TextInputType.phone,
              controller: _phoneController,
              decoration: buildInputDecoration(
                context,
                'Ex: 22670707070 ',
                Icon(Icons.add),
              ),
            ),

            const SizedBox(height: 16),

            const Text(
              "Votre ville *",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            TextField(
              controller: _cityController,
              decoration: buildInputDecoration(
                context,
                'Ex: Ouagadougou ',
                Icon(Icons.location_city),
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              "Nous vous contacterons sur ce numéro pour confirmer votre commande",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed:
                    _isButtonEnabled
                        ? () async {
                          final networkInfo = NetworkInfo(InternetConnection());
                          final isOnline = await networkInfo.isConnected;
                          if (isOnline) {
                            final order = OrderEntity(
                              _nameController.text,
                              _phoneController.text,
                              _cityController.text,
                              int.parse(widget.product.id!),
                              widget.quantity,
                            );
                            if (context.mounted) {
                              context.read<RemoteOrderBloc>().add(
                                SendOrder(order),
                              );
                            }
                            showCustomToast(
                              context,
                              'Félicitations',
                              "Commande soumise avec succès 🎉",
                              true,
                            );
                            Navigator.pop(context);
                          } else {
                            showCustomToast(
                              context,
                              "Pas d'internet",
                              "Veuillez bien vouloir vous connecter à internet bien avant !",
                              false,
                            );
                            Navigator.of(context).pop();
                          }
                        }
                        : null,
                icon: const Icon(LucideIcons.checkSquare),
                label: const Text("Confirmer"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

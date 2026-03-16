import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'DeliveryOption.dart';

class DeliveryDetails extends StatelessWidget {
  const DeliveryDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Informations de livraison",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          DeliveryOption(
            icon: LucideIcons.truck,
            title: "Livraison standard",
            description: "Livraison en 3-7 jours ouvrables",
            price: "",
          ),
          const SizedBox(height: 10),
          DeliveryOption(
            icon: LucideIcons.store,
            title: "Retrait en magasin",
            description: "Disponible sous 2h dans nos magasins",
            price: "Gratuit",
          ),
        ],
      ),
    );
  }
}

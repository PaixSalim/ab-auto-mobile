import 'package:flutter/material.dart';

import 'PartnerSection.dart';

class BrandsDemo extends StatelessWidget {
  const BrandsDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nos partenaires')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PartnerBrandsWidget(
              title: 'Nos marques partenaires',
              subtitle: 'Les meilleures marques automobiles',
              logoHeight: 70,
              useCarousel: true,
              showBrandNames: true,
            ),
            const SizedBox(height: 32),
            const PartnerBrandsWidget(
              title: 'Équipementiers',
              logoHeight: 60,
              useCarousel: false,
              showBrandNames: true,
            ),
          ],
        ),
      ),
    );
  }
}

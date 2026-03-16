import 'package:auto/categories/presentation/bloc/remote/remote_category_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';

import 'CategoryCard.dart';

Widget CategorySection() {
  return Column(
    children: [
      const Text(
        "Commandez on vous livre",
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 20),
      BlocBuilder<RemoteCategoryBloc, RemoteCategoryState>(
        builder: (context, state) {
          if (state is RemoteCategoryLoading) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.builder(
                shrinkWrap: true,
                // Permet au GridView de se redimensionner à son contenu
                physics: NeverScrollableScrollPhysics(),
                // Empêche le GridView de scroller indépendamment
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  childAspectRatio: 1.25,
                ),
                itemCount: 4,
                itemBuilder: (context, index) {
                  return Container(
                    width: 150,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CachedNetworkImage(
                          height: 60,
                          imageUrl: 'https://auto-cdn.uvatis.com/logo.png',
                          progressIndicatorBuilder:
                              (context, url, downloadProgress) => Lottie.asset(
                                'assets/animations/lottie/loading-image.json',
                              ),
                          errorWidget:
                              (context, url, error) => Lottie.asset(
                                'assets/animations/lottie/loading-image.json',
                              ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Chargement',
                          softWrap: true,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          }
          if (state is RemoteCategoryDone) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.builder(
                shrinkWrap: true,
                // Permet au GridView de se redimensionner à son contenu
                physics: NeverScrollableScrollPhysics(),
                // Empêche le GridView de scroller indépendamment
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  childAspectRatio: 1.25,
                ),
                itemCount: state.categories!.length,
                itemBuilder: (context, index) {
                  final category = state.categories![index];
                  return CategoryCard(category: category);
                },
              ),
            );
          }
          if (state is RemoteCategoryError) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.builder(
                shrinkWrap: true,
                // Permet au GridView de se redimensionner à son contenu
                physics: NeverScrollableScrollPhysics(),
                // Empêche le GridView de scroller indépendamment
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  childAspectRatio: 1.25,
                ),
                itemCount: 4,
                itemBuilder: (context, index) {
                  return Container(
                    width: 150,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CachedNetworkImage(
                          height: 60,
                          imageUrl: 'https://auto-cdn.uvatis.com/logo.png',
                          progressIndicatorBuilder:
                              (context, url, downloadProgress) => Lottie.asset(
                                'assets/animations/lottie/error-network.json',
                              ),
                          errorWidget:
                              (context, url, error) => Lottie.asset(
                                'assets/animations/lottie/error-network.json',
                              ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Erreur survenue',
                          softWrap: true,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          }

          return Text('');
        },
      ),
      const SizedBox(height: 20),
    ],
  );
}

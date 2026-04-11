import 'package:auto/categories/presentation/bloc/remote/remote_category_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'CategoryCard.dart';

Widget CategorySection() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Text(
          "Catégories",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      SizedBox(
        height: 110,
        child: BlocBuilder<RemoteCategoryBloc, RemoteCategoryState>(
          builder: (context, state) {
            if (state is RemoteCategoryLoading) {
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: 5,
                itemBuilder: (context, index) => _buildLoadingCard(),
              );
            }
            if (state is RemoteCategoryDone) {
              // Filtrer pour n'afficher que les catégories principales (parentId: null)
              final mainCategories = state.categories!.where((category) => category.parentId == null).toList();
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: mainCategories.length,
                itemBuilder: (context, index) {
                  final category = mainCategories[index];
                  return CategoryCard(category: category);
                },
              );
            }
            return const SizedBox();
          },
        ),
      ),
      const SizedBox(height: 10),
    ],
  );
}

Widget _buildLoadingCard() {
  return Container(
    width: 80,
    margin: const EdgeInsets.symmetric(horizontal: 8),
    child: Column(
      children: [
        CircleAvatar(radius: 30, backgroundColor: Colors.grey.shade200),
        const SizedBox(height: 8),
        Container(width: 40, height: 10, color: Colors.grey.shade200),
      ],
    ),
  );
}

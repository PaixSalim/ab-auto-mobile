import 'dart:ui';

import 'package:auto/categories/domain/entities/category_entity.dart';
import 'package:auto/products/presentation/bloc/remote/remote_product_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'SubCategorySelectionModal.dart';

void showSubCategorySelectionDialog(
  BuildContext context,
  CategoryEntity category,
) {
  final bloc = context.read<RemoteProductsBloc>();
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5), // Effet de flou
        child: Dialog(
          backgroundColor: Colors.white,
          insetPadding: EdgeInsets.symmetric(horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: SubCategorySelectionModal(category: category, bloc: bloc),
        ),
      );
    },
  );
}

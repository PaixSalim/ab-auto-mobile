import 'dart:ui';

import 'package:auto/categories/domain/entities/category_entity.dart';
import 'package:flutter/material.dart';

import 'SubCategorySelectionModal.dart';

void showSubCategorySelectionDialog(
  BuildContext context,
  CategoryEntity category,
) {
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
          child: SubCategorySelectionModal(category: category),
        ),
      );
    },
  );
}

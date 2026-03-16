import 'package:flutter/material.dart';

enum AnimationType { fade, slide, rotate, gauche }

void goTo(BuildContext context, Widget destinationPage, AnimationType type) {
  Navigator.of(context).push(
    PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => destinationPage,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        switch (type) {
          case AnimationType.fade:
            return FadeTransition(opacity: animation, child: child);
          case AnimationType.slide:
            return SlideTransition(
              position: Tween<Offset>(
                begin: Offset(1.0, 0.0), // Slide à partir de la droite
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
          case AnimationType.gauche:
            return SlideTransition(
              position: Tween<Offset>(
                begin: Offset(-1.0, 0.0), // Slide à partir de la droite
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
          case AnimationType.rotate:
            return RotationTransition(
              turns: Tween(begin: 0.0, end: 1.0).animate(animation),
              child: child,
            );
        }
      },
    ),
  );
}

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class TypingIndicator extends StatelessWidget {
  const TypingIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildAvatar(context),
        Transform.translate(
          offset: Offset(0, -10), // -8 pour remonter verticalement
          child: Lottie.asset(
            "assets/animations/lottie/loading.json",
            width: 60,
          ),
        ),
      ],
    );
  }

  Widget _buildAvatar(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Icon(Icons.smart_toy, color: Colors.white, size: 16),
    );
  }
}

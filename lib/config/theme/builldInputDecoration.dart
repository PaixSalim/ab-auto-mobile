import 'package:flutter/material.dart';

InputDecoration buildInputDecoration(
  BuildContext context,
  String placeholder,
  Icon prefixIcon,
  [Icon? suffixIcon,]
) {
  return InputDecoration(
    prefixIcon: prefixIcon,
    suffixIcon: suffixIcon,
    hintText: placeholder,
    hintStyle: TextStyle(color: Colors.grey, fontSize: 15),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide.none,
      borderRadius: BorderRadius.circular(10),
    ),
    filled: true,
    fillColor: Colors.grey.withValues(alpha: 0.1),
    contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
      borderRadius: BorderRadius.circular(8),
    ),
  );
}

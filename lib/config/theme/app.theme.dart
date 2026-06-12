import 'package:flutter/material.dart';

ThemeData theme() {
  return ThemeData(
    scaffoldBackgroundColor: Colors.grey.shade100,
    //textTheme: GoogleFonts.robotoTextTheme(),
    appBarTheme: appBarTheme(),
    primaryColor: const Color(0xFFBE1622),
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFFFFFFFF),
      primary: const Color(0xFF878787), // secondary
    ),
  );
}

AppBarTheme appBarTheme() {
  return AppBarTheme(
    backgroundColor: Colors.white,
    elevation: 0,
    iconTheme: IconThemeData(),
  );
}

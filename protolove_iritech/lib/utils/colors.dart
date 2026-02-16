import 'package:flutter/material.dart';

class AppColors {
  final Color primaryColor = const Color.fromARGB(251, 167, 151, 246);
  final Color secondaryColor = const Color.fromARGB(255, 255, 124, 108);
  final Color terciaryColor = const Color.fromARGB(255, 151, 151, 151);
  final Color buttonColor = const Color.fromARGB(255, 255, 111, 97);
  
  final Gradient primaryGradient = const LinearGradient(
    colors: [
      Color.fromARGB(112, 255, 111, 97),
      Color.fromARGB(255, 255, 124, 108),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

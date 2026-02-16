import 'package:flutter/material.dart';

class AppMessages {
  static void error(BuildContext context, String message) {
    _show(
      context,
      message,
      icon: Icons.error_outline,
      bgColor: const Color(0xFFF7EEEE),
      textColor: const Color(0xFF850018),
    );
  }

  static void success(BuildContext context, String message) {
    _show(
      context,
      message,
      icon: Icons.check_circle_outline,
      bgColor: const Color(0xffE6F4EA),
      textColor: const Color(0xff1B5E20),
    );
  }

  static void info(BuildContext context, String message) {
    _show(
      context,
      message,
      icon: Icons.info_outline,
      bgColor: const Color(0xffE8F0FE),
      textColor: const Color(0xff1A237E),
    );
  }

  static void _show(
    BuildContext context,
    String message, {
    required IconData icon,
    required Color bgColor,
    required Color textColor,
  }) {
    final snackBar = SnackBar(
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(16),
      backgroundColor: bgColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      content: Row(
        children: [
          Icon(icon, color: textColor),
          const SizedBox(width: 12),
          Expanded(child: Text(message, style: TextStyle(color: textColor))),
        ],
      ),
    );

    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(snackBar);
  }
}

import 'package:flutter/material.dart';

class PrototypeCategoryUtils {
  static const categories = [
    'fisica',
    'intelectual',
    'emocional',
    'social',
    'moral',
  ];

  static String label(String category) {
    switch (category.trim().toLowerCase()) {
      case 'fisica':
        return 'Física';
      case 'intelectual':
        return 'Intelectual';
      case 'emocional':
        return 'Emocional';
      case 'social':
        return 'Social';
      case 'moral':
        return 'Moral';
      default:
        return category;
    }
  }

  static IconData icon(String category) {
    switch (category.trim().toLowerCase()) {
      case 'fisica':
        return Icons.fitness_center;
      case 'intelectual':
        return Icons.psychology;
      case 'emocional':
        return Icons.favorite;
      case 'social':
        return Icons.groups;
      case 'moral':
        return Icons.balance;
      default:
        return Icons.category;
    }
  }

  static Color color(String category) {
    switch (category.trim().toLowerCase()) {
      case 'fisica':
        return Colors.blue;
      case 'intelectual':
        return Colors.deepPurple;
      case 'emocional':
        return Colors.pink;
      case 'social':
        return Colors.orange;
      case 'moral':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}

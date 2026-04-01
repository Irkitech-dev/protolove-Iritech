import 'prototype_category_utils.dart';

class CandidateScoreUtils {
  static List<String> get categories => PrototypeCategoryUtils.categories;

  static String label(String category) {
    return PrototypeCategoryUtils.label(category);
  }

  static double categoryScore(
    List<Map<String, dynamic>> rows,
    String category,
  ) {
    final current =
        rows
            .where(
              (r) =>
                  (r['category'] ?? '').toString().trim().toLowerCase() ==
                  category.trim().toLowerCase(),
            )
            .toList();

    if (current.isEmpty) return 0;

    double totalWeight = 0;
    for (final row in current) {
      totalWeight += ((row['weight'] ?? 0) as num).toDouble();
    }

    if (totalWeight == 0) return 0;

    double total = 0;
    for (final row in current) {
      final score = ((row['score'] ?? 0) as num).toDouble();
      final weight = ((row['weight'] ?? 0) as num).toDouble();

      total += score * (weight / (5 * totalWeight));
    }

    return total;
  }

  static Map<String, double> categoryScores(List<Map<String, dynamic>> rows) {
    return {for (final c in categories) c: categoryScore(rows, c)};
  }

  static double totalScore(List<Map<String, dynamic>> rows) {
    double total = 0;
    for (final c in categories) {
      total += categoryScore(rows, c);
    }
    return total;
  }

  static double percentage(List<Map<String, dynamic>> rows) {
    return (totalScore(rows) / 10) * 100;
  }

  static List<String> missingNonNegotiables(List<Map<String, dynamic>> rows) {
    return rows
        .where((r) {
          final isRequired = (r['is_required'] as bool?) ?? false;
          final score = r['score'] as int?;
          return isRequired && (score == null || score < 10);
        })
        .map((r) => (r['trait_name'] ?? '').toString())
        .where((e) => e.trim().isNotEmpty)
        .toList();
  }

  static bool hasNonNegotiableIssue(List<Map<String, dynamic>> rows) {
    return missingNonNegotiables(rows).isNotEmpty;
  }

  static String idealMessage(List<Map<String, dynamic>> rows) {
    final missing = missingNonNegotiables(rows);

    if (missing.isEmpty) {
      return 'Sí cumple con todos tus no negociables.';
    }

    if (missing.length == 1) {
      return 'No cumple con el no negociable "${missing.first}".';
    }

    return 'No cumple con estos no negociables: ${missing.map((e) => '"$e"').join(', ')}.';
  }
}

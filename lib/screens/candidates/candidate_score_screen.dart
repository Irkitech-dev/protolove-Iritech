import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../utils/app_colors.dart';
import '../../utils/candidate_score_utils.dart';
import '../../utils/prototype_category_utils.dart';
import 'candidate_traits_detail_screen.dart';

class CandidateScoreScreen extends StatefulWidget {
  final String candidateId;
  final String candidateName;

  const CandidateScoreScreen({
    super.key,
    required this.candidateId,
    required this.candidateName,
  });

  @override
  State<CandidateScoreScreen> createState() => _CandidateScoreScreenState();
}

class _CandidateScoreScreenState extends State<CandidateScoreScreen> {
  bool loading = true;
  List<Map<String, dynamic>> rows = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      setState(() => loading = true);

      final data = await Supabase.instance.client
          .from('plv_candidate_scores')
          .select(
            'id,candidate_id,prototype_trait_id,category,trait_name,weight,is_required,score',
          )
          .eq('candidate_id', widget.candidateId)
          .order('category')
          .order('is_required', ascending: false)
          .order('weight', ascending: false)
          .order('trait_name');

      if (!mounted) return;

      setState(() {
        rows = List<Map<String, dynamic>>.from(data);
        loading = false;
      });
    } on PostgrestException catch (_) {
      if (!mounted) return;
      setState(() => loading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No se pudo cargar')));
    }
  }

  Widget _summaryCard({
    required String title,
    required String value,
    required String subtitle,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: color.withOpacity(0.20)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: color.withOpacity(0.14),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(color: color, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _categoryCard(String category, double score, int count) {
    final color = PrototypeCategoryUtils.color(category);

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (_) => CandidateTraitsDetailScreen(
                  candidateId: widget.candidateId,
                  candidateName: widget.candidateName,
                  category: category,
                ),
          ),
        );
        await _load();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withOpacity(0.20)),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 140, maxWidth: 160),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: color.withOpacity(0.12),
                  child: Icon(
                    PrototypeCategoryUtils.icon(category),
                    color: color,
                    size: 20,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  CandidateScoreUtils.label(category),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${score.toStringAsFixed(2)} / 2.00',
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$count rasgos',
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  int _categoryCount(String category) {
    return rows
        .where(
          (r) =>
              (r['category'] ?? '').toString().trim().toLowerCase() == category,
        )
        .length;
  }

  @override
  Widget build(BuildContext context) {
    final total = CandidateScoreUtils.totalScore(rows);
    final percentage = CandidateScoreUtils.percentage(rows);
    final missing = CandidateScoreUtils.missingNonNegotiables(rows);
    final hasIssue = missing.isNotEmpty;
    final categoryScores = CandidateScoreUtils.categoryScores(rows);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.candidateName),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(onPressed: _load, icon: const Icon(Icons.refresh)),
        ],
      ),
      body:
          loading
              ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
              : rows.isEmpty
              ? const Center(child: Text('No hay rasgos para puntuar'))
              : RefreshIndicator(
                onRefresh: _load,
                color: AppColors.primary,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _summaryCard(
                      title: 'Resultado',
                      value: '${percentage.toStringAsFixed(0)}%',
                      subtitle: 'Total: ${total.toStringAsFixed(2)} / 10.00',
                      color: hasIssue ? AppColors.danger : AppColors.primary,
                      icon:
                          hasIssue
                              ? Icons.warning_amber_rounded
                              : Icons.verified,
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color:
                            hasIssue
                                ? AppColors.dangerSoft
                                : AppColors.successSoft,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color:
                              hasIssue
                                  ? AppColors.danger.withOpacity(0.18)
                                  : AppColors.success.withOpacity(0.18),
                        ),
                      ),
                      child: Text(
                        hasIssue ? 'Le faltan rasgos obligatorios' : 'Va bien',
                        style: TextStyle(
                          color:
                              hasIssue ? AppColors.danger : AppColors.success,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Toca una categoría para puntuar',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: 1.05,
                      children:
                          CandidateScoreUtils.categories
                              .map(
                                (c) => _categoryCard(
                                  c,
                                  categoryScores[c] ?? 0,
                                  _categoryCount(c),
                                ),
                              )
                              .toList(),
                    ),
                  ],
                ),
              ),
    );
  }
}

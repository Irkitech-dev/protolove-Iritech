import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../utils/candidate_score_utils.dart';
import '../../utils/prototype_category_utils.dart';

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
  String selectedCategory = 'fisica';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
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

    await _saveGlobalResult();
  }

  List<Map<String, dynamic>> get current =>
      rows
          .where(
            (r) =>
                (r['category'] ?? '').toString().trim().toLowerCase() ==
                selectedCategory,
          )
          .toList();

  Future<void> _updateScore(String scoreRowId, int? newScore) async {
    await Supabase.instance.client
        .from('plv_candidate_scores')
        .update({'score': newScore})
        .eq('id', scoreRowId);

    final idx = rows.indexWhere((e) => e['id'] == scoreRowId);
    if (idx != -1) {
      setState(() {
        rows[idx]['score'] = newScore;
      });
    }

    await _saveGlobalResult();
  }

  Future<void> _saveGlobalResult() async {
    final total = CandidateScoreUtils.totalScore(rows);

    try {
      await Supabase.instance.client.from('plv_candidate_results').upsert({
        'candidate_id': widget.candidateId,
        'compatibility_score': total,
      }, onConflict: 'candidate_id');
    } catch (_) {}
  }

  Widget _summaryCard({
    required String title,
    required String value,
    required String subtitle,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.15),
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
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(subtitle, style: TextStyle(color: Colors.grey[700])),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _categoryScoreCard(String category, double score) {
    final color = PrototypeCategoryUtils.color(category);
    final selected = selectedCategory == category;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => setState(() => selectedCategory = category),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.16) : color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? color : color.withOpacity(0.20),
            width: selected ? 1.6 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(PrototypeCategoryUtils.icon(category), color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              CandidateScoreUtils.label(category),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${score.toStringAsFixed(2)} / 2.00',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _traitCard(Map<String, dynamic> r) {
    final isReq = (r['is_required'] as bool?) ?? false;
    final score = r['score'] as int?;
    final failed = isReq && (score == null || score < 10);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: failed ? Colors.red.withOpacity(0.06) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: failed ? Colors.red.withOpacity(0.25) : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor:
                failed
                    ? Colors.red.withOpacity(0.12)
                    : Colors.pinkAccent.withOpacity(0.12),
            child: Icon(
              isReq ? Icons.lock : Icons.star_border,
              color: failed ? Colors.red : Colors.pinkAccent,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (r['trait_name'] ?? '').toString(),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: failed ? Colors.red[800] : null,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Importancia: ${r['weight']}/10${isReq ? " • No negociable" : ""}',
                  style: TextStyle(
                    color: failed ? Colors.red[700] : Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
          DropdownButton<int?>(
            value: score,
            hint: const Text('—'),
            items: [
              const DropdownMenuItem<int?>(value: null, child: Text('—')),
              ...List.generate(
                11,
                (i) => DropdownMenuItem<int?>(value: i, child: Text('$i')),
              ),
            ],
            onChanged: (v) => _updateScore(r['id'] as String, v),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final total = CandidateScoreUtils.totalScore(rows);
    final percentage = CandidateScoreUtils.percentage(rows);
    final missing = CandidateScoreUtils.missingNonNegotiables(rows);
    final hasIssue = missing.isNotEmpty;
    final categoryScores = CandidateScoreUtils.categoryScores(rows);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.candidateName),
        backgroundColor: Colors.pinkAccent,
        actions: [
          IconButton(onPressed: _load, icon: const Icon(Icons.refresh)),
        ],
      ),
      body:
          loading
              ? const Center(child: CircularProgressIndicator())
              : rows.isEmpty
              ? const Center(
                child: Text(
                  'Este candidato no tiene características para calificar.',
                  textAlign: TextAlign.center,
                ),
              )
              : RefreshIndicator(
                onRefresh: _load,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _summaryCard(
                      title: 'Resultado Excel',
                      value: '${percentage.toStringAsFixed(0)}%',
                      subtitle: 'Total: ${total.toStringAsFixed(2)} / 10.00',
                      color: hasIssue ? Colors.red : Colors.green,
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
                                ? Colors.red.withOpacity(0.10)
                                : Colors.green.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: hasIssue ? Colors.red : Colors.green,
                        ),
                      ),
                      child: Text(
                        CandidateScoreUtils.idealMessage(rows),
                        style: TextStyle(
                          color: hasIssue ? Colors.red[800] : Colors.green[800],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Resumen por categoría',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: 1.35,
                      children:
                          CandidateScoreUtils.categories
                              .map(
                                (c) => _categoryScoreCard(
                                  c,
                                  categoryScores[c] ?? 0,
                                ),
                              )
                              .toList(),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Características de ${CandidateScoreUtils.label(selectedCategory)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...current.map(_traitCard),
                  ],
                ),
              ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../utils/app_colors.dart';
import '../../utils/prototype_category_utils.dart';

class CandidateTraitsDetailScreen extends StatefulWidget {
  final String candidateId;
  final String candidateName;
  final String category;

  const CandidateTraitsDetailScreen({
    super.key,
    required this.candidateId,
    required this.candidateName,
    required this.category,
  });

  @override
  State<CandidateTraitsDetailScreen> createState() =>
      _CandidateTraitsDetailScreenState();
}

class _CandidateTraitsDetailScreenState
    extends State<CandidateTraitsDetailScreen> {
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
            'id,candidate_id,category,trait_name,weight,is_required,score',
          )
          .eq('candidate_id', widget.candidateId)
          .eq('category', widget.category)
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

  Future<void> _updateScore(String scoreRowId, int? newScore) async {
    try {
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
    } on PostgrestException catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No se pudo guardar')));
    }
  }

  Widget _traitCard(Map<String, dynamic> r) {
    final isReq = (r['is_required'] as bool?) ?? false;
    final score = r['score'] as int?;
    final failed = isReq && (score == null || score < 10);
    final color =
        failed
            ? AppColors.danger
            : PrototypeCategoryUtils.color(widget.category);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: failed ? AppColors.dangerSoft : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: failed ? AppColors.danger.withOpacity(0.22) : AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.14),
            child: Icon(
              isReq ? Icons.lock : Icons.favorite_outline,
              color: color,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (r['trait_name'] ?? '').toString(),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Peso ${r['weight']}/10${isReq ? " • Obligatorio" : ""}',
                  style: const TextStyle(color: AppColors.textSecondary),
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
    final title = PrototypeCategoryUtils.label(widget.category);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('$title - ${widget.candidateName}'),
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
              ? const Center(child: Text('No hay rasgos en esta categoría'))
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: rows.length,
                itemBuilder: (_, i) => _traitCard(rows[i]),
              ),
    );
  }
}

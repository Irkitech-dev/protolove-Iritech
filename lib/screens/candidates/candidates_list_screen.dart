import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../utils/app_colors.dart';
import '../../utils/candidate_score_utils.dart';
import 'candidate_create_screen.dart';
import 'candidate_score_screen.dart';

class CandidatesListScreen extends StatefulWidget {
  const CandidatesListScreen({super.key});

  @override
  State<CandidatesListScreen> createState() => _CandidatesListScreenState();
}

class _CandidatesListScreenState extends State<CandidatesListScreen> {
  bool loading = true;
  List<Map<String, dynamic>> items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => loading = true);

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      setState(() {
        items = [];
        loading = false;
      });
      return;
    }

    final data = await Supabase.instance.client
        .from('plv_candidates')
        .select('id,name,alias,created_at')
        .eq('user_id', user.id)
        .order('created_at', ascending: false);

    final candidates = List<Map<String, dynamic>>.from(data);

    final enriched = await Future.wait(
      candidates.map((candidate) async {
        final scores = await Supabase.instance.client
            .from('plv_candidate_scores')
            .select(
              'id,candidate_id,prototype_trait_id,category,trait_name,weight,is_required,score',
            )
            .eq('candidate_id', candidate['id']);

        final rows = List<Map<String, dynamic>>.from(scores);
        final percentage = CandidateScoreUtils.percentage(rows);
        final total = CandidateScoreUtils.totalScore(rows);
        final missing = CandidateScoreUtils.missingNonNegotiables(rows);
        final hasIssue = missing.isNotEmpty;

        return {
          ...candidate,
          'percentage': percentage,
          'total': total,
          'missing_non_negotiables': missing,
          'has_non_negotiable_issue': hasIssue,
        };
      }),
    );

    enriched.sort((a, b) {
      final aIssue = (a['has_non_negotiable_issue'] as bool?) ?? false;
      final bIssue = (b['has_non_negotiable_issue'] as bool?) ?? false;

      if (aIssue != bIssue) {
        return aIssue ? 1 : -1;
      }

      final aPercentage = ((a['percentage'] ?? 0) as num).toDouble();
      final bPercentage = ((b['percentage'] ?? 0) as num).toDouble();
      return bPercentage.compareTo(aPercentage);
    });

    if (!mounted) return;

    setState(() {
      items = enriched;
      loading = false;
    });
  }

  Future<bool> _ensurePrototypeReady() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return false;

    final prototype =
        await Supabase.instance.client
            .from('plv_prototypes')
            .select('id')
            .eq('user_id', user.id)
            .maybeSingle();

    if (prototype == null) {
      if (!mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Primero crea tu prototipo')),
      );
      return false;
    }

    final prototypeId = prototype['id'] as String;

    final traits = await Supabase.instance.client
        .from('plv_prototype_traits')
        .select('id')
        .eq('prototype_id', prototypeId)
        .limit(1);

    if (traits.isEmpty) {
      if (!mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Agrega rasgos al prototipo')),
      );
      return false;
    }

    return true;
  }

  Future<void> _deleteCandidate(String candidateId, String name) async {
    final confirm =
        await showDialog<bool>(
          context: context,
          builder:
              (_) => AlertDialog(
                title: const Text('Eliminar'),
                content: Text('¿Eliminar a "$name"?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancelar'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text(
                      'Eliminar',
                      style: TextStyle(color: AppColors.danger),
                    ),
                  ),
                ],
              ),
        ) ??
        false;

    if (!confirm) return;

    try {
      await Supabase.instance.client
          .from('plv_candidates')
          .delete()
          .eq('id', candidateId);

      await _load();

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Candidato eliminado')));
    } on PostgrestException catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No se pudo eliminar')));
    }
  }

  Widget _candidateCard(Map<String, dynamic> c) {
    final name = (c['name'] ?? '').toString();
    final alias = (c['alias'] ?? '').toString().trim();
    final percentage = ((c['percentage'] ?? 0) as num).toDouble();
    final total = ((c['total'] ?? 0) as num).toDouble();
    final hasIssue = (c['has_non_negotiable_issue'] as bool?) ?? false;
    final issues = List<String>.from(c['missing_non_negotiables'] ?? []);

    final color = hasIssue ? AppColors.danger : AppColors.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: hasIssue ? AppColors.dangerSoft : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color:
              hasIssue ? AppColors.danger.withOpacity(0.18) : AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withOpacity(0.14),
                child: Icon(Icons.person, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  alias.isNotEmpty ? '$name ($alias)' : name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${percentage.toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  Text(
                    '${total.toStringAsFixed(2)} / 10',
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: (percentage.clamp(0, 100)) / 100,
              minHeight: 10,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              hasIssue ? 'Pendientes: ${issues.join(", ")}' : 'Todo bien',
              style: TextStyle(
                color: hasIssue ? AppColors.danger : AppColors.primaryDark,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) => CandidateScoreScreen(
                              candidateId: c['id'] as String,
                              candidateName: name,
                            ),
                      ),
                    );
                    await _load();
                  },
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Puntuar'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: BorderSide(
                      color: AppColors.primary.withOpacity(0.25),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _deleteCandidate(c['id'] as String, name),
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Eliminar'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.danger,
                    side: BorderSide(color: AppColors.danger.withOpacity(0.25)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mis Candidatos'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        onPressed: () async {
          final ok = await _ensurePrototypeReady();
          if (!ok) return;

          final result = await Navigator.push<Map<String, dynamic>>(
            context,
            MaterialPageRoute(builder: (_) => const CandidateCreateScreen()),
          );

          if (result != null && result['created'] == true) {
            await _load();

            if (!mounted) return;

            await Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (_) => CandidateScoreScreen(
                      candidateId: result['candidateId'] as String,
                      candidateName: result['candidateName'] as String,
                    ),
              ),
            );

            await _load();
          }
        },
        child: const Icon(Icons.add),
      ),
      body:
          loading
              ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
              : items.isEmpty
              ? const Center(child: Text('Aún no tienes candidatos'))
              : RefreshIndicator(
                onRefresh: _load,
                color: AppColors.primary,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  itemBuilder: (_, i) => _candidateCard(items[i]),
                ),
              ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
            .select('score,weight,is_required,trait_name')
            .eq('candidate_id', candidate['id']);

        final rows = List<Map<String, dynamic>>.from(scores);

        double weightedSum = 0;
        double totalWeight = 0;

        final missingNonNegotiables = <String>[];

        for (final row in rows) {
          final score = row['score'];
          final weight = row['weight'];

          if (score != null && weight != null) {
            weightedSum += (score as int) * (weight as int);
            totalWeight += (weight as int).toDouble();
          }

          final isRequired = (row['is_required'] as bool?) ?? false;
          final candidateScore = row['score'] as int?;

          if (isRequired && (candidateScore == null || candidateScore < 10)) {
            missingNonNegotiables.add((row['trait_name'] ?? '').toString());
          }
        }

        final globalScore = totalWeight == 0 ? 0.0 : weightedSum / totalWeight;
        final percentage = (globalScore / 10) * 100;

        return {
          ...candidate,
          'global_score': globalScore,
          'percentage': percentage,
          'missing_non_negotiables': missingNonNegotiables,
          'has_non_negotiable_issue': missingNonNegotiables.isNotEmpty,
        };
      }),
    );

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
        const SnackBar(content: Text('Primero crea tu Prototipo 💖')),
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
        const SnackBar(
          content: Text(
            'Agrega rasgos al prototipo antes de crear candidatos ✍️',
          ),
        ),
      );
      return false;
    }

    return true;
  }

  String _buildSubtitle(Map<String, dynamic> c) {
    final alias = (c['alias'] ?? '').toString().trim();
    final percentage = ((c['percentage'] ?? 0.0) as num).toDouble();
    final hasIssue = (c['has_non_negotiable_issue'] as bool?) ?? false;

    final aliasText = alias.isEmpty ? 'Sin alias' : alias;
    final percentText = '${percentage.toStringAsFixed(0)}% de compatibilidad';

    if (hasIssue) {
      return '$aliasText • $percentText • Tiene no negociables pendientes';
    }

    return '$aliasText • $percentText';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Candidatos'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final ok = await _ensurePrototypeReady();
          if (!ok) return;

          final created = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => const CandidateCreateScreen()),
          );

          if (created == true) {
            _load();
          }
        },
        child: const Icon(Icons.add),
      ),
      body:
          loading
              ? const Center(child: CircularProgressIndicator())
              : items.isEmpty
              ? const Center(child: Text('Aún no tienes candidatos.'))
              : ListView.separated(
                itemCount: items.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, i) {
                  final c = items[i];
                  final hasIssue =
                      (c['has_non_negotiable_issue'] as bool?) ?? false;
                  final percentage =
                      ((c['percentage'] ?? 0.0) as num).toDouble();

                  final primaryColor =
                      hasIssue
                          ? Colors.red
                          : Theme.of(context).colorScheme.primary;

                  return ListTile(
                    leading: Icon(
                      Icons.person,
                      color: hasIssue ? Colors.red : null,
                    ),
                    title: Text(
                      c['name'] ?? '',
                      style: TextStyle(
                        color: hasIssue ? Colors.red : null,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      _buildSubtitle(c),
                      style: TextStyle(
                        color: hasIssue ? Colors.red : Colors.black54,
                      ),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${percentage.toStringAsFixed(0)}%',
                          style: TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        if (hasIssue)
                          const Text(
                            'Revisar',
                            style: TextStyle(color: Colors.red, fontSize: 11),
                          ),
                      ],
                    ),
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => CandidateScoreScreen(
                                candidateId: c['id'] as String,
                                candidateName: c['name'] as String,
                              ),
                        ),
                      );
                      _load();
                    },
                  );
                },
              ),
    );
  }
}

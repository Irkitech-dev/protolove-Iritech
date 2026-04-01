import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
          'rows': rows,
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
        const SnackBar(content: Text('Primero crea tu prototipo 💖')),
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
            'Agrega características al prototipo antes de crear candidatos.',
          ),
        ),
      );
      return false;
    }

    return true;
  }

  Widget _candidateCard(Map<String, dynamic> c) {
    final name = (c['name'] ?? '').toString();
    final alias = (c['alias'] ?? '').toString().trim();
    final percentage = ((c['percentage'] ?? 0) as num).toDouble();
    final total = ((c['total'] ?? 0) as num).toDouble();
    final hasIssue = (c['has_non_negotiable_issue'] as bool?) ?? false;
    final issues = List<String>.from(c['missing_non_negotiables'] ?? []);

    final color = hasIssue ? Colors.red : Colors.green;

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () async {
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
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.20)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: color.withOpacity(0.15),
                  child: Icon(Icons.person, color: color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (alias.isNotEmpty)
                        Text(alias, style: TextStyle(color: Colors.grey[700])),
                    ],
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
                      style: TextStyle(color: Colors.grey[700]),
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
                hasIssue
                    ? 'No negociables pendientes: ${issues.join(", ")}'
                    : 'Cumple con los no negociables',
                style: TextStyle(
                  color: hasIssue ? Colors.red[800] : Colors.green[800],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Candidatos'),
        backgroundColor: Colors.pinkAccent,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.pinkAccent,
        onPressed: () async {
          final ok = await _ensurePrototypeReady();
          if (!ok) return;

          final created = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => const CandidateCreateScreen()),
          );

          if (created == true) {
            await _load();
          }
        },
        child: const Icon(Icons.add),
      ),
      body:
          loading
              ? const Center(child: CircularProgressIndicator())
              : items.isEmpty
              ? const Center(child: Text('Aún no tienes candidatos.'))
              : RefreshIndicator(
                onRefresh: _load,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  itemBuilder: (_, i) => _candidateCard(items[i]),
                ),
              ),
    );
  }
}

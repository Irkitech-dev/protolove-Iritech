import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  static const categories = [
    'fisica',
    'intelectual',
    'emocional',
    'social',
    'moral',
  ];
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
        .select('id,category,trait_name,weight,is_required,score')
        .eq('candidate_id', widget.candidateId)
        .order('category')
        .order('trait_name');

    setState(() {
      rows = List<Map<String, dynamic>>.from(data);
      loading = false;
    });
  }

  List<Map<String, dynamic>> get current =>
      rows.where((r) => r['category'] == selectedCategory).toList();

  double _calcGlobalScore() {
    double sum = 0;
    double wsum = 0;

    for (final r in rows) {
      final s = r['score'];
      if (s == null) continue;
      final w = (r['weight'] as int).toDouble();
      sum += (s as int).toDouble() * w;
      wsum += w;
    }
    if (wsum == 0) return 0;
    return sum / wsum;
  }

  Future<void> _updateScore(String scoreRowId, int? newScore) async {
    await Supabase.instance.client
        .from('plv_candidate_scores')
        .update({'score': newScore})
        .eq('id', scoreRowId);

    final idx = rows.indexWhere((e) => e['id'] == scoreRowId);
    if (idx != -1) setState(() => rows[idx]['score'] = newScore);
  }

  Future<void> _saveGlobalResult() async {
    final global = _calcGlobalScore();

    try {
      await Supabase.instance.client.from('plv_candidate_results').upsert(
        {'candidate_id': widget.candidateId, 'compatibility_score': global},
        onConflict: 'candidate_id', // ✅ CLAVE para no duplicar
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Calificación global: ${global.toStringAsFixed(2)}'),
        ),
      );
    } on PostgrestException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error guardando: ${e.message}')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error inesperado: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final global = _calcGlobalScore();

    return Scaffold(
      appBar: AppBar(
        title: Text('Calificar: ${widget.candidateName}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveGlobalResult,
            tooltip: 'Guardar calificación global',
          ),
        ],
      ),
      body:
          loading
              ? const Center(child: CircularProgressIndicator())
              : rows.isEmpty
              ? const Center(
                child: Text(
                  'Este candidato no tiene rasgos para calificar.\nAsegúrate de tener prototipo + rasgos.',
                  textAlign: TextAlign.center,
                ),
              )
              : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Global: ${global.toStringAsFixed(2)} / 10',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        DropdownButton<String>(
                          value: selectedCategory,
                          items:
                              categories
                                  .map(
                                    (c) => DropdownMenuItem(
                                      value: c,
                                      child: Text(c.toUpperCase()),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (v) {
                            if (v == null) return;
                            setState(() => selectedCategory = v);
                          },
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: ListView.separated(
                      itemCount: current.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (_, i) {
                        final r = current[i];
                        final isReq = (r['is_required'] as bool?) ?? false;
                        final score = r['score'] as int?;

                        return ListTile(
                          title: Text(r['trait_name']),
                          subtitle: Text(
                            'Peso: ${r['weight']} • ${isReq ? "No negociable" : "Opcional"}',
                          ),
                          trailing: DropdownButton<int?>(
                            value: score,
                            hint: const Text('—'),
                            items: [
                              const DropdownMenuItem(
                                value: null,
                                child: Text('—'),
                              ),
                              ...List.generate(
                                11,
                                (i) => DropdownMenuItem(
                                  value: i,
                                  child: Text('$i'),
                                ),
                              ),
                            ],
                            onChanged:
                                (v) => _updateScore(r['id'] as String, v),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
    );
  }
}

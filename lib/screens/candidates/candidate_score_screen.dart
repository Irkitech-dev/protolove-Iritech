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

    if (!mounted) return;

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

  double _calcGlobalPercentage() {
    return (_calcGlobalScore() / 10) * 100;
  }

  List<String> _missingNonNegotiables() {
    return rows
        .where((r) {
          final isRequired = (r['is_required'] as bool?) ?? false;
          final score = r['score'] as int?;
          return isRequired && (score == null || score < 10);
        })
        .map((r) => (r['trait_name'] ?? '').toString())
        .where((name) => name.isNotEmpty)
        .toList();
  }

  String _idealCandidateMessage() {
    final missing = _missingNonNegotiables();

    if (missing.isEmpty) {
      return 'Sí cumple con todos tus no negociables. Este candidato mantiene intactos tus requisitos esenciales.';
    }

    if (missing.length == 1) {
      return 'Aún no es tu candidato ideal: no cumple completamente con tu no negociable más importante: ${missing.first}.';
    }

    return 'Aún no es tu candidato ideal: no cumple completamente con estos no negociables esenciales para ti: ${missing.join(', ')}.';
  }

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
  }

  Future<void> _saveGlobalResult() async {
    final global = _calcGlobalScore();

    try {
      await Supabase.instance.client.from('plv_candidate_results').upsert({
        'candidate_id': widget.candidateId,
        'compatibility_score': global,
      }, onConflict: 'candidate_id');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Compatibilidad guardada: ${_calcGlobalPercentage().toStringAsFixed(0)}%',
          ),
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
    final percentage = _calcGlobalPercentage();
    final missingNonNegotiables = _missingNonNegotiables();
    final hasIssue = missingNonNegotiables.isNotEmpty;

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
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.all(12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color:
                          hasIssue
                              ? Colors.red.withOpacity(0.10)
                              : Colors.green.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: hasIssue ? Colors.red : Colors.green,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          hasIssue
                              ? Icons.warning_amber_rounded
                              : Icons.verified,
                          color: hasIssue ? Colors.red : Colors.green,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _idealCandidateMessage(),
                            style: TextStyle(
                              color:
                                  hasIssue
                                      ? Colors.red[800]
                                      : Colors.green[800],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Global: ${global.toStringAsFixed(2)} / 10  •  ${percentage.toStringAsFixed(0)}%',
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
                  const SizedBox(height: 8),
                  const Divider(height: 1),
                  Expanded(
                    child: ListView.separated(
                      itemCount: current.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (_, i) {
                        final r = current[i];
                        final isReq = (r['is_required'] as bool?) ?? false;
                        final score = r['score'] as int?;
                        final isRequiredFail =
                            isReq && (score == null || score < 10);

                        return ListTile(
                          tileColor:
                              isRequiredFail
                                  ? Colors.red.withOpacity(0.06)
                                  : null,
                          title: Text(
                            r['trait_name'],
                            style: TextStyle(
                              color: isRequiredFail ? Colors.red[800] : null,
                              fontWeight:
                                  isRequiredFail
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                            ),
                          ),
                          subtitle: Text(
                            'Peso: ${r['weight']} • ${isReq ? "No negociable" : "Opcional"}',
                            style: TextStyle(
                              color: isRequiredFail ? Colors.red[700] : null,
                            ),
                          ),
                          trailing: DropdownButton<int?>(
                            value: score,
                            hint: const Text('—'),
                            items: [
                              const DropdownMenuItem<int?>(
                                value: null,
                                child: Text('—'),
                              ),
                              ...List.generate(
                                11,
                                (i) => DropdownMenuItem<int?>(
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

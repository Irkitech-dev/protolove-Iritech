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
    if (user == null) return;

    final data = await Supabase.instance.client
        .from('plv_candidates')
        .select('id,name,alias,created_at')
        .eq('user_id', user.id)
        .order('created_at', ascending: false);

    setState(() {
      items = List<Map<String, dynamic>>.from(data);
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
          if (created == true) _load();
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
                  return ListTile(
                    leading: const Icon(Icons.person),
                    title: Text(c['name'] ?? ''),
                    subtitle: Text(
                      (c['alias'] ?? '').toString().isEmpty
                          ? 'Sin alias'
                          : c['alias'],
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => CandidateScoreScreen(
                                candidateId: c['id'] as String,
                                candidateName: c['name'] as String,
                              ),
                        ),
                      );
                    },
                  );
                },
              ),
    );
  }
}

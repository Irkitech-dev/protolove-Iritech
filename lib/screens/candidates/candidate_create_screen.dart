import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CandidateCreateScreen extends StatefulWidget {
  const CandidateCreateScreen({super.key});

  @override
  State<CandidateCreateScreen> createState() => _CandidateCreateScreenState();
}

class _CandidateCreateScreenState extends State<CandidateCreateScreen> {
  final nameCtrl = TextEditingController();
  final aliasCtrl = TextEditingController();
  bool saving = false;

  @override
  void dispose() {
    nameCtrl.dispose();
    aliasCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = nameCtrl.text.trim();
    final alias = aliasCtrl.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa el nombre del candidato')),
      );
      return;
    }

    setState(() => saving = true);

    try {
      await Supabase.instance.client.rpc(
        'create_candidate_with_scores',
        params: {'p_name': name, 'p_alias': alias.isEmpty ? null : alias},
      );

      if (!mounted) return;
      Navigator.pop(context, true);
    } on PostgrestException catch (e) {
      final msg =
          e.message.contains('Prototype not found')
              ? 'Primero crea tu prototipo y agrega rasgos.'
              : e.message;

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $msg')));
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo candidato')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Nombre del candidato/a',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: aliasCtrl,
              decoration: const InputDecoration(
                labelText: 'Alias (opcional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: saving ? null : _save,
                child:
                    saving
                        ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : const Text('Crear candidato'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

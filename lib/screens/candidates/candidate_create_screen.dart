import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../utils/app_colors.dart';

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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Escribe el nombre')));
      return;
    }

    setState(() => saving = true);

    try {
      final candidateId = await Supabase.instance.client.rpc(
        'create_candidate_with_scores',
        params: {'p_name': name, 'p_alias': alias.isEmpty ? null : alias},
      );

      if (!mounted) return;

      Navigator.pop(context, {
        'created': true,
        'candidateId': candidateId,
        'candidateName': name,
      });
    } on PostgrestException catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo crear el candidato')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Ocurrió un error')));
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Nuevo candidato'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nameCtrl,
              decoration: InputDecoration(
                labelText: 'Nombre',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: aliasCtrl,
              decoration: InputDecoration(
                labelText: 'Alias (opcional)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child:
                    saving
                        ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                        : const Text('Crear y puntuar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TraitsListScreen extends StatefulWidget {
  final String prototypeId;

  const TraitsListScreen({super.key, required this.prototypeId});

  @override
  State<TraitsListScreen> createState() => _TraitsListScreenState();
}

class _TraitsListScreenState extends State<TraitsListScreen> {
  final supabase = Supabase.instance.client;

  bool loading = true;
  List<Map<String, dynamic>> traits = [];

  static const categories = [
    'fisica',
    'intelectual',
    'emocional',
    'social',
    'moral',
  ];

  @override
  void initState() {
    super.initState();
    _loadTraits();
  }

  Future<void> _loadTraits() async {
    setState(() => loading = true);

    final data = await supabase
        .from('plv_prototype_traits')
        .select(
          'id, category, name, description, weight, is_required, created_at',
        )
        .eq('prototype_id', widget.prototypeId)
        .order('category')
        .order('name');

    setState(() {
      traits = List<Map<String, dynamic>>.from(data);
      loading = false;
    });
  }

  Future<void> _deleteTrait(String traitId) async {
    try {
      await supabase.from('plv_prototype_traits').delete().eq('id', traitId);

      await _loadTraits();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Rasgo eliminado ✅')));
    } on PostgrestException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.message}')));
    }
  }

  Future<void> _openTraitForm({Map<String, dynamic>? existing}) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (_) => _TraitFormSheet(
            prototypeId: widget.prototypeId,
            existing: existing,
          ),
    );

    if (saved == true) _loadTraits();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Características del Prototipo'),
        backgroundColor: Colors.pinkAccent,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadTraits),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.pinkAccent,
        onPressed: () => _openTraitForm(),
        child: const Icon(Icons.add),
      ),
      body:
          loading
              ? const Center(child: CircularProgressIndicator())
              : traits.isEmpty
              ? _emptyState()
              : ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: traits.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) {
                  final t = traits[i];
                  final isReq = (t['is_required'] as bool?) ?? false;

                  return Dismissible(
                    key: ValueKey(t['id']),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 18),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    confirmDismiss: (_) async {
                      return await showDialog<bool>(
                            context: context,
                            builder:
                                (_) => AlertDialog(
                                  title: const Text('Eliminar rasgo'),
                                  content: Text('¿Eliminar "${t['name']}"?'),
                                  actions: [
                                    TextButton(
                                      onPressed:
                                          () => Navigator.pop(context, false),
                                      child: const Text('Cancelar'),
                                    ),
                                    TextButton(
                                      onPressed:
                                          () => Navigator.pop(context, true),
                                      child: const Text(
                                        'Eliminar',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                ),
                          ) ??
                          false;
                    },
                    onDismissed: (_) => _deleteTrait(t['id'] as String),
                    child: InkWell(
                      onTap: () => _openTraitForm(existing: t),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 10,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.pinkAccent.withOpacity(
                                0.15,
                              ),
                              child: Icon(
                                isReq ? Icons.lock : Icons.star_border,
                                color: Colors.pinkAccent,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    t['name'] ?? '',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${(t['category'] as String).toUpperCase()} • Peso: ${t['weight']}'
                                    '${isReq ? " • No negociable" : ""}',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                  if ((t['description'] ?? '')
                                      .toString()
                                      .isNotEmpty) ...[
                                    const SizedBox(height: 6),
                                    Text(
                                      t['description'],
                                      style: TextStyle(color: Colors.grey[700]),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border,
              size: 70,
              color: Colors.pinkAccent.withOpacity(0.6),
            ),
            const SizedBox(height: 12),
            const Text(
              'Tu prototipo está vacío',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              'Agrega características para comenzar.\nToca el botón +',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}

class _TraitFormSheet extends StatefulWidget {
  final String prototypeId;
  final Map<String, dynamic>? existing;

  const _TraitFormSheet({required this.prototypeId, this.existing});

  @override
  State<_TraitFormSheet> createState() => _TraitFormSheetState();
}

class _TraitFormSheetState extends State<_TraitFormSheet> {
  final supabase = Supabase.instance.client;

  final nameCtrl = TextEditingController();
  final descCtrl = TextEditingController();

  String category = 'fisica';
  double weight = 5;
  bool isRequired = false;

  bool saving = false;

  bool get editing => widget.existing != null;

  @override
  void initState() {
    super.initState();

    if (editing) {
      final e = widget.existing!;
      nameCtrl.text = (e['name'] ?? '').toString();
      descCtrl.text = (e['description'] ?? '').toString();
      category = (e['category'] ?? 'fisica').toString();
      weight = ((e['weight'] ?? 5) as int).toDouble();
      isRequired = (e['is_required'] as bool?) ?? false;
    }
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    descCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = nameCtrl.text.trim();
    final desc = descCtrl.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa el nombre del rasgo')),
      );
      return;
    }

    setState(() => saving = true);

    try {
      if (editing) {
        await supabase
            .from('plv_prototype_traits')
            .update({
              'category': category,
              'name': name,
              'description': desc.isEmpty ? null : desc,
              'weight': weight.toInt(),
              'is_required': isRequired,
            })
            .eq('id', widget.existing!['id']);
      } else {
        await supabase.from('plv_prototype_traits').insert({
          'prototype_id': widget.prototypeId,
          'category': category,
          'name': name,
          'description': desc.isEmpty ? null : desc,
          'weight': weight.toInt(),
          'is_required': isRequired,
        });
      }

      if (!mounted) return;
      Navigator.pop(context, true);
    } on PostgrestException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.message}')));
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: bottom + 16,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              editing ? 'Editar rasgo' : 'Nuevo rasgo',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Nombre del rasgo',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descCtrl,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Descripción (opcional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
            ),
            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              value: category,
              decoration: const InputDecoration(
                labelText: 'Categoría',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'fisica', child: Text('Física')),
                DropdownMenuItem(
                  value: 'intelectual',
                  child: Text('Intelectual'),
                ),
                DropdownMenuItem(value: 'emocional', child: Text('Emocional')),
                DropdownMenuItem(value: 'social', child: Text('Social')),
                DropdownMenuItem(value: 'moral', child: Text('Moral')),
              ],
              onChanged: (v) => setState(() => category = v ?? 'fisica'),
            ),

            const SizedBox(height: 14),
            Row(
              children: [
                const Text('Peso'),
                const SizedBox(width: 12),
                Expanded(
                  child: Slider(
                    value: weight,
                    min: 1,
                    max: 10,
                    divisions: 9,
                    label: weight.toInt().toString(),
                    onChanged:
                        isRequired
                            ? null
                            : (v) {
                              setState(() {
                                weight = v;
                              });
                            },
                  ),
                ),
                SizedBox(width: 36, child: Text(weight.toInt().toString())),
              ],
            ),

            SwitchListTile(
              value: isRequired,
              onChanged: (v) {
                setState(() {
                  isRequired = v;
                  if (isRequired) {
                    weight = 10;
                  } else {
                    weight = 5;
                  }
                });
              },
              title: const Text('No negociable'),
              subtitle: const Text('Este rasgo es obligatorio.'),
            ),

            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: saving ? null : _save,
                icon:
                    saving
                        ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                        : const Icon(Icons.save),
                label: Text(saving ? 'Guardando...' : 'Guardar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pinkAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

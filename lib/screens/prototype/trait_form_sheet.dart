import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../utils/prototype_category_utils.dart';

class TraitFormSheet extends StatefulWidget {
  final String prototypeId;
  final String fixedCategory;
  final Map<String, dynamic>? existing;

  const TraitFormSheet({
    super.key,
    required this.prototypeId,
    required this.fixedCategory,
    this.existing,
  });

  @override
  State<TraitFormSheet> createState() => _TraitFormSheetState();
}

class _TraitFormSheetState extends State<TraitFormSheet> {
  final supabase = Supabase.instance.client;

  final nameCtrl = TextEditingController();
  final descCtrl = TextEditingController();

  double weight = 5;
  bool isRequired = false;
  bool saving = false;

  bool get editing => widget.existing != null && widget.existing!['id'] != null;

  @override
  void initState() {
    super.initState();

    if (editing) {
      final e = widget.existing!;
      nameCtrl.text = (e['name'] ?? '').toString();
      descCtrl.text = (e['description'] ?? '').toString();
      weight = ((e['weight'] ?? 5) as num).toDouble();
      isRequired = (e['is_required'] as bool?) ?? false;
    }
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    descCtrl.dispose();
    super.dispose();
  }

  Future<int> _nextDisplayOrder() async {
    final category = widget.fixedCategory.trim().toLowerCase();

    final data = await supabase
        .from('plv_prototype_traits')
        .select('display_order')
        .eq('prototype_id', widget.prototypeId)
        .eq('category', category)
        .order('display_order', ascending: false)
        .limit(1);

    if (data.isEmpty) return 1;
    final last = ((data.first['display_order'] ?? 0) as num).toInt();
    return last + 1;
  }

  Future<void> _save() async {
    final name = nameCtrl.text.trim();
    final desc = descCtrl.text.trim();
    final category = widget.fixedCategory.trim().toLowerCase();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Escribe el nombre de la característica')),
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
        final nextOrder = await _nextDisplayOrder();

        await supabase.from('plv_prototype_traits').insert({
          'prototype_id': widget.prototypeId,
          'category': category,
          'name': name,
          'description': desc.isEmpty ? null : desc,
          'weight': weight.toInt(),
          'is_required': isRequired,
          'display_order': nextOrder,
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
    final media = MediaQuery.of(context);
    final keyboard = media.viewInsets.bottom;
    final safeBottom = media.viewPadding.bottom;
    final categoryColor = PrototypeCategoryUtils.color(widget.fixedCategory);
    final categoryLabel = PrototypeCategoryUtils.label(widget.fixedCategory);

    return AnimatedPadding(
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: keyboard),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(16, 16, 16, safeBottom + 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                  editing ? 'Editar característica' : 'Nueva característica',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: categoryColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Categoría: $categoryLabel',
                    style: TextStyle(
                      color: categoryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nombre',
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
                                : (v) => setState(() => weight = v),
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
                      }
                    });
                  },
                  title: const Text('No negociable'),
                  subtitle: const Text('Esta característica es obligatoria'),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 52,
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
        ),
      ),
    );
  }
}

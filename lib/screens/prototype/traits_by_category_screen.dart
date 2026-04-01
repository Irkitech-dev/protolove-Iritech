import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../utils/prototype_category_utils.dart';
import 'trait_form_sheet.dart';

class TraitsByCategoryScreen extends StatefulWidget {
  final String prototypeId;
  final String category;

  const TraitsByCategoryScreen({
    super.key,
    required this.prototypeId,
    required this.category,
  });

  @override
  State<TraitsByCategoryScreen> createState() => _TraitsByCategoryScreenState();
}

class _TraitsByCategoryScreenState extends State<TraitsByCategoryScreen> {
  final supabase = Supabase.instance.client;

  bool loading = true;
  bool _hasChanges = false;
  List<Map<String, dynamic>> traits = [];

  @override
  void initState() {
    super.initState();
    _loadTraits();
  }

  Future<void> _loadTraits() async {
    setState(() => loading = true);

    try {
      final data = await supabase
          .from('plv_prototype_traits')
          .select(
            'id, prototype_id, category, name, description, weight, is_required, created_at',
          )
          .eq('prototype_id', widget.prototypeId)
          .eq('category', widget.category.trim().toLowerCase())
          .order('is_required', ascending: false)
          .order('weight', ascending: false)
          .order('created_at', ascending: true);

      if (!mounted) return;

      setState(() {
        traits = List<Map<String, dynamic>>.from(data);
        loading = false;
      });
    } on PostgrestException catch (e) {
      if (!mounted) return;
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error cargando características: ${e.message}')),
      );
    }
  }

  Future<void> _deleteTrait(String traitId) async {
    try {
      await supabase.from('plv_prototype_traits').delete().eq('id', traitId);

      _hasChanges = true;
      await _loadTraits();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Característica eliminada ✅')),
      );
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
      builder: (_) {
        return SafeArea(
          top: false,
          child: FractionallySizedBox(
            heightFactor: 0.92,
            child: TraitFormSheet(
              prototypeId: widget.prototypeId,
              fixedCategory: widget.category,
              existing: existing,
            ),
          ),
        );
      },
    );

    if (saved == true) {
      _hasChanges = true;
      await _loadTraits();
    }
  }

  Widget _traitCard(Map<String, dynamic> t) {
    final isRequired = (t['is_required'] as bool?) ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.pinkAccent.withOpacity(0.15),
                child: Icon(
                  isRequired ? Icons.lock : Icons.star_border,
                  color: Colors.pinkAccent,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  t['name'] ?? '',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Importancia: ${t['weight']}/10${isRequired ? " • No negociable" : ""}',
            style: TextStyle(color: Colors.grey[700]),
          ),
          if ((t['description'] ?? '').toString().trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(t['description'], style: TextStyle(color: Colors.grey[700])),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _openTraitForm(existing: t),
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Editar'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final confirm =
                        await showDialog<bool>(
                          context: context,
                          builder:
                              (_) => AlertDialog(
                                title: const Text('Eliminar característica'),
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

                    if (confirm) {
                      await _deleteTrait(t['id'] as String);
                    }
                  },
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  label: const Text(
                    'Eliminar',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    final label = PrototypeCategoryUtils.label(widget.category);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 12),
            Text(
              'No hay características en $label',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Toca el botón + para agregar una nueva.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = PrototypeCategoryUtils.label(widget.category);
    final color = PrototypeCategoryUtils.color(widget.category);

    return PopScope<Map<String, dynamic>>(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(title),
          backgroundColor: Colors.pinkAccent,
          actions: [
            IconButton(onPressed: _loadTraits, icon: const Icon(Icons.refresh)),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: Colors.pinkAccent,
          onPressed: () => _openTraitForm(),
          icon: const Icon(Icons.add),
          label: const Text('Agregar'),
        ),
        body:
            loading
                ? const Center(child: CircularProgressIndicator())
                : WillPopScope(
                  onWillPop: () async {
                    Navigator.pop(context, {
                      'changed': _hasChanges,
                      'category': widget.category.trim().toLowerCase(),
                      'count': traits.length,
                    });
                    return false;
                  },
                  child:
                      traits.isEmpty
                          ? _emptyState()
                          : Column(
                            children: [
                              Container(
                                width: double.infinity,
                                margin: const EdgeInsets.fromLTRB(
                                  16,
                                  16,
                                  16,
                                  8,
                                ),
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: color.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  'Categoría: $title • ${traits.length} características',
                                  style: TextStyle(
                                    color: color,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: ListView.builder(
                                  padding: const EdgeInsets.fromLTRB(
                                    16,
                                    0,
                                    16,
                                    16,
                                  ),
                                  itemCount: traits.length,
                                  itemBuilder: (_, i) => _traitCard(traits[i]),
                                ),
                              ),
                            ],
                          ),
                ),
      ),
    );
  }
}

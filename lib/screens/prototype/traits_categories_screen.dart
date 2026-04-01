import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../utils/prototype_category_utils.dart';
import 'traits_by_category_screen.dart';

class TraitsCategoriesScreen extends StatefulWidget {
  final String prototypeId;

  const TraitsCategoriesScreen({super.key, required this.prototypeId});

  @override
  State<TraitsCategoriesScreen> createState() => _TraitsCategoriesScreenState();
}

class _TraitsCategoriesScreenState extends State<TraitsCategoriesScreen> {
  final supabase = Supabase.instance.client;

  bool loading = true;
  Map<String, int> counts = {
    for (final c in PrototypeCategoryUtils.categories) c: 0,
  };

  @override
  void initState() {
    super.initState();
    _loadCounts();
  }

  Future<void> _loadCounts() async {
    setState(() => loading = true);

    try {
      final data = await supabase
          .from('plv_prototype_traits')
          .select('category')
          .eq('prototype_id', widget.prototypeId);

      final temp = {for (final c in PrototypeCategoryUtils.categories) c: 0};

      for (final row in data) {
        final category =
            (row['category'] ?? '').toString().trim().toLowerCase();

        if (temp.containsKey(category)) {
          temp[category] = temp[category]! + 1;
        }
      }

      if (!mounted) return;

      setState(() {
        counts = temp;
        loading = false;
      });
    } on PostgrestException catch (e) {
      if (!mounted) return;
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error cargando categorías: ${e.message}')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => loading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error inesperado: $e')));
    }
  }

  Widget _categoryCard(String category) {
    final color = PrototypeCategoryUtils.color(category);
    final label = PrototypeCategoryUtils.label(category);
    final icon = PrototypeCategoryUtils.icon(category);
    final count = counts[category] ?? 0;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () async {
        final result = await Navigator.push<Map<String, dynamic>>(
          context,
          MaterialPageRoute(
            builder:
                (_) => TraitsByCategoryScreen(
                  prototypeId: widget.prototypeId,
                  category: category,
                ),
          ),
        );

        if (result != null && result['changed'] == true) {
          final returnedCategory =
              (result['category'] ?? '').toString().trim().toLowerCase();
          final returnedCount = ((result['count'] ?? 0) as num).toInt();

          if (!mounted) return;

          setState(() {
            counts[returnedCategory] = returnedCount;
          });
        } else {
          await _loadCounts();
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withOpacity(0.35)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 36, color: color),
              const SizedBox(height: 10),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '$count característica${count == 1 ? '' : 's'}',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: color.withOpacity(0.90)),
              ),
              const SizedBox(height: 6),
              Text(
                'Tocar para ver',
                style: TextStyle(fontSize: 12, color: color.withOpacity(0.75)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categories = PrototypeCategoryUtils.categories;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Características del Prototipo'),
        backgroundColor: Colors.pinkAccent,
        actions: [
          IconButton(onPressed: _loadCounts, icon: const Icon(Icons.refresh)),
        ],
      ),
      body:
          loading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16),
                child: GridView.builder(
                  itemCount: categories.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 1.15,
                  ),
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    return _categoryCard(category);
                  },
                ),
              ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'create_trait_screen.dart';

class TraitsListScreen extends StatefulWidget {
  const TraitsListScreen({super.key});

  @override
  State<TraitsListScreen> createState() => _TraitsListScreenState();
}

class _TraitsListScreenState extends State<TraitsListScreen> {
  final supabase = Supabase.instance.client;

  bool isLoading = true;
  List traits = [];
  String? prototypeId;

  @override
  void initState() {
    super.initState();
    _loadTraits();
  }

  Future<void> _loadTraits() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    // Obtener prototipo
    final prototype =
        await supabase
            .from('plv_prototypes')
            .select()
            .eq('user_id', user.id)
            .maybeSingle();

    if (prototype == null) {
      setState(() => isLoading = false);
      return;
    }

    prototypeId = prototype['id'];

    final data = await supabase
        .from('plv_prototype_traits')
        .select()
        .eq('prototype_id', prototypeId!)
        .order('created_at', ascending: false);

    setState(() {
      traits = data;
      isLoading = false;
    });
  }

  Future<void> _deleteTrait(String id) async {
    await supabase.from('plv_prototype_traits').delete().eq('id', id);
    _loadTraits();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Características'),
        backgroundColor: const Color.fromARGB(255, 255, 107, 156),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.pinkAccent,
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateTraitScreen()),
          );
          _loadTraits();
        },
        child: const Icon(Icons.add),
      ),
      body:
          traits.isEmpty
              ? const Center(
                child: Text(
                  'Aún no has agregado características 💕',
                  style: TextStyle(fontSize: 16),
                ),
              )
              : ListView.builder(
                itemCount: traits.length,
                itemBuilder: (context, index) {
                  final trait = traits[index];

                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: ListTile(
                      title: Text(trait['name']),
                      subtitle: Text(
                        "Categoría: ${trait['category']} | Peso: ${trait['weight']}",
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteTrait(trait['id']),
                      ),
                    ),
                  );
                },
              ),
    );
  }
}

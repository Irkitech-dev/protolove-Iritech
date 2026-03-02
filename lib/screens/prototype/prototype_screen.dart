import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'traits_list_screen.dart';

class PrototypeScreen extends StatefulWidget {
  const PrototypeScreen({super.key});

  @override
  State<PrototypeScreen> createState() => _PrototypeScreenState();
}

class _PrototypeScreenState extends State<PrototypeScreen> {
  final supabase = Supabase.instance.client;

  bool loading = true;
  String? prototypeId;
  int traitsCount = 0;

  @override
  void initState() {
    super.initState();
    _loadPrototype();
  }

  Future<void> _loadPrototype() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final proto =
        await supabase
            .from('plv_prototypes')
            .select('id')
            .eq('user_id', user.id)
            .maybeSingle();

    if (proto == null) {
      final insert =
          await supabase
              .from('plv_prototypes')
              .insert({'user_id': user.id})
              .select('id')
              .single();

      prototypeId = insert['id'];
    } else {
      prototypeId = proto['id'];
    }

    final traits = await supabase
        .from('plv_prototype_traits')
        .select('id')
        .eq('prototype_id', prototypeId!)
        .count(CountOption.exact);

    traitsCount = traits.count ?? 0;

    if (mounted) setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final hasTraits = traitsCount > 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Prototipo 💖'),
        backgroundColor: Colors.pinkAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // CARD ESTADO
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors:
                      hasTraits
                          ? [Colors.green, Colors.teal]
                          : [Colors.orange, Colors.deepOrange],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    hasTraits ? Icons.check_circle : Icons.warning,
                    color: Colors.white,
                    size: 50,
                  ),
                  const SizedBox(height: 15),
                  Text(
                    hasTraits
                        ? 'Tu prototipo está listo'
                        : 'Tu prototipo está vacío',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    hasTraits
                        ? 'Tienes $traitsCount rasgos configurados.'
                        : 'Agrega características para comenzar.',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // BOTÓN PRINCIPAL
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.favorite),
                label: Text(
                  hasTraits
                      ? 'Editar características'
                      : 'Agregar características',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pinkAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => TraitsListScreen(prototypeId: prototypeId!),
                    ),
                  ).then((_) => _loadPrototype());
                },
              ),
            ),

            const SizedBox(height: 20),

            if (hasTraits)
              Text(
                'Mientras más específicos sean tus rasgos, mejor será la compatibilidad.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),
          ],
        ),
      ),
    );
  }
}

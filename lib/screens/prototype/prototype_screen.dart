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
  bool isLoading = true;
  String? prototypeId;

  @override
  void initState() {
    super.initState();
    _loadPrototype();
  }

  Future<void> _loadPrototype() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final response =
        await supabase
            .from('plv_prototypes')
            .select()
            .eq('user_id', user.id)
            .maybeSingle();

    if (response == null) {
      final insert =
          await supabase
              .from('plv_prototypes')
              .insert({'user_id': user.id})
              .select()
              .single();

      prototypeId = insert['id'];
    } else {
      prototypeId = response['id'];
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Mi Prototipo')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TraitsListScreen()),
            );
          },
          child: const Text('Gestionar Características'),
        ),
      ),
    );
  }
}

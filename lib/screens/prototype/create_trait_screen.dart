import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CreateTraitScreen extends StatefulWidget {
  const CreateTraitScreen({super.key});

  @override
  State<CreateTraitScreen> createState() => _CreateTraitScreenState();
}

class _CreateTraitScreenState extends State<CreateTraitScreen> {
  final supabase = Supabase.instance.client;

  final nameController = TextEditingController();
  int weight = 5;
  bool isRequired = false;
  String category = 'emocional';

  Future<void> _saveTrait() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final prototype =
        await supabase
            .from('plv_prototypes')
            .select()
            .eq('user_id', user.id)
            .single();

    await supabase.from('plv_prototype_traits').insert({
      'prototype_id': prototype['id'],
      'category': category,
      'name': nameController.text.trim(),
      'weight': weight,
      'is_required': isRequired,
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nueva Característica"),
        backgroundColor: const Color.fromARGB(255, 255, 107, 156),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Nombre",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            DropdownButtonFormField(
              value: category,
              items: const [
                DropdownMenuItem(value: 'fisica', child: Text('Física')),
                DropdownMenuItem(value: 'emocional', child: Text('Emocional')),
                DropdownMenuItem(
                  value: 'intelectual',
                  child: Text('Intelectual'),
                ),
                DropdownMenuItem(value: 'social', child: Text('Social')),
                DropdownMenuItem(value: 'moral', child: Text('Moral')),
              ],
              onChanged: (value) {
                setState(() => category = value.toString());
              },
              decoration: const InputDecoration(
                labelText: "Categoría",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            const Text("Importancia (Peso)"),
            Slider(
              value: weight.toDouble(),
              min: 1,
              max: 10,
              divisions: 9,
              label: weight.toString(),
              onChanged: (value) {
                setState(() => weight = value.toInt());
              },
            ),

            SwitchListTile(
              title: const Text("No negociable"),
              value: isRequired,
              onChanged: (value) {
                setState(() => isRequired = value);
              },
            ),

            const SizedBox(height: 20),

            ElevatedButton(onPressed: _saveTrait, child: const Text("Guardar")),
          ],
        ),
      ),
    );
  }
}

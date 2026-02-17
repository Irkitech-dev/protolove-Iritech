import 'package:flutter/material.dart';

class CreatePrototypeScreen extends StatefulWidget {
  const CreatePrototypeScreen({super.key});

  @override
  State<CreatePrototypeScreen> createState() => _CreatePrototypeScreenState();
}

class _CreatePrototypeScreenState extends State<CreatePrototypeScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  bool isSaving = false;

  void _savePrototype() {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isSaving = true);

    // Simulación de guardado (luego aquí va Supabase)
    Future.delayed(const Duration(seconds: 1), () {
      setState(() => isSaving = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Prototipo creado exitosamente 🚀')),
      );

      Navigator.pop(context); // Regresa al dashboard
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Prototipo'),
        backgroundColor: Colors.pinkAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del prototipo',
                  prefixIcon: Icon(Icons.title),
                  border: OutlineInputBorder(),
                ),
                validator:
                    (value) => value!.isEmpty ? 'Ingrese un nombre' : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: descriptionController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  prefixIcon: Icon(Icons.description),
                  border: OutlineInputBorder(),
                ),
                validator:
                    (value) =>
                        value!.isEmpty ? 'Ingrese una descripción' : null,
              ),
              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  icon:
                      isSaving
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                          : const Icon(Icons.save),
                  label: Text(isSaving ? 'Guardando...' : 'Guardar prototipo'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pinkAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: isSaving ? null : _savePrototype,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

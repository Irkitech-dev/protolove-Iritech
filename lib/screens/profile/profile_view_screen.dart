import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'profile_edit_screen.dart';

class ProfileViewScreen extends StatefulWidget {
  const ProfileViewScreen({super.key});

  @override
  State<ProfileViewScreen> createState() => _ProfileViewScreenState();
}

class _ProfileViewScreenState extends State<ProfileViewScreen> {
  String name = 'Usuario';
  String email = '';
  String? photoUrl;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) return;

    setState(() {
      email = user.email ?? '';
      name = user.userMetadata?['name'] ?? 'Usuario';
      photoUrl = user.userMetadata?['photo_url'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 255, 107, 156),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CircleAvatar(
              radius: 55,
              backgroundColor: Colors.pink.shade100,
              backgroundImage:
                  photoUrl != null ? NetworkImage(photoUrl!) : null,
              child:
                  photoUrl == null
                      ? const Icon(Icons.person, size: 60, color: Colors.white)
                      : null,
            ),
            const SizedBox(height: 20),

            Text(
              name,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),

            Text(
              email,
              style: const TextStyle(fontSize: 15, color: Colors.grey),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.edit),
                label: const Text('Editar perfil'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pinkAccent,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ProfileEditScreen(),
                    ),
                  ).then((_) => _loadProfile()); // refresca al volver
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

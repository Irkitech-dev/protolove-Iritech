import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../auth/login_screen.dart';
import 'package:protolove_iritech/utils/app_messages.dart';
import '../profile/user_profile_screen.dart';
import '../prototype/prototype_screen.dart';
import '../prototype/traits_list_screen.dart';
import '../candidates/candidates_list_screen.dart';

class HomeScreen extends StatefulWidget {
  static const String routeName = 'home';
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final supabase = Supabase.instance.client;

  String? userEmail;
  String userName = 'Usuario';
  String? userPhotoUrl;

  bool loading = true;
  bool prototypeReady = false;
  String? prototypeId;

  int traitsCount = 0;
  int candidatesCount = 0;

  Map<String, dynamic>? topCandidate; // {name, alias, score}

  @override
  void initState() {
    super.initState();
    _initHome();
  }

  Future<void> _initHome() async {
    setState(() => loading = true);

    final user = supabase.auth.currentUser;
    if (user == null) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => LoginScreen()),
        );
      }
      return;
    }

    userEmail = user.email;

    try {
      await _loadUserData(user.id);
      await _loadPrototypeAndCounts(user.id);
      await _loadTopCandidate(user.id);
    } on PostgrestException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.message}')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error inesperado: $e')));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _loadUserData(String userId) async {
    final response =
        await supabase
            .from('plv_users')
            .select('alias, avatar_url')
            .eq('id', userId)
            .maybeSingle();

    if (response != null) {
      setState(() {
        userName = response['alias'] ?? 'Usuario';
        userPhotoUrl = response['avatar_url'];
      });
    } else {
      setState(() => userName = 'Completa tu perfil');
    }
  }

  Future<void> _loadPrototypeAndCounts(String userId) async {
    // 1) prototipo
    final proto =
        await supabase
            .from('plv_prototypes')
            .select('id')
            .eq('user_id', userId)
            .maybeSingle();

    if (proto == null) {
      setState(() {
        prototypeReady = false;
        prototypeId = null;
        traitsCount = 0;
      });
    } else {
      prototypeId = proto['id'] as String;

      // 2) traits count
      final traits = await supabase
          .from('plv_prototype_traits')
          .select('id')
          .eq('prototype_id', prototypeId!)
          .count(CountOption.exact);

      // supabase_flutter devuelve: {data: [...], count: N}
      final count = traits.count ?? 0;

      setState(() {
        traitsCount = count;
        prototypeReady = count > 0; // listo si tiene rasgos
      });
    }

    // 3) candidatos count
    final cand = await supabase
        .from('plv_candidates')
        .select('id')
        .eq('user_id', userId)
        .count(CountOption.exact);

    setState(() {
      candidatesCount = cand.count ?? 0;
    });
  }

  Future<void> _loadTopCandidate(String userId) async {
    // Trae el candidato con mayor compatibility_score
    // Joins en PostgREST: seleccionamos candidate_id, score, y de plv_candidates traemos name/alias
    final data = await supabase
        .from('plv_candidate_results')
        .select(
          'compatibility_score, candidate_id, plv_candidates(name, alias)',
        )
        .order('compatibility_score', ascending: false)
        .limit(1);

    if (data.isEmpty) {
      setState(() => topCandidate = null);
      return;
    }

    final row = data.first as Map<String, dynamic>;
    final candidate = row['plv_candidates'] as Map<String, dynamic>?;

    // Seguridad: solo mostrar si el candidato pertenece al user (por si acaso)
    if (candidate == null) {
      setState(() => topCandidate = null);
      return;
    }

    setState(() {
      topCandidate = {
        'name': candidate['name'],
        'alias': candidate['alias'],
        'score': row['compatibility_score'],
      };
    });
  }

  /// ✅ Bloquea Candidatos si no hay prototipo + rasgos
  Future<bool> _ensurePrototypeReady() async {
    if (prototypeReady) return true;

    if (!mounted) return false;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Primero crea tu prototipo y agrega rasgos ✍️'),
      ),
    );

    // si no hay prototipo -> va a PrototypeScreen que lo crea
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PrototypeScreen()),
    );

    return false;
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Protolove'),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 255, 107, 156),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _initHome),
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed:
                () => AppMessages.success(
                  context,
                  'Notificaciones próximamente.',
                ),
          ),
        ],
      ),
      drawerScrimColor: Colors.black.withOpacity(0.6),
      drawer: _buildDrawer(context),
      body: RefreshIndicator(
        onRefresh: _initHome,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hola, $userName 👋',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                prototypeReady
                    ? 'Tu prototipo está listo. Ahora califica candidatos 💕'
                    : 'Crea tu prototipo y agrega rasgos para comenzar 💕',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),

              const SizedBox(height: 18),

              // Banner si no está listo
              if (!prototypeReady) _prototypeWarningCard(),

              if (!prototypeReady) const SizedBox(height: 18),

              // Card Prototipo
              _prototypeCard(context),

              const SizedBox(height: 20),

              // Top Candidate
              _topCandidateCard(),

              const SizedBox(height: 20),

              // Resumen dinámico
              const Text(
                'Resumen',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _statCard('$traitsCount', 'Rasgos')),
                  const SizedBox(width: 15),
                  Expanded(child: _statCard('$candidatesCount', 'Candidatos')),
                ],
              ),

              const SizedBox(height: 22),

              // Acciones rápidas
              const Text(
                'Acciones rápidas',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _actionCard(
                      icon: Icons.person,
                      title: 'Mi Perfil',
                      onTap:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const UserProfileScreen(),
                            ),
                          ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: _actionCard(
                      icon: Icons.people,
                      title: 'Candidatos',
                      onTap: () async {
                        final ok = await _ensurePrototypeReady();
                        if (!ok) return;

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CandidatesListScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _prototypeWarningCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.orange.withOpacity(0.4)),
      ),
      child: Row(
        children: const [
          Icon(Icons.warning_amber_rounded, color: Colors.orange),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Aún no tienes rasgos en tu prototipo. Agrégalos para poder crear y calificar candidatos.',
              style: TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _prototypeCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.pinkAccent, Colors.orangeAccent],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.pinkAccent.withOpacity(0.25),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Mi Prototipo 💖',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            prototypeReady
                ? 'Rasgos definidos: $traitsCount'
                : 'Aún no has definido rasgos.',
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 15),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.pinkAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PrototypeScreen()),
                ),
            child: const Text('Gestionar prototipo'),
          ),
        ],
      ),
    );
  }

  Widget _topCandidateCard() {
    final tc = topCandidate;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child:
          tc == null
              ? Row(
                children: const [
                  Icon(Icons.emoji_events_outlined),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Aún no hay resultados. Califica candidatos y guarda su puntuación global.',
                      style: TextStyle(color: Colors.black87),
                    ),
                  ),
                ],
              )
              : Row(
                children: [
                  const Icon(Icons.emoji_events, color: Colors.amber),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Mejor candidato/a',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${tc['name']}${(tc['alias'] == null || (tc['alias'] as String).isEmpty) ? "" : " (${tc['alias']})"}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${(tc['score'] as num).toStringAsFixed(2)} / 10',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
    );
  }

  // Drawer
  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          _buildDrawerHeader(),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _drawerItem(
                  icon: Icons.home,
                  text: 'Inicio',
                  onTap: () => Navigator.pop(context),
                ),
                _drawerItem(
                  icon: Icons.person,
                  text: 'Mi perfil',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const UserProfileScreen(),
                      ),
                    );
                  },
                ),
                _drawerItem(
                  icon: Icons.favorite,
                  text: 'Mi Prototipo',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PrototypeScreen(),
                      ),
                    );
                  },
                ),
                _drawerItem(
                  icon: Icons.people,
                  text: 'Mis Candidatos',
                  onTap: () async {
                    Navigator.pop(context);
                    final ok = await _ensurePrototypeReady();
                    if (!ok) return;

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CandidatesListScreen(),
                      ),
                    );
                  },
                ),
                const Divider(height: 30),
                _drawerItem(
                  icon: Icons.logout,
                  text: 'Cerrar sesión',
                  color: Colors.red,
                  onTap: () async {
                    Navigator.pop(context);
                    await supabase.auth.signOut();
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => LoginScreen()),
                      (_) => false,
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 50, bottom: 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.pinkAccent, Colors.orangeAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white,
            backgroundImage:
                userPhotoUrl != null ? NetworkImage(userPhotoUrl!) : null,
            child:
                userPhotoUrl == null
                    ? const Icon(
                      Icons.person,
                      size: 50,
                      color: Colors.pinkAccent,
                    )
                    : null,
          ),
          const SizedBox(height: 12),
          Text(
            userName,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            userEmail ?? 'Sin correo',
            style: const TextStyle(fontSize: 14, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _drawerItem({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    Color color = Colors.black87,
  }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  }

  Widget _statCard(String number, String label) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            number,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.pinkAccent,
            ),
          ),
          const SizedBox(height: 5),
          Text(label, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _actionCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 30, color: Colors.pinkAccent),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

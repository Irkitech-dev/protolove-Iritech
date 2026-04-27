import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:protolove_iritech/service/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../utils/app_colors.dart';
import '../../utils/candidate_score_utils.dart';
import '../candidates/candidates_list_screen.dart';
import '../profile/user_profile_screen.dart';
import '../prototype/prototype_screen.dart';

class HomeScreen extends StatefulWidget {
  static const String routeName = '/home';

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final supabase = Supabase.instance.client;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool loading = true;

  String userName = 'Usuario';
  String userAlias = '';
  String userEmail = '';
  int traitsCount = 0;
  int candidatesCount = 0;

  String bestCandidateName = 'Sin datos';
  double bestCandidateScore = 0;

  @override
  void initState() {
    super.initState();
    _loadHome();
  }

  Future<void> _loadHome() async {
    setState(() => loading = true);

    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        if (!mounted) return;
        setState(() {
          userName = 'Usuario';
          userAlias = '';
          userEmail = '';
          traitsCount = 0;
          candidatesCount = 0;
          bestCandidateName = 'Sin datos';
          bestCandidateScore = 0;
          loading = false;
        });
        return;
      }

      userEmail = user.email ?? '';

      final profile =
          await supabase
              .from('plv_users')
              .select('name, alias')
              .eq('id', user.id)
              .maybeSingle();

      final dbName = (profile?['name'] ?? '').toString().trim();
      final dbAlias = (profile?['alias'] ?? '').toString().trim();

      userName = dbName.isNotEmpty ? dbName : 'Usuario';
      userAlias = dbAlias;

      final prototype =
          await supabase
              .from('plv_prototypes')
              .select('id')
              .eq('user_id', user.id)
              .maybeSingle();

      traitsCount = 0;

      if (prototype != null) {
        final prototypeId = prototype['id'] as String;

        final traitsRes = await supabase
            .from('plv_prototype_traits')
            .select('id')
            .eq('prototype_id', prototypeId)
            .count(CountOption.exact);

        traitsCount = traitsRes.count ?? 0;
      }

      final candidatesData = await supabase
          .from('plv_candidates')
          .select('id, name, alias, created_at')
          .eq('user_id', user.id);

      final candidates = List<Map<String, dynamic>>.from(candidatesData);
      candidatesCount = candidates.length;

      bestCandidateName = 'Sin datos';
      bestCandidateScore = 0;

      if (candidates.isNotEmpty) {
        double bestPercentage = -1;
        String bestName = 'Sin datos';
        double bestTotal = 0;

        for (final candidate in candidates) {
          final scores = await supabase
              .from('plv_candidate_scores')
              .select(
                'id,candidate_id,prototype_trait_id,category,trait_name,weight,is_required,score',
              )
              .eq('candidate_id', candidate['id']);

          final rows = List<Map<String, dynamic>>.from(scores);
          final percentage = CandidateScoreUtils.percentage(rows);
          final total = CandidateScoreUtils.totalScore(rows);

          if (percentage > bestPercentage) {
            bestPercentage = percentage;
            bestTotal = total;

            final name = (candidate['name'] ?? '').toString().trim();
            final alias = (candidate['alias'] ?? '').toString().trim();

            bestName = alias.isNotEmpty ? '$name ($alias)' : name;
          }
        }

        bestCandidateName = bestName;
        bestCandidateScore = bestTotal;
      }

      if (!mounted) return;
      setState(() => loading = false);
    } catch (_) {
      if (!mounted) return;
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo cargar el inicio')),
      );
    }
  }

  Future<void> _goPrototype() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PrototypeScreen()),
    );
    await _loadHome();
  }

  Future<void> _goCandidates() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CandidatesListScreen()),
    );
    await _loadHome();
  }

  Future<void> _goProfile() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const UserProfileScreen()),
    );
    await _loadHome();
  }

  Future<void> _logout() async {
    if (!mounted) return;
    await context.read<AuthService>().logout(context);
  }

  Widget _drawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color color = AppColors.textPrimary,
  }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        title,
        style: TextStyle(
          color: color,
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  }

  Widget _summaryCard(String value, String label) {
    return Expanded(
      child: Container(
        height: 145,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickAction({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Container(
          height: 175,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 42, color: AppColors.primary),
              const SizedBox(height: 18),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final helloName = userName.trim().isEmpty ? 'Usuario' : userName;
    final drawerName = helloName;
    final hasPrototype = traitsCount > 0;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      drawer: Drawer(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(
                top: 70,
                left: 20,
                right: 20,
                bottom: 24,
              ),
              decoration: BoxDecoration(gradient: AppColors.primaryGradient),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 46,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 52,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    drawerName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (userAlias.trim().isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      '@$userAlias',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 15,
                      ),
                    ),
                  ],
                  if (userEmail.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      userEmail,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
            _drawerItem(
              icon: Icons.home,
              title: 'Inicio',
              onTap: () => Navigator.pop(context),
            ),
            _drawerItem(
              icon: Icons.person,
              title: 'Mi perfil',
              onTap: () async {
                Navigator.pop(context);
                await _goProfile();
              },
            ),
            _drawerItem(
              icon: Icons.favorite,
              title: 'Mi Prototipo',
              onTap: () async {
                Navigator.pop(context);
                await _goPrototype();
              },
            ),
            _drawerItem(
              icon: Icons.groups,
              title: 'Mis Candidatos',
              onTap: () async {
                Navigator.pop(context);
                await _goCandidates();
              },
            ),
            const Divider(height: 28),
            _drawerItem(
              icon: Icons.logout,
              title: 'Cerrar sesión',
              color: AppColors.danger,
              onTap: _logout,
            ),
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: const Text('Protolove'),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadHome),
          IconButton(icon: const Icon(Icons.notifications), onPressed: () {}),
        ],
      ),
      body:
          loading
              ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
              : RefreshIndicator(
                color: AppColors.primary,
                onRefresh: _loadHome,
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    Text(
                      'Hola, $helloName 👋',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      hasPrototype
                          ? 'Tu prototipo está listo. Ahora califica candidatos 💕'
                          : 'Aún no has creado tu prototipo.',
                      style: const TextStyle(
                        fontSize: 17,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 22),
                    Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.16),
                            blurRadius: 18,
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
                              color: Colors.white,
                              fontSize: 21,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Rasgos definidos: $traitsCount',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: 230,
                            height: 54,
                            child: ElevatedButton(
                              onPressed: _goPrototype,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: AppColors.primary,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),
                              child: const Text(
                                'Gestionar prototipo',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.emoji_events,
                            color: Colors.amber,
                            size: 34,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Mejor candidato/a',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  bestCandidateName,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '${bestCandidateScore.toStringAsFixed(2)} / 10',
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    const Text(
                      'Resumen',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _summaryCard('$traitsCount', 'Rasgos'),
                        const SizedBox(width: 14),
                        _summaryCard('$candidatesCount', 'Candidatos'),
                      ],
                    ),
                    const SizedBox(height: 28),
                    const Text(
                      'Acciones rápidas',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _quickAction(
                          icon: Icons.person,
                          title: 'Mi Perfil',
                          onTap: _goProfile,
                        ),
                        const SizedBox(width: 14),
                        _quickAction(
                          icon: Icons.groups,
                          title: 'Candidatos',
                          onTap: _goCandidates,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
    );
  }
}

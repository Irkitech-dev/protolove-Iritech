import 'package:flutter/material.dart';
import 'package:protolove/widgets/widgets.dart';
import 'package:protolove/screens/home/home_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:protolove/utils/app_messages.dart';
import 'package:protolove/screens/auth/register_screen.dart';
import 'package:protolove/screens/auth/forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  static const String routeName = 'login';
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final supabase = Supabase.instance.client;

  bool isLoading = false;

  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      AppMessages.info(context, 'Por favor ingresa tu correo y contraseña ✍️');
      return;
    }
    setState(() => isLoading = true);

    try {
      final response = await supabase.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (response.user != null && mounted) {
        AppMessages.success(context, '¡Bienvenido a Protolove! 💕');

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } on AuthException catch (e) {
      print(e);
      if (e.message.contains('Invalid login credentials')) {
        AppMessages.error(
          context,
          'Correo o contraseña incorrectos 🔐\nInténtalo nuevamente.',
        );
      } else {
        AppMessages.error(
          context,
          'No pudimos iniciar sesión 😕\nInténtalo más tarde.',
        );
      }
    } catch (_) {
      AppMessages.error(
        context,
        'Ocurrió un problema inesperado ⚠️\nRevisa tu conexión.',
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: const Color(0xffFBE4E1),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              /// HEADER
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Bienvenido PROTOLOVE',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 8),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Que la pasen bien 💕',
                  style: TextStyle(color: Colors.black54),
                ),
              ),

              const SizedBox(height: 30),

              /// EMAIL
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  hintText: 'Correo electrónico',
                  prefixIcon: Icon(Icons.email_outlined),
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              /// PASSWORD
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  hintText: 'Contraseña',
                  prefixIcon: Icon(Icons.lock_outline),
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ForgotPasswordScreen(),
                      ),
                    );
                  },
                  child: const Text('¿Olvidaste tu contraseña?'),
                ),
              ),

              const SizedBox(height: 10),

              /// LOGIN BUTTON
              PrimaryButton(
                text: isLoading ? 'Cargando...' : 'Login',
                onPressed: isLoading ? null : _login,
              ),

              const SizedBox(height: 20),

              /// DIVIDER
              Row(
                children: const [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text('o continuar con'),
                  ),
                  Expanded(child: Divider()),
                ],
              ),

              const SizedBox(height: 20),

              /// SOCIAL BUTTONS
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [],
              ),

              const SizedBox(height: 30),

              /// REGISTER
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('¿No tienes una cuenta? '),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RegisterScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'Registrar',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.pinkAccent,
                      ),
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
}

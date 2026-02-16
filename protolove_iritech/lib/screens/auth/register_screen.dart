import 'package:flutter/material.dart';
import 'package:protolove/widgets/widgets.dart';
import 'package:protolove/utils/app_messages.dart';
import 'package:provider/provider.dart';

import '../../service/service.dart';

class RegisterScreen extends StatefulWidget {
  static const String routeName = 'register';
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();

    return Scaffold(
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
                  'Crear cuenta',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Empieza tu historia en Protolove 💕',
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
              const SizedBox(height: 16),

              /// CONFIRM PASSWORD
              TextField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  hintText: 'Confirmar contraseña',
                  prefixIcon: Icon(Icons.lock_reset_outlined),
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              /// REGISTER BUTTON
              PrimaryButton(
                text: authService.isLoading ? 'Creando cuenta...' : 'Registrar',
                onPressed:
                    authService.isLoading
                        ? null
                        : () async {
                          if (_emailController.text.isEmpty ||
                              _passwordController.text.isEmpty ||
                              _confirmPasswordController.text.isEmpty) {
                            AppMessages.info(
                              context,
                              'Completa todos los campos ✍️',
                            );
                            return;
                          }

                          if (_passwordController.text !=
                              _confirmPasswordController.text) {
                            AppMessages.error(
                              context,
                              'Las contraseñas no coinciden 🔐',
                            );
                            return;
                          }

                          if (_passwordController.text.length < 6) {
                            AppMessages.info(
                              context,
                              'La contraseña debe tener al menos 6 caracteres 🔒',
                            );
                            return;
                          }

                          await authService.register(
                            _emailController.text,
                            _passwordController.text,
                            context,
                          );
                        },
              ),

              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '¿Ya tienes una cuenta? ',
                    style: TextStyle(fontSize: 14),
                  ),

                  /// BACK TO LOGIN
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Iniciar sesión',
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

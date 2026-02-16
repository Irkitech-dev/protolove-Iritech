import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:protolove/utils/app_messages.dart';
import 'package:protolove/widgets/widgets.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final supabase = Supabase.instance.client;

  bool isLoading = false;

  Future<void> _recoverPassword() async {
    if (_emailController.text.isEmpty) {
      AppMessages.info(
        context,
        'Ingresa tu correo para ayudarte a recuperar tu contraseña 💌',
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      await supabase.auth.resetPasswordForEmail(_emailController.text.trim());

      AppMessages.success(
        context,
        'Te enviamos un correo 📩\n'
        'Revisa tu bandeja y sigue las instrucciones 💕',
      );

      Navigator.pop(context);
    } on AuthException catch (_) {
      AppMessages.error(
        context,
        'No pudimos enviar el correo 😕\n'
        'Verifica que el email sea correcto.',
      );
    } catch (_) {
      AppMessages.error(
        context,
        'Ocurrió un error inesperado ⚠️\n'
        'Inténtalo más tarde.',
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recuperar contraseña')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '¿Olvidaste tu contraseña? 💭',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'No te preocupes 💕\n'
              'Te enviaremos un enlace para crear una nueva.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

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

            const SizedBox(height: 24),

            PrimaryButton(
              text: isLoading ? 'Enviando...' : 'Enviar enlace',
              onPressed: isLoading ? null : _recoverPassword,
            ),
          ],
        ),
      ),
    );
  }
}

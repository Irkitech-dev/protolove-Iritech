import 'package:flutter/material.dart';
import 'package:protolove_iritech/screens/home/home_screen.dart';
import 'package:protolove_iritech/service/app_service.dart';
import 'package:protolove_iritech/service/service.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../utils/app_messages.dart';

class AuthService extends ChangeNotifier {
  final _supabase = Supabase.instance.client;

  //Variables
  bool _isLoading = false;
  bool _notHasBiometric = false;

  //Getter y setter
  bool get isLoading => _isLoading;
  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  bool get notHasBiometric => _notHasBiometric;
  set notHasBiometric(bool value) {
    _notHasBiometric = value;
    notifyListeners();
  }

  Future<void> login(
    String email,
    String password,
    BuildContext context,
  ) async {
    try {
      isLoading = true;
      final response = await _supabase.auth.signInWithPassword(
        email: email.trim(),
        password: password.trim(),
      );

      if (response.user != null) {
        AppMessages.success(context, '¡Bienvenido a Protolove! 💕');
        final appService = context.read<AppService>();
        appService.setLoginData(email, password);
        NavigationService().pushReplacementNamed(HomeScreen.routeName);
      }
    } on AuthException catch (e) {
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
    } catch (e) {
      AppMessages.error(
        context,
        'Ocurrió un problema inesperado ⚠️\nRevisa tu conexión.',
      );
    } finally {
      isLoading = false;
    }
  }

  Future<void> register(
    String email,
    String password,
    BuildContext context,
  ) async {
    isLoading = true;
    try {
      final response = await _supabase.auth.signUp(
        email: email.trim(),
        password: password.trim(),
      );

      if (response.user != null) {
        AppMessages.success(
          context,
          'Cuenta creada 🎉\nRevisa tu correo para confirmar 💌',
        );
        final appService = context.read<AppService>();

        appService.setDataUser(
          email,
          password,
        ); // Se guarda el email y password en Preferencias
        NavigationService().pushReplacementNamed(HomeScreen.routeName);
      }
    } on AuthException catch (e) {
      if (e.message.contains('already registered')) {
        AppMessages.error(context, 'Este correo ya está registrado 📧');
      } else {
        AppMessages.error(context, 'No pudimos crear la cuenta 😕');
      }
    } catch (_) {
      AppMessages.error(context, 'Error inesperado ⚠️\nInténtalo más tarde.');
    } finally {
      isLoading = false;
    }
  }

  Future<void> logout() async {
    await _supabase.auth.signOut();
  }
}

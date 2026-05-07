import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../screens/screen.dart';
import '../utils/app_messages.dart';
import 'app_service.dart';
import 'navigation_service.dart';
import 'terms_service.dart';

class AuthService extends ChangeNotifier {
  final _supabase = Supabase.instance.client;

  bool _isLoading = false;
  bool _notHasBiometric = false;

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
        await appService.setLoginData(email, password);

        final hasAcceptedTerms = await TermsService().hasAcceptedTerms();

        if (hasAcceptedTerms) {
          NavigationService().pushNamedAndRemoveUntil(
            HomeScreen.routeName,
            (route) => false,
          );
        } else {
          NavigationService().pushNamedAndRemoveUntil(
            TermsScreen.routeName,
            (route) => false,
          );
        }
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
    try {
      isLoading = true;

      final response = await _supabase.auth.signUp(
        email: email.trim(),
        password: password.trim(),
      );

      if (response.user != null) {
        AppMessages.success(
          context,
          'Cuenta creada 🎉\nAhora crea tu perfil 💌',
        );

        final appService = context.read<AppService>();
        await appService.setLoginData(email, password);

        NavigationService().pushNamedAndRemoveUntil(
          RegisterNameScreen.routeName,
          (route) => false,
        );
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

  Future<void> createUserProfile(String alias) async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw Exception('Usuario no autenticado');
    }

    final existingAlias =
        await _supabase
            .from('plv_users')
            .select('id')
            .eq('alias', alias)
            .maybeSingle();

    if (existingAlias != null && existingAlias['id'] != user.id) {
      throw Exception(
        'El nombre seleccionado ya está en uso. Por favor, elige otro.',
      );
    }

    await _supabase.from('plv_users').upsert({'id': user.id, 'alias': alias});
  }

  Future<void> logout(BuildContext context) async {
    final appService = context.read<AppService>();

    try {
      await _supabase.auth.signOut();
    } finally {
      await appService.clearSession();

      NavigationService().pushNamedAndRemoveUntil(
        SignInUpScreen.routeName,
        (route) => false,
      );
    }
  }
}

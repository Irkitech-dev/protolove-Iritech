import 'package:flutter/material.dart';

import '../utils/utils.dart';

class AppService extends ChangeNotifier {
  final PreferencesService _prefs;

  AppService(this._prefs);

  bool _isLogged = false;
  bool _hasSeenOnboarding = false;
  String _email = '';
  String _password = '';

  bool get isLogged => _isLogged;
  bool get hasSeenOnboarding => _hasSeenOnboarding;

  String get email => _email;
  String get password => _password;

  Future<void> init() async {
    _isLogged = await _prefs.getIsLogged();
    _hasSeenOnboarding = await _prefs.getHasSeenOnboarding();

    if (_isLogged) {
      getCredentialUser();
    }

    notifyListeners();
  }

  //Obtener credenciales guardadas
  void getCredentialUser() async {
    final credentials = await _prefs.getCredentialUser();
    _email = credentials['email']!;
    _password = credentials['password']!;
    notifyListeners();
  }

  //Setear datos de Usuario
  Future<void> setLoginData(String emailStr, String passwordStr) async {
    _isLogged = true;
    await _prefs.setIsLogged(true);
    setDataUser(emailStr, passwordStr);
    notifyListeners();
  }

  Future<void> setDataUser(String emailStr, String passwordStr) async {
    _email = emailStr;
    _password = passwordStr;
    await _prefs.setCredentialUser(email, password);
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    _hasSeenOnboarding = true;
    await _prefs.setHasSeenOnboarding(true);
    notifyListeners();
  }

  Future<void> clearSession() async {
    _isLogged = false;
    _email = '';
    _password = '';
    await _prefs.setIsLogged(false);
    await _prefs.clearCredentialUser();
    notifyListeners();
  }
}

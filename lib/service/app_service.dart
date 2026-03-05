import 'package:flutter/material.dart';

import '../utils/utils.dart';

class AppService extends ChangeNotifier {
  final PreferencesService _prefs;

  AppService(this._prefs);

  bool _isLogged = false;
  String _email = '';
  String _password = '';

  
  bool get isLogged => _isLogged;
  String get email => _email;
  String get password => _password;


  Future<void> init() async {
    _isLogged = await _prefs.getIsLogged();
    if (_isLogged) {
      _prefs.getCredentialUser().then((credentials) {
        _email = credentials['email'] ?? '';
        _password = credentials['password'] ?? '';
        notifyListeners();
      });
    }
    notifyListeners();
  }

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
}

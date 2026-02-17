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
    print('AppService: isLogged=$_isLogged');
    notifyListeners();
  }

  Future<void> login() async {
    _isLogged = true;
    await _prefs.setIsLogged(true);
    print('AppService: isLogged=$_isLogged');
    notifyListeners();
  }

  Future<void> setDataUser(String emailStr, String passwordStr) async {
    _email = emailStr;
    _password = passwordStr;
    await _prefs.setCredentialUser(email, password);
    notifyListeners();
  }
}

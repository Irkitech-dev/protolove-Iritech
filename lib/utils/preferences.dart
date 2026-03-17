import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const _isLoggedKey = 'is_logged';

  Future<bool> getIsLogged() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedKey) ?? false;
  }

  Future<void> setIsLogged(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedKey, value);
  }

  Future<Map<String, String>> getCredentialUser() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('email');
    final savedPassword = prefs.getString('password');
    return {'email': savedEmail!, 'password': savedPassword!};
  }

  Future<void> setCredentialUser(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', email);
    await prefs.setString('password', password);
  }
}

import 'package:flutter/material.dart';


import '../screens/screen.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> getRoutes() {
    return <String, WidgetBuilder>{
      SplashScreen.routeName: (BuildContext context) => const SplashScreen(),
      LoginScreen.routeName: (context) => const LoginScreen(),
      HomeScreen.routeName: (context) => const HomeScreen(),
      SignInUpScreen.routeName: (context) => SignInUpScreen(),
      RegisterScreen.routeName: (context) => const RegisterScreen(),
      RegisterNameScreen.routeName: (context) => const RegisterNameScreen(),
    };
  }
}

import 'package:flutter/material.dart';

class NavigationService {
  static final NavigationService _instance = NavigationService._internal();
  factory NavigationService() => _instance;
  NavigationService._internal();

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  Future<T?> pushNamed<T extends Object?>(String routeName,
      {Object? arguments}) async {
    return navigatorKey.currentState
        ?.pushNamed<T>(routeName, arguments: arguments);
  }

  Future<T?> push<T extends Object?>(Route<T> route) async {
    return navigatorKey.currentState?.push<T>(route);
  }

  void pop<T extends Object?>([T? result]) {
    navigatorKey.currentState?.pop<T>(result);
  }

  Future<T?> pushReplacementNamed<T extends Object?, TO extends Object?>(
      String routeName,
      {TO? result,
      Object? arguments}) async {
    return navigatorKey.currentState?.pushReplacementNamed<T, TO>(routeName,
        result: result, arguments: arguments);
  }

  Future<T?> pushNamedAndRemoveUntil<T extends Object?>(
    String newRouteName,
    RoutePredicate predicate, {
    Object? arguments,
  }) async {
    return navigatorKey.currentState?.pushNamedAndRemoveUntil<T>(
        newRouteName, predicate,
        arguments: arguments);
  }

  Future<T?> popAndPushNamed<T extends Object?, TO extends Object?>(
      String routeName,
      {TO? result,
      Object? arguments}) async {
    return navigatorKey.currentState?.popAndPushNamed<T, TO>(routeName,
        result: result, arguments: arguments);
  }

  void popUntil(RoutePredicate predicate) {
    navigatorKey.currentState?.popUntil(predicate);
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:protolove_iritech/screens/screen.dart';
import 'package:protolove_iritech/service/app_service.dart';
import 'package:protolove_iritech/service/service.dart';
import 'package:protolove_iritech/utils/preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Onboarding flows through the three intro screens', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => AppService(PreferencesService()),
          ),
        ],
        child: MaterialApp(
          navigatorKey: NavigationService().navigatorKey,
          routes: {
            OnboardingScreen.routeName:
                (context) => const OnboardingScreen(),
            SignInUpScreen.routeName:
                (context) => const Scaffold(
                  body: Center(child: Text('Destino final')),
                ),
          },
          initialRoute: OnboardingScreen.routeName,
        ),
      ),
    );

    expect(find.text('Define tu prototipo\nde pareja'), findsOneWidget);
    expect(find.text('Continuar'), findsOneWidget);

    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();

    expect(find.text('Muchas personas\neligen a ciegas'), findsOneWidget);

    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();

    expect(find.text('Elige con el corazón\ny con la cabeza'), findsOneWidget);
    expect(find.text('Empezar'), findsOneWidget);

    await tester.tap(find.text('Empezar'));
    await tester.pumpAndSettle();

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('has_seen_onboarding'), isTrue);
    expect(find.text('Destino final'), findsOneWidget);
  });

  testWidgets('Onboarding can be skipped with omit button', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => AppService(PreferencesService()),
          ),
        ],
        child: MaterialApp(
          navigatorKey: NavigationService().navigatorKey,
          routes: {
            OnboardingScreen.routeName:
                (context) => const OnboardingScreen(),
            SignInUpScreen.routeName:
                (context) => const Scaffold(
                  body: Center(child: Text('Destino final')),
                ),
          },
          initialRoute: OnboardingScreen.routeName,
        ),
      ),
    );

    expect(find.text('Omitir'), findsOneWidget);

    await tester.tap(find.text('Omitir'));
    await tester.pumpAndSettle();

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('has_seen_onboarding'), isTrue);
    expect(find.text('Destino final'), findsOneWidget);
  });
}

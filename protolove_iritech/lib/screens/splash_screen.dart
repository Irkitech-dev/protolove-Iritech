import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/services.dart';
import 'package:protolove/service/service.dart';
import 'package:protolove/utils/colors.dart';

import '../widgets/widgets.dart';
import 'screen.dart';

class SplashScreen extends StatefulWidget {
  static const String routeName = 'init';
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  final colorizeColors = [AppColors().primaryColor, Colors.pink];

  static const colorizeTextStyle = TextStyle(fontSize: 50);

  bool _isPrecaching = false;

  final List<String> imagesToPrecache = [
    'assets/persona.jpg',
    'assets/pareja_2.jpg',
    'assets/pareja_7.jpg',
    'assets/pareja_6.jpeg',
    'assets/pareja_9.jpg',
    'assets/pareja_14.jpg',
    'assets/pareja_15.jpg',
    'assets/pareja_13.jpg',
    'assets/pareja_12.jpg',
    'assets/pareja_4.jpg',
    'assets/pareja_10.jpg',
    'assets/pareja_11.jpg',
  ];

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 3500), () {
      NavigationService().pushReplacementNamed(SignInUpScreen.routeName);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isPrecaching) {
      _isPrecaching = true;
      _precacheEverything();
    }
  }

  Future<void> _precacheEverything() async {
    for (String img in imagesToPrecache) {
      precacheImage(ResizeImage(AssetImage(img), width: 400), context);
    }
  }

  @override
  void dispose() {
    super.dispose();
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Align(
            alignment: const Alignment(0, -0.3),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/heart.png',
                  width: 240,
                  height: 240,
                  fit: BoxFit.contain,
                ),

                AnimatedTextKit(
                  animatedTexts: [
                    ColorizeAnimatedText(
                      'Protolove',
                      textStyle: colorizeTextStyle,
                      colors: colorizeColors,
                      speed: const Duration(milliseconds: 300),
                    ),
                  ],
                  isRepeatingAnimation: false,
                ),
              ],
            ),
          ),

          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: BottomWave(color: const Color(0xFFFFC1B8), height: 320),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: BottomWave(color: const Color(0xFFFF9F8F), height: 260),
          ),
        ],
      ),
    );
  }
}

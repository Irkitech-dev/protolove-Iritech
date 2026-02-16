import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:protolove/service/service.dart';
import 'package:provider/provider.dart';

import 'package:staggered_grid_view/flutter_staggered_grid_view.dart';

import '../service/app_service.dart';
import '../utils/utils.dart';
import '../widgets/widgets.dart';
import 'screen.dart';

class SignInUpScreen extends StatefulWidget {
  static const String routeName = 'sign_in_up';
  const SignInUpScreen({super.key});

  @override
  State<SignInUpScreen> createState() => _SignInUpScreenState();
}

class _SignInUpScreenState extends State<SignInUpScreen> {
  bool imagesReady = false;

  List<String> images = [
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

    WidgetsBinding.instance.addPostFrameCallback((_) { 
      if (mounted) {
        setState(() {
          imagesReady = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final appService = context.watch<AppService>();
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: RepaintBoundary(
              child: Container(
                decoration: BoxDecoration(
                  gradient: AppColors().primaryGradient,
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: RepaintBoundary(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      AppColors().primaryColor.withOpacity(0.15),
                      AppColors().primaryColor.withOpacity(0.6),
                      AppColors().primaryColor,
                    ],
                  ),
                ),
              ),
            ),
          ),

          Positioned.fill(
            child: RepaintBoundary(
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                child: ColorFiltered(
                  colorFilter: const ColorFilter.matrix([
                    0.85, 0, 0, 0, 0, // ↓ saturación
                    0, 0.85, 0, 0, 0,
                    0, 0, 0.85, 0, 0,
                    0, 0, 0, 1, 0,
                  ]),
                  child: RepaintBoundary(
                    child: StaggeredImages(
                      images: images,
                      animate: imagesReady,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Contenido
          Positioned(
            bottom: 40,
            left: 24,
            right: 24,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 64),
                  child: Divider(thickness: 6, color: Colors.white),
                ),
                Text(
                  'PROTO\nLOVE',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 64),
                  child: Divider(thickness: 6, color: Colors.white),
                ),
                const SizedBox(height: 30),
                PrimaryButton(
                  text: 'Iniciar sesión',
                  color: AppColors().buttonColor,
                  textColor: Colors.white,
                  onPressed: () {
                    print(appService.isLogged);
                    Navigator.pushNamed(context, LoginScreen.routeName);
                  },
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        thickness: 1,
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.0),
                      child: Text(
                        'o',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        thickness: 1,
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                PrimaryButton(
                  text: 'Registro',
                  textColor: Colors.white,
                  color: AppColors().buttonColor,
                  onPressed: () {
                    //NavigationService().pushNamed(RegisterNameScreen.routeName);
                    Navigator.pushNamed(context, RegisterScreen.routeName);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class StaggeredImages extends StatefulWidget {
  final List<String> images;
  final bool animate;
  const StaggeredImages({
    super.key,
    required this.images,
    required this.animate,
  });

  @override
  State<StaggeredImages> createState() => _StaggeredImagesState();
}

class _StaggeredImagesState extends State<StaggeredImages>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant StaggeredImages oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.animate && !oldWidget.animate) {
      _controller.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StaggeredGridView.countBuilder(
      crossAxisCount: 4,
      itemCount: widget.images.length,
      mainAxisSpacing: 5,
      crossAxisSpacing: 5,
      physics: const NeverScrollableScrollPhysics(),

      itemBuilder: (context, index) {
        final animation = CurvedAnimation(
          parent: _controller,
          curve: Interval(
            index / widget.images.length,
            1.0,
            curve: Curves.easeOut,
          ),
        );

        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, -0.15),
              end: Offset.zero,
            ).animate(animation),
            child: ClipRRect(
              child: Image.asset(
                widget.images[index],
                fit: BoxFit.cover,
                cacheWidth: 400,
                gaplessPlayback: true,
              ),
            ),
          ),
        );
      },

      staggeredTileBuilder: (index) {
        return StaggeredTile.count(1, index % 2 == 0 ? 1.8 : 1.4);
      },
    );
  }
}

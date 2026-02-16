import 'dart:math';
import 'package:flutter/material.dart';
import 'package:protolove/utils/colors.dart';

class RegisterNameScreen extends StatefulWidget {
  static const String routeName = 'register_name';
  const RegisterNameScreen({super.key});

  @override
  State<RegisterNameScreen> createState() => _RegisterNameScreenState();
}

class _RegisterNameScreenState extends State<RegisterNameScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late PageController _pageController;
  int currentPage = 0;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat();

    _pageController = PageController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final t = _controller.value * 2 * pi;

          return Stack(
            children: [
              Container(color: const Color.fromARGB(255, 75, 62, 67)),

              /// Blob rosa principal
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment(sin(t) * 0.5, cos(t) * 0.5),
                      radius: 0.9,
                      colors: [AppColors().secondaryColor, Colors.transparent],
                    ),
                  ),
                ),
              ),

              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment(
                        cos(t + pi / 2) * 0.5,
                        sin(t + pi / 2) * 0.5,
                      ),
                      radius: 0.9,
                      colors: const [Color(0xFFE040FB), Colors.transparent],
                    ),
                  ),
                ),
              ),

              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment(sin(t + pi) * 0.4, cos(t + pi) * 0.4),
                      radius: 1.0,
                      colors: [AppColors().primaryColor, Colors.transparent],
                    ),
                  ),
                ),
              ),

              PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Todo empieza con un nombre',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 42,
                            fontWeight: FontWeight.w300,
                          ),
                        ),

                        const SizedBox(height: 30),

                        const Text(
                          'Una historia, una vibra, una conexión.',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                            height: 1.4,
                          ),
                        ),

                        const SizedBox(height: 30),

                        const Text(
                          'Vamos a crear tu perfil.',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            height: 1.4,
                          ),
                        ),

                        const SizedBox(height: 30),

                        GestureDetector(
                          onTap: () {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 800),
                              curve: Curves.easeInOutCubic,
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 32,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.25),
                              ),
                            ),
                            child: const Text(
                              'Continuar',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '¿Cómo quieres que te llamen?',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 34,
                            fontWeight: FontWeight.w400,
                          ),
                        ),

                        const SizedBox(height: 30),

                        const Text(
                          'Este será el nombre que verán los demás',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            height: 1.4,
                          ),
                        ),

                        const SizedBox(height: 40),

                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                            ),
                          ),
                          child: const TextField(
                            style: TextStyle(color: Colors.white),
                            cursorColor: Colors.white,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Tu nombre…',
                              hintStyle: TextStyle(color: Colors.white54),
                            ),
                          ),
                        ),

                        const SizedBox(height: 30),

                        TextButton(
                          onPressed: () {
                            _pageController.previousPage(
                              duration: const Duration(milliseconds: 800),
                              curve: Curves.easeInOutCubic,
                            );
                          },
                          child: const Text(
                            'Atrás',
                            style: TextStyle(color: Colors.white54),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

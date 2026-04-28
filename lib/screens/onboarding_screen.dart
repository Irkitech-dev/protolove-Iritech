import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:protolove_iritech/service/app_service.dart';
import 'package:protolove_iritech/service/service.dart';
import 'package:protolove_iritech/utils/utils.dart';

import '../widgets/atom/primary_button.dart';
import 'screen.dart';

class OnboardingScreen extends StatefulWidget {
  static const String routeName = 'onboarding';

  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();

  int _currentPage = 0;
  bool _isSubmitting = false;

  final List<_OnboardingPageData> _pages = const [
    _OnboardingPageData(
      imagePath: 'assets/pareja_14.jpg',
      eyebrow: 'PROTOLOVE',
      title: 'Define tu prototipo\nde pareja',
      description:
          'Elegir a tu compañero de vida es una de las decisiones más importantes que tomarás.\n\n'
          'Sin embargo, casi nadie nos enseña cómo hacerlo bien.',
    ),
    _OnboardingPageData(
      imagePath: 'assets/pareja_9.jpg',
      eyebrow: 'EL PROBLEMA',
      title: 'El gran error',
      description:
          'Muchas personas eligen a ciegas: por pura emoción, impulso o miedo a la soledad.\n\n'
          'El resultado suele ser:',
      bullets: [
        'Conflictos constantes',
        'Frustración emocional',
        'Relaciones que no duran',
      ],
    ),
    _OnboardingPageData(
      imagePath: 'assets/pareja_15.jpg',
      eyebrow: 'LA SOLUCIÓN',
      title: 'Claridad total',
      description:
          'ProtoLove te ayuda a elegir con el corazón... pero también con la cabeza.\n\n'
          'No se trata de juzgar a los demás, sino de saber qué necesitas para ser feliz.',
      bullets: [
        'Define lo que buscas',
        'Evalúa con los pies en la tierra',
        'Decide con total seguridad',
      ],
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _finishOnboarding() async {
    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    await context.read<AppService>().completeOnboarding();

    if (!mounted) return;

    NavigationService().pushReplacementNamed(SignInUpScreen.routeName);
  }

  Future<void> _handleContinue() async {
    if (_isSubmitting) return;

    if (_currentPage < _pages.length - 1) {
      await _pageController.nextPage(
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
      );
      return;
    }

    await _finishOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFF4EF), Color(0xFFFFE4DB), Color(0xFFF7D7E6)],
          ),
        ),
        child: Stack(
          children: [
            const _BackgroundOrbs(),
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isSmallHeight = constraints.maxHeight < 650;
                  final horizontalPadding =
                      constraints.maxWidth < 360 ? 16.0 : 20.0;

                  return Padding(
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      14,
                      horizontalPadding,
                      24,
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'ProtoLove',
                                style: GoogleFonts.playfairDisplay(
                                  fontSize:
                                      constraints.maxWidth < 360 ? 24 : 28,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF4F2D36),
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed:
                                  _isSubmitting ? null : _finishOnboarding,
                              child: Text(
                                'Omitir',
                                style: GoogleFonts.inter(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF6A4A54),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: isSmallHeight ? 10 : 18),
                        Expanded(
                          child: PageView.builder(
                            controller: _pageController,
                            itemCount: _pages.length,
                            physics: const NeverScrollableScrollPhysics(),
                            onPageChanged: (value) {
                              setState(() {
                                _currentPage = value;
                              });
                            },
                            itemBuilder: (context, index) {
                              return _OnboardingCard(page: _pages[index]);
                            },
                          ),
                        ),
                        SizedBox(height: isSmallHeight ? 12 : 18),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            _pages.length,
                            (index) => AnimatedContainer(
                              duration: const Duration(milliseconds: 240),
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              height: 8,
                              width: _currentPage == index ? 26 : 8,
                              decoration: BoxDecoration(
                                color:
                                    _currentPage == index
                                        ? colors.buttonColor
                                        : const Color(0xFFD9B8AF),
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: isSmallHeight ? 14 : 22),
                        PrimaryButton(
                          text:
                              _isSubmitting
                                  ? 'Preparando...'
                                  : _currentPage == _pages.length - 1
                                  ? 'Empezar'
                                  : 'Continuar',
                          color: const Color(0xFFEA6D5C),
                          textColor: Colors.white,
                          onPressed: _handleContinue,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingCard extends StatelessWidget {
  final _OnboardingPageData page;

  const _OnboardingCard({required this.page});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallHeight = constraints.maxHeight < 560;
        final isNarrow = constraints.maxWidth < 360;

        final imageHeight =
            constraints.maxHeight *
            (isSmallHeight
                ? 0.34
                : isNarrow
                ? 0.38
                : 0.44);

        final titleSize =
            isNarrow
                ? 24.0
                : isSmallHeight
                ? 25.0
                : 30.0;
        final bodySize =
            isNarrow
                ? 13.5
                : isSmallHeight
                ? 14.0
                : 15.5;
        final bulletSize = isNarrow ? 13.5 : 15.0;
        final cardPadding = isNarrow ? 16.0 : 22.0;

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: SizedBox(
                    height: imageHeight.clamp(180, 330),
                    width: double.infinity,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(page.imagePath, fit: BoxFit.cover),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withOpacity(0.05),
                                Colors.black.withOpacity(0.36),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          left: 18,
                          right: 18,
                          bottom: 18,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(22),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.16),
                                  borderRadius: BorderRadius.circular(22),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.22),
                                  ),
                                ),
                                child: Text(
                                  page.eyebrow,
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 2,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(cardPadding),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.92),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.white.withOpacity(0.8)),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x332B0B11),
                        blurRadius: 24,
                        offset: Offset(0, 16),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        page.title,
                        style: GoogleFonts.playfairDisplay(
                          fontSize: titleSize,
                          height: 1.08,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2F1A21),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        page.description,
                        style: GoogleFonts.inter(
                          fontSize: bodySize,
                          height: 1.5,
                          color: Color(0xFF6A4A54),
                        ),
                      ),
                      if (page.bullets.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        ...page.bullets.map(
                          (bullet) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '•',
                                  style: TextStyle(
                                    fontSize: 22,
                                    height: 1,
                                    color: Color(0xFFEA6D5C),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    bullet,
                                    style: GoogleFonts.inter(
                                      fontSize: bulletSize,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF51363F),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _BackgroundOrbs extends StatelessWidget {
  const _BackgroundOrbs();

  @override
  Widget build(BuildContext context) {
    return const Stack(
      children: [
        Positioned(
          top: -70,
          right: -30,
          child: _Orb(
            size: 220,
            colors: [Color(0x66FFFFFF), Color(0x22FFFFFF)],
          ),
        ),
        Positioned(
          top: 260,
          left: -60,
          child: _Orb(
            size: 180,
            colors: [Color(0x66FFD2C7), Color(0x11FFD2C7)],
          ),
        ),
        Positioned(
          bottom: 80,
          right: -40,
          child: _Orb(
            size: 200,
            colors: [Color(0x44F3B4C7), Color(0x10F3B4C7)],
          ),
        ),
      ],
    );
  }
}

class _Orb extends StatelessWidget {
  final double size;
  final List<Color> colors;

  const _Orb({required this.size, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: colors),
      ),
    );
  }
}

class _OnboardingPageData {
  final String imagePath;
  final String eyebrow;
  final String title;
  final String description;
  final List<String> bullets;

  const _OnboardingPageData({
    required this.imagePath,
    required this.eyebrow,
    required this.title,
    required this.description,
    this.bullets = const [],
  });
}

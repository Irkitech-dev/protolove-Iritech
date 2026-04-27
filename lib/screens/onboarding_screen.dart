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
  bool _didMarkSeen = false;

  final List<_OnboardingPageData> _pages = const [
    _OnboardingPageData(
      imagePath: 'assets/pareja_14.jpg',
      eyebrow: 'PROTOLOVE',
      title: 'Define tu prototipo\nde pareja',
      description:
          'Elegir pareja es una de las decisiones más importantes de tu vida.\n\n'
          'Sin embargo, casi nadie nos enseña cómo hacerlo bien.',
    ),
    _OnboardingPageData(
      imagePath: 'assets/pareja_9.jpg',
      eyebrow: 'EL PROBLEMA',
      title: 'Muchas personas\neligen a ciegas',
      description:
          'Por emoción, impulso o miedo a estar solas.\n\n'
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
      title: 'Elige con el corazón\ny con la cabeza',
      description:
          'ProtoLove te ayuda a tener claridad sobre lo que realmente necesitas para ser feliz.',
      bullets: [
        'Definir lo que buscas',
        'Evaluar personas reales',
        'Tomar mejores decisiones',
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted || _didMarkSeen) return;
      _didMarkSeen = true;
      await context.read<AppService>().completeOnboarding();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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

    setState(() {
      _isSubmitting = true;
    });

    if (!mounted) return;

    NavigationService().pushReplacementNamed(SignInUpScreen.routeName);
  }

  void _skipOnboarding() {
    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    NavigationService().pushReplacementNamed(SignInUpScreen.routeName);
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
            colors: [
              Color(0xFFFFF4EF),
              Color(0xFFFFE4DB),
              Color(0xFFF7D7E6),
            ],
          ),
        ),
        child: Stack(
          children: [
            const _BackgroundOrbs(),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'ProtoLove',
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF4F2D36),
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: _skipOnboarding,
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF7A5560),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          child: Text(
                            'Omitir',
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
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
                    const SizedBox(height: 20),
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
                    const SizedBox(height: 22),
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
        final isCompact = constraints.maxHeight < 560;
        final isNarrow = constraints.maxWidth < 340;
        final imageHeight =
            constraints.maxHeight *
            (isNarrow ? 0.24 : isCompact ? 0.34 : 0.46);
        final titleSize = isNarrow ? 22.0 : isCompact ? 25.0 : 29.0;
        final bodySize = isNarrow ? 12.5 : isCompact ? 14.0 : 15.0;
        final bulletSize = isNarrow ? 13.0 : isCompact ? 14.0 : 15.0;
        final cardPadding = isNarrow ? 16.0 : isCompact ? 20.0 : 24.0;
        const overlap = 28.0;

        return Stack(
          children: [
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              height: imageHeight,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: Stack(
                  children: [
                    SizedBox.expand(
                      child: Image.asset(page.imagePath, fit: BoxFit.cover),
                    ),
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.06),
                              Colors.black.withValues(alpha: 0.36),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 20,
                      right: 20,
                      bottom: 20,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                          child: Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.16),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.22),
                              ),
                            ),
                            child: Text(
                              page.eyebrow,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 2.2,
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
            Positioned(
              left: 0,
              right: 0,
              top: imageHeight - overlap,
              bottom: 0,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(
                  cardPadding,
                  cardPadding,
                  cardPadding,
                  cardPadding,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0x332B0B11),
                      blurRadius: 24,
                      offset: const Offset(0, 16),
                    ),
                  ],
                ),
                child: LayoutBuilder(
                  builder: (context, cardConstraints) {
                    return FittedBox(
                      alignment: Alignment.topLeft,
                      fit: BoxFit.scaleDown,
                      child: SizedBox(
                        width: cardConstraints.maxWidth,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              page.title,
                              style: GoogleFonts.playfairDisplay(
                                fontSize: titleSize,
                                height: 1.08,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF2F1A21),
                              ),
                            ),
                            SizedBox(
                              height: isNarrow ? 8 : isCompact ? 10 : 12,
                            ),
                            Text(
                              page.description,
                              style: GoogleFonts.inter(
                                fontSize: bodySize,
                                height: 1.55,
                                color: const Color(0xFF6A4A54),
                              ),
                            ),
                            if (page.bullets.isNotEmpty) ...[
                              SizedBox(
                                height: isNarrow ? 10 : isCompact ? 12 : 16,
                              ),
                              ...page.bullets.map(
                                (bullet) => Padding(
                                  padding: EdgeInsets.only(
                                    bottom:
                                        isNarrow ? 6 : isCompact ? 8 : 10,
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        margin: const EdgeInsets.only(top: 3),
                                        height:
                                            isNarrow
                                                ? 16
                                                : isCompact
                                                ? 18
                                                : 20,
                                        width:
                                            isNarrow
                                                ? 16
                                                : isCompact
                                                ? 18
                                                : 20,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFFFEFEA),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.check,
                                          size: 12,
                                          color: Color(0xFFEA6D5C),
                                        ),
                                      ),
                                      SizedBox(
                                        width: isNarrow ? 8 : isCompact ? 8 : 10,
                                      ),
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
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _BackgroundOrbs extends StatelessWidget {
  const _BackgroundOrbs();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -70,
          right: -30,
          child: _Orb(
            size: 220,
            colors: const [Color(0x66FFFFFF), Color(0x22FFFFFF)],
          ),
        ),
        Positioned(
          top: 260,
          left: -60,
          child: _Orb(
            size: 180,
            colors: const [Color(0x66FFD2C7), Color(0x11FFD2C7)],
          ),
        ),
        Positioned(
          bottom: 80,
          right: -40,
          child: _Orb(
            size: 200,
            colors: const [Color(0x44F3B4C7), Color(0x10F3B4C7)],
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

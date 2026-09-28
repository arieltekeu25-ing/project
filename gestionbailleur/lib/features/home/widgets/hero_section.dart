import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_constants.dart';
import '../constants/app_strings.dart';
import 'custom_button.dart';

/// Section Hero avec carousel d'images de luxe et animation d'ouverture
class HeroSection extends StatefulWidget {
  const HeroSection({super.key});

  @override
  State<HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<HeroSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _autoScrollTimer;
  
  final List<String> _luxuryImages = [
    'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?w=1200&q=80', // Villa moderne
    'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?w=1200&q=80', // Villa de luxe
    'https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?w=1200&q=80', // Appartement moderne
    'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=1200&q=80', // Maison contemporaine
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppConstants.animationDurationLong,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();
    _startAutoScroll();
  }

  @override
  void dispose() {
    _controller.dispose();
    _pageController.dispose();
    _autoScrollTimer?.cancel();
    super.dispose();
  }

  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_pageController.hasClients) {
        final nextPage = (_currentPage + 1) % _luxuryImages.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _goToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: AppConstants.spacingXXLarge,
        horizontal: AppConstants.spacingLarge,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            Theme.of(context).colorScheme.secondary.withValues(alpha: 0.05),
          ],
        ),
      ),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > AppConstants.breakpointTablet) {
                return _buildDesktopLayout(context);
              } else {
                return _buildMobileLayout(context);
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TypewriterText(
                text: AppStrings.heroTitle,
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                      height: 1.15,
                    ),
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: AppConstants.spacingMedium),
              SizedBox(
                width: double.infinity,
                child: Text(
                  AppStrings.heroSubtitle,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                ),
              ),
              const SizedBox(height: AppConstants.spacingXLarge),
              CustomButton(
                text: AppStrings.searchProperty,
                icon: Icons.search,
                onPressed: () {
                  context.go('/search');
                },
              ),
            ],
          ),
        ),
        const SizedBox(width: AppConstants.spacingXXLarge),
        Expanded(
          flex: 2,
          child: _buildIllustration(),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallMobile = constraints.maxWidth < 400;

        return Column(
          children: [
            // Logo officiel — entier, sans zoom / crop
            SizedBox(
              width: isSmallMobile ? 72 : 88,
              height: isSmallMobile ? 72 : 88,
              child: Image.asset(
                'assetes/images/logo.png',
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.home_work_rounded,
                    size: isSmallMobile ? 48 : 56,
                    color: Theme.of(context).colorScheme.primary,
                  );
                },
              ),
            ),
            const SizedBox(height: AppConstants.spacingMedium),
            // Titre typewriter : toujours 1 ligne, entièrement visible (police réduite si besoin)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: TypewriterText(
                text: AppStrings.heroTitle,
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                      height: 1.1,
                      fontSize: isSmallMobile ? 22 : 26,
                    ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: AppConstants.spacingMedium),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spacingMedium,
              ),
              child: Text(
                AppStrings.heroSubtitle,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                      fontSize: isSmallMobile ? 15 : 17,
                    ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: AppConstants.spacingLarge),
            _buildIllustration(height: isSmallMobile ? 200 : 300),
            const SizedBox(height: AppConstants.spacingLarge),
            CustomButton(
              text: AppStrings.searchProperty,
              icon: Icons.search,
              onPressed: () {
                context.go('/search');
              },
              width: double.infinity,
            ),
          ],
        );
      },
    );
  }

  Widget _buildIllustration({double height = 300}) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        children: [
          // Carousel d'images
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: _luxuryImages.length,
            itemBuilder: (context, index) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(AppConstants.borderRadiusXLarge),
                child: Image.network(
                  _luxuryImages[index],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.home, size: 100, color: Colors.grey),
                    );
                  },
                ),
              );
            },
          ),
          // Boutons de navigation
          Positioned(
            left: 8,
            top: 0,
            bottom: 0,
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.chevron_left, color: Colors.white),
                  onPressed: () {
                    final prevPage = (_currentPage - 1 + _luxuryImages.length) % _luxuryImages.length;
                    _goToPage(prevPage);
                  },
                ),
              ),
            ),
          ),
          Positioned(
            right: 8,
            top: 0,
            bottom: 0,
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.chevron_right, color: Colors.white),
                  onPressed: () {
                    final nextPage = (_currentPage + 1) % _luxuryImages.length;
                    _goToPage(nextPage);
                  },
                ),
              ),
            ),
          ),
          // Indicateurs de page
          Positioned(
            bottom: 12,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _luxuryImages.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == index ? 12 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index ? Colors.white : Colors.white.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget avec effet d'écriture dynamique (typewriter)
/// Le texte reste toujours sur UNE seule ligne et entièrement visible
/// (réduction automatique de la police via FittedBox si l'écran est étroit).
class TypewriterText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;

  const TypewriterText({
    super.key,
    required this.text,
    this.style,
    this.textAlign,
  });

  @override
  State<TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<TypewriterText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _characterCount;
  String _displayText = '';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: (widget.text.length * 55).clamp(1400, 3200)),
      vsync: this,
    );

    _characterCount = IntTween(
      begin: 0,
      end: widget.text.length,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // Animation en boucle : écriture -> pause -> effacement -> pause -> recommence
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // Une fois écrit, attendre puis effacer
        Future.delayed(const Duration(milliseconds: 2000), () {
          if (mounted) {
            _controller.reverse();
          }
        });
      } else if (status == AnimationStatus.dismissed) {
        // Une fois effacé, attendre puis recommencer
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            _controller.forward();
          }
        });
      }
    });

    _controller.forward();

    _characterCount.addListener(() {
      if (!mounted) return;
      setState(() {
        _displayText = widget.text.substring(0, _characterCount.value);
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final align = widget.textAlign ?? TextAlign.start;
    return SizedBox(
      width: double.infinity,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: align == TextAlign.center
            ? Alignment.center
            : align == TextAlign.right
                ? Alignment.centerRight
                : Alignment.centerLeft,
        child: Text(
          _displayText.isEmpty ? ' ' : _displayText,
          style: widget.style,
          textAlign: align,
          maxLines: 1,
          softWrap: false,
          overflow: TextOverflow.visible,
        ),
      ),
    );
  }
}

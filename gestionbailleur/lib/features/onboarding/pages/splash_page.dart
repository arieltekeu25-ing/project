import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/storage_service.dart';
import '../../authentication/providers/auth_provider.dart';
import '../../authentication/models/enums/role_utilisateur.dart';
import '../../home/constants/app_colors.dart';

/// Splash Screen — fond bleu clair, logo entier (pas de zoom / crop)
class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  static const Color _splashBg = Color(0xFFE8F1FF);

  @override
  void initState() {
    super.initState();
    _initAnimation();
    _navigateToNextScreen();
  }

  void _initAnimation() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _animationController.forward();
  }

  Future<void> _navigateToNextScreen() async {
    await Future.delayed(const Duration(milliseconds: 2200));

    if (!mounted) return;

    final authState = ref.read(authProvider);
    final hasCompletedOnboarding = StorageService.instance
            .getBool(AppConstants.keyOnboardingCompleted) ??
        false;

    if (authState.estAuthentifie && authState.utilisateur != null) {
      final utilisateur = authState.utilisateur!;
      switch (utilisateur.role) {
        case RoleUtilisateur.bailleur:
          context.go(AppConstants.routeLandlordDashboard);
          break;
        case RoleUtilisateur.administrateur:
          context.go(AppConstants.routeAdminDashboard);
          break;
        case RoleUtilisateur.client:
          context.go(AppConstants.routeClientDashboard);
          break;
      }
      return;
    }

    if (hasCompletedOnboarding || kIsWeb) {
      context.go(AppConstants.routeHome);
    } else {
      context.go('/onboarding');
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    // Logo bien visible mais jamais trop grand / zoomé
    final logoBox = (size.shortestSide * 0.38).clamp(120.0, 200.0);

    return Scaffold(
      backgroundColor: _splashBg,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: _splashBg,
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: logoBox,
                      height: logoBox,
                      child: Padding(
                        // Marge interne pour que le logo ne soit jamais coupé
                        padding: EdgeInsets.all(logoBox * 0.08),
                        child: Image.asset(
                          'assetes/images/logo.png',
                          fit: BoxFit.contain,
                          alignment: Alignment.center,
                          filterQuality: FilterQuality.high,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.home_work_rounded,
                              size: logoBox * 0.4,
                              color: AppColors.primary,
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'GestBailleur',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.4,
                          ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Votre logement, votre gestion, simplement.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 36),
                    const SizedBox(
                      width: 32,
                      height: 32,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                        strokeWidth: 3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/storage_service.dart';
import '../../../shared/design_system/spacing/ds_spacing.dart';

/// Modèle pour un écran d'onboarding
class OnboardingScreen {
  final String title;
  final String description;
  final IconData icon;
  final Color? iconColor;

  OnboardingScreen({
    required this.title,
    required this.description,
    required this.icon,
    this.iconColor,
  });
}

/// Page d'onboarding mobile avec 4 écrans
class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingScreen> _screens = [
    OnboardingScreen(
      title: 'Trouvez le logement qui vous correspond',
      description: 'Explorez facilement les logements disponibles selon votre ville, quartier, type de bien et budget.',
      icon: Icons.home,
      iconColor: Colors.blue,
    ),
    OnboardingScreen(
      title: 'Échangez directement avec les bailleurs',
      description: 'Discutez avec les bailleurs, posez vos questions et organisez vos visites directement depuis GestBailleur.',
      icon: Icons.chat,
      iconColor: Colors.green,
    ),
    OnboardingScreen(
      title: 'Publiez et gérez vos logements',
      description: 'Publiez vos logements, ajoutez vos photos et vidéos, gérez vos informations et suivez vos statistiques.',
      icon: Icons.add_home,
      iconColor: Colors.orange,
    ),
    OnboardingScreen(
      title: 'Tout votre immobilier au même endroit',
      description: 'Une plateforme simple pour rechercher, publier, communiquer et gérer vos logements.',
      icon: Icons.dashboard,
      iconColor: Colors.purple,
    ),
  ];

  Future<void> _completeOnboarding() async {
    // Marquer l'onboarding comme terminé
    await StorageService.instance.setBool(
      AppConstants.keyOnboardingCompleted,
      true,
    );
    
    if (mounted) {
      // Rediriger vers l'accueil public (mode visiteur) au lieu du login
      context.go(AppConstants.routeHome);
    }
  }

  void _skipOnboarding() {
    _completeOnboarding();
  }

  void _nextPage() {
    if (_currentPage < _screens.length - 1 && _pageController.hasClients) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _previousPage() {
    if (_currentPage > 0 && _pageController.hasClients) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Bouton "Passer" en haut à droite
            Padding(
              padding: const EdgeInsets.all(DSSpacing.md),
              child: Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: _skipOnboarding,
                  child: Text(
                    'Passer',
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),

            // Contenu principal
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _screens.length,
                itemBuilder: (context, index) {
                  return _buildOnboardingScreen(
                    _screens[index],
                    theme,
                  );
                },
              ),
            ),

            // Indicateur de progression
            Padding(
              padding: const EdgeInsets.symmetric(vertical: DSSpacing.md),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _screens.length,
                  (index) => _buildPageIndicator(index, theme),
                ),
              ),
            ),

            // Boutons de navigation
            Padding(
              padding: const EdgeInsets.all(DSSpacing.xl),
              child: Row(
                children: [
                  // Bouton précédent
                  if (_currentPage > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _previousPage,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                        child: const Text('Précédent'),
                      ),
                    )
                  else
                    const Expanded(child: SizedBox()),
                  
                  const SizedBox(width: DSSpacing.md),
                  
                  // Bouton suivant/commencer
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _nextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                      ),
                      child: Text(
                        _currentPage == _screens.length - 1
                            ? 'Commencer'
                            : 'Suivant',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOnboardingScreen(
    OnboardingScreen screen,
    ThemeData theme,
  ) {
    return Padding(
      padding: const EdgeInsets.all(DSSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icône illustrative
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              color: (screen.iconColor ?? theme.colorScheme.primary)
                  .withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              screen.icon,
              size: 80,
              color: screen.iconColor ?? theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: DSSpacing.xl),
          
          // Titre
          Text(
            screen.title,
            style: theme.textTheme.headlineMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: DSSpacing.md),
          
          // Description
          Text(
            screen.description,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator(int index, ThemeData theme) {
    final isActive = index == _currentPage;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: isActive ? 24 : 8,
      decoration: BoxDecoration(
        color: isActive
            ? theme.colorScheme.primary
            : theme.colorScheme.outline.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

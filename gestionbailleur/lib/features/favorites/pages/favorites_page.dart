import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/design_system/spacing/ds_spacing.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../authentication/providers/auth_provider.dart';
import '../../home/widgets/property_card.dart';
import '../providers/favorites_provider.dart';

/// Page de gestion des favoris réels de l'utilisateur (MVVM + Backend DRF)
class FavoritesPage extends ConsumerStatefulWidget {
  const FavoritesPage({super.key});

  @override
  ConsumerState<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends ConsumerState<FavoritesPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        ref.read(favoritesProvider.notifier).loadFavorites();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = ref.watch(authProvider);
    final favState = ref.watch(favoritesProvider);

    return AppScaffold(
      title: 'Mes Favoris',
      showBackButton: true,
      onBackPressed: () {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        } else {
          context.go(AppConstants.routeHome);
        }
      },
      actions: [
        IconButton(
          icon: const Icon(Icons.home_outlined),
          tooltip: 'Accueil',
          onPressed: () => context.go(AppConstants.routeHome),
        ),
        IconButton(
          icon: const Icon(Icons.search_outlined),
          tooltip: 'Recherche',
          onPressed: () => context.go(AppConstants.routeSearch),
        ),
        const SizedBox(width: 8),
      ],
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(favoritesProvider.notifier).loadFavorites(forceRefresh: true);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isSmallMobile = constraints.maxWidth < 400;
              final padding = isSmallMobile ? DSSpacing.md : DSSpacing.lg;
              
              return Padding(
                padding: EdgeInsets.all(padding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Entête
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Vos logements sauvegardés',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: isSmallMobile ? 20 : 22,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Retrouvez facilement les logements que vous avez mis en favoris.',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                  fontSize: isSmallMobile ? 14 : 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (authState.estAuthentifie && favState.favorites.isNotEmpty)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: isSmallMobile ? 10 : 14, 
                              vertical: 8
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${favState.favorites.length} favori${favState.favorites.length > 1 ? 's' : ''}',
                              style: TextStyle(
                                color: theme.colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.bold,
                                fontSize: isSmallMobile ? 12 : 14,
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: isSmallMobile ? DSSpacing.md : DSSpacing.lg),

                    // ÉTAT 1 : Visiteur non connecté
                    if (!authState.estAuthentifie)
                      _buildUnauthenticatedState(context, theme)

                    // ÉTAT 2 : Chargement en cours
                    else if (favState.isLoading && favState.favorites.isEmpty)
                      _buildLoadingState(theme)

                    // ÉTAT 3 : Erreur réseau / serveur
                    else if (favState.errorMessage != null && favState.favorites.isEmpty)
                      _buildErrorState(context, theme, favState.errorMessage!)

                    // ÉTAT 4 : Liste vide (Empty State officiel)
                    else if (favState.favorites.isEmpty)
                      _buildEmptyState(context, theme)

                    // ÉTAT 5 : Liste des favoris réels
                    else
                      _buildFavoritesGrid(context, theme, favState, constraints, isSmallMobile),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildFavoritesGrid(BuildContext context, ThemeData theme, FavoritesState favState, BoxConstraints constraints, bool isSmallMobile) {
    int crossAxisCount;
    double childAspectRatio;
    double crossAxisSpacing;
    double mainAxisSpacing;

    if (constraints.maxWidth > AppConstants.breakpointDesktop) {
      crossAxisCount = 3;
      childAspectRatio = 0.8;
      crossAxisSpacing = DSSpacing.md;
      mainAxisSpacing = DSSpacing.lg;
    } else if (constraints.maxWidth > AppConstants.breakpointTablet) {
      crossAxisCount = 2;
      childAspectRatio = 0.8;
      crossAxisSpacing = DSSpacing.md;
      mainAxisSpacing = DSSpacing.lg;
    } else if (constraints.maxWidth > 600) {
      crossAxisCount = 2;
      childAspectRatio = 0.85;
      crossAxisSpacing = DSSpacing.sm;
      mainAxisSpacing = DSSpacing.md;
    } else {
      crossAxisCount = 1;
      childAspectRatio = 0.85;
      crossAxisSpacing = DSSpacing.sm;
      mainAxisSpacing = DSSpacing.md;
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
        crossAxisSpacing: crossAxisSpacing,
        mainAxisSpacing: mainAxisSpacing,
      ),
      itemCount: favState.favorites.length,
      itemBuilder: (context, index) {
        final property = favState.favorites[index];
        final isRemovingThis = favState.actionPropertyIdLoading == property.id;

        return Stack(
          children: [
            PropertyCard(
              property: property.copyWith(isFavorite: true),
              onTap: () {
                context.go(
                  AppConstants.routePropertyDetails
                      .replaceFirst(':id', property.id),
                );
              },
              onFavoriteToggle: () {
                ref
                    .read(favoritesProvider.notifier)
                    .removeFavorite(property.id, context);
              },
            ),
            if (isRemovingThis)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  /// Interface pour un utilisateur non connecté
  Widget _buildUnauthenticatedState(BuildContext context, ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.lock_outline,
            size: 64,
            color: theme.colorScheme.primary.withValues(alpha: 0.7),
          ),
          const SizedBox(height: 16),
          Text(
            'Connectez-vous pour voir vos favoris',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Sauvegardez vos logements préférés et retrouvez-les à tout moment sur l\'ensemble de vos appareils.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.go(AppConstants.routeLogin),
            icon: const Icon(Icons.login),
            label: const Text('Se connecter'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Interface Skeleton de chargement
  Widget _buildLoadingState(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: const Center(
        child: Column(
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Chargement de vos favoris réels...'),
          ],
        ),
      ),
    );
  }

  /// Interface d'erreur
  Widget _buildErrorState(BuildContext context, ThemeData theme, String errorMsg) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.error.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.cloud_off_outlined,
            size: 64,
            color: theme.colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Erreur lors du chargement des favoris',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.error,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            errorMsg,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () {
              ref.read(favoritesProvider.notifier).loadFavorites(forceRefresh: true);
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }

  /// Empty State officiel conformément aux consignes
  Widget _buildEmptyState(BuildContext context, ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.favorite_border,
            size: 64,
            color: theme.colorScheme.primary.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 16),
          Text(
            "Vous n'avez encore aucun logement en favori.",
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            "Ajoutez les logements qui vous intéressent pour les retrouver facilement.",
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.go(AppConstants.routeSearch),
            icon: const Icon(Icons.search),
            label: const Text('Rechercher un logement'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

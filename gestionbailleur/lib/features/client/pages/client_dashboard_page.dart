import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/design_system/spacing/ds_spacing.dart';
import '../../authentication/providers/auth_provider.dart';
import '../../favorites/providers/favorites_provider.dart';

/// Dashboard Client avec navigation et raccourcis
class ClientDashboardPage extends ConsumerWidget {
  const ClientDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final authState = ref.watch(authProvider);
    final favoritesState = ref.watch(favoritesProvider);
    final utilisateur = authState.utilisateur;

    final initial = utilisateur != null && utilisateur.prenom.isNotEmpty
        ? utilisateur.prenom[0].toUpperCase()
        : 'U';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Espace Client'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
        IconButton(
          icon: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              'assetes/images/logo.png',
              width: 24,
              height: 24,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.home_outlined);
              },
            ),
          ),
          onPressed: () => context.go(AppConstants.routeHome),
          tooltip: 'Accueil',
        ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => context.go(AppConstants.routeNotifications),
            tooltip: 'Notifications',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(DSSpacing.xl),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Banner d'accueil client avec photo
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(DSSpacing.xl),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.primary.withValues(alpha: 0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      if (utilisateur != null && utilisateur.photoUrl != null && utilisateur.photoUrl!.isNotEmpty)
                        CircleAvatar(
                          radius: 40,
                          backgroundImage: CachedNetworkImageProvider(utilisateur.photoUrl!),
                        )
                      else
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.white,
                          child: Text(
                            initial,
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                            ),
                          ),
                        ),
                      const SizedBox(width: DSSpacing.lg),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Bienvenue, ${utilisateur?.prenom ?? ''}!',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Gérez votre recherche de logement et vos favoris.',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: DSSpacing.xxl),

                // Statistiques
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        context,
                        'Favoris',
                        '${favoritesState.favorites.length}',
                        Icons.favorite,
                        Colors.pink,
                      ),
                    ),
                    const SizedBox(width: DSSpacing.md),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        'Visites',
                        '0',
                        Icons.calendar_month,
                        Colors.blue,
                      ),
                    ),
                    const SizedBox(width: DSSpacing.md),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        'Messages',
                        '0',
                        Icons.chat,
                        Colors.green,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: DSSpacing.xxl),

                Text(
                  'Accès rapide',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),

                const SizedBox(height: DSSpacing.lg),

                _buildQuickActionCard(
                  context,
                  'Trouver un logement',
                  'Recherchez parmi toutes les offres disponibles',
                  Icons.search,
                  () => context.go(AppConstants.routeSearch),
                  theme.colorScheme.primary,
                ),

                const SizedBox(height: DSSpacing.md),

                _buildQuickActionCard(
                  context,
                  'Mes Favoris',
                  'Consultez vos logements sauvegardés',
                  Icons.favorite,
                  () => context.go(AppConstants.routeFavorites),
                  Colors.pink,
                ),

                const SizedBox(height: DSSpacing.md),

                _buildQuickActionCard(
                  context,
                  'Mes demandes de visite',
                  'Gérez vos visites programmées',
                  Icons.calendar_month,
                  () => context.go('/visits/my'),
                  Colors.blue,
                ),

                const SizedBox(height: DSSpacing.md),

                _buildQuickActionCard(
                  context,
                  'Mon Profil',
                  'Modifiez vos informations personnelles',
                  Icons.person,
                  () => context.push(AppConstants.routeProfile),
                  Colors.orange,
                ),

                const SizedBox(height: DSSpacing.md),

                _buildQuickActionCard(
                  context,
                  'Messagerie',
                  'Discutez avec les propriétaires',
                  Icons.chat,
                  () => context.go(AppConstants.routeChat),
                  Colors.green,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(DSSpacing.lg),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: DSSpacing.sm),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
    Color color,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(DSSpacing.lg),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: DSSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16),
          ],
        ),
      ),
    );
  }
}

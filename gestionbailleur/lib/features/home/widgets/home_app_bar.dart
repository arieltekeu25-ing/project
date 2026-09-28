import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_strings.dart';
import '../../authentication/models/enums/role_utilisateur.dart';
import '../../authentication/providers/auth_provider.dart';
import '../../authentication/routes/auth_routes.dart';
import '../../favorites/providers/favorites_provider.dart';
import '../../chat/providers/chat_provider.dart';
import '../../notifications/providers/notifications_provider.dart';

/// AppBar adaptative avec navigation horizontale (Web) et menu (Mobile)
class HomeAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final VoidCallback? onSearchTap;
  final VoidCallback? onChatbotTap;
  final VoidCallback? onLoginTap;
  final VoidCallback? onMenuTap;

  const HomeAppBar({
    super.key,
    this.onSearchTap,
    this.onChatbotTap,
    this.onLoginTap,
    this.onMenuTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > AppConstants.breakpointTablet) {
          return _buildDesktopAppBar(context, ref);
        } else {
          return _buildMobileAppBar(context, ref);
        }
      },
    );
  }

  Widget _buildDesktopAppBar(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final favState = ref.watch(favoritesProvider);
    final messagesState = ref.watch(messagesProvider);
    final notifState = ref.watch(notificationsProvider);

    final favCount = favState.favorites.length;
    final unreadMessages = messagesState.totalUnreadCount;
    final unreadNotifs = notifState.unreadCount;
    final totalUnread = unreadMessages + unreadNotifs;

    return AppBar(
      elevation: 0,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      title: InkWell(
        onTap: () => context.go(AppConstants.routeHome),
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                child: Image.asset(
                  'assetes/images/logo.png',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.home,
                      color: Colors.white,
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: AppConstants.spacingSmall),
            Flexible(
              child: Text(
                AppStrings.appName,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      actions: [
        // Navigation horizontale fonctionnelle
        _buildNavButton(context, AppStrings.home, () => context.go(AppConstants.routeHome)),
        _buildNavButton(context, AppStrings.search, onSearchTap ?? () => context.go(AppConstants.routeSearch)),
        _buildNavButton(
          context,
          (authState.estAuthentifie && favCount > 0)
              ? '${AppStrings.favorites} ($favCount)'
              : AppStrings.favorites,
          () => context.go(AppConstants.routeFavorites),
        ),
        _buildNavButton(
          context,
          (authState.estAuthentifie && unreadMessages > 0)
              ? '${AppStrings.messages} ($unreadMessages)'
              : AppStrings.messages,
          () => context.go(AppConstants.routeChat),
        ),
        const SizedBox(width: AppConstants.spacingMedium),
        // Boutons d'action
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: onSearchTap ?? () => context.go(AppConstants.routeSearch),
          tooltip: AppStrings.search,
        ),
        IconButton(
          icon: const Icon(Icons.smart_toy),
          onPressed: onChatbotTap ?? () => context.go(AppConstants.routeChatbot),
          tooltip: 'Chatbot',
        ),
        const SizedBox(width: AppConstants.spacingSmall),

        // État utilisateur (visiteur ou connecté)
        if (!authState.estAuthentifie) ...[
          ElevatedButton.icon(
            onPressed: onLoginTap ?? () => context.push(AuthRoutes.login),
            icon: const Icon(Icons.login, size: 18),
            label: const Text(AppStrings.login),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spacingMedium,
                vertical: AppConstants.spacingSmall,
              ),
            ),
          ),
          const SizedBox(width: AppConstants.spacingSmall),
          OutlinedButton.icon(
            onPressed: () => context.push(AuthRoutes.register),
            icon: const Icon(Icons.person_add, size: 18),
            label: const Text('Créer un compte'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spacingMedium,
                vertical: AppConstants.spacingSmall,
              ),
            ),
          ),
        ] else ...[
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () => context.go(AppConstants.routeNotifications),
                tooltip: 'Notifications',
              ),
              if (totalUnread > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$totalUnread',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          _buildUserMenu(context, ref, authState, favCount, unreadMessages),
        ],
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildMobileAppBar(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final favState = ref.watch(favoritesProvider);
    final messagesState = ref.watch(messagesProvider);
    final notifState = ref.watch(notificationsProvider);

    final favCount = favState.favorites.length;
    final unreadMessages = messagesState.totalUnreadCount;
    final unreadNotifs = notifState.unreadCount;
    final totalUnread = unreadMessages + unreadNotifs;

    return AppBar(
      elevation: 0,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      title: InkWell(
        onTap: () => context.go(AppConstants.routeHome),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                child: Image.asset(
                  'assetes/images/logo.png',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.home,
                      color: Colors.white,
                      size: 20,
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: AppConstants.spacingSmall),
            Flexible(
              child: Text(
                AppStrings.appName,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: onSearchTap ?? () => context.go(AppConstants.routeSearch),
          tooltip: AppStrings.search,
        ),
        IconButton(
          icon: const Icon(Icons.smart_toy),
          onPressed: onChatbotTap ?? () => context.go(AppConstants.routeChatbot),
          tooltip: 'Chatbot',
        ),

        if (!authState.estAuthentifie) ...[
          IconButton(
            icon: const Icon(Icons.login),
            onPressed: onLoginTap ?? () => context.push(AuthRoutes.login),
            tooltip: AppStrings.login,
          ),
        ] else ...[
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () => context.go(AppConstants.routeNotifications),
                tooltip: 'Notifications',
              ),
              if (totalUnread > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$totalUnread',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          _buildUserMenu(context, ref, authState, favCount, unreadMessages),
        ],
      ],
    );
  }

  Widget _buildNavButton(BuildContext context, String text, VoidCallback? onTap) {
    return TextButton(
      onPressed: onTap,
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }

  Widget _buildUserMenu(
      BuildContext context, WidgetRef ref, dynamic authState, int favCount, int unreadMessages) {
    final utilisateur = authState.utilisateur;
    if (utilisateur == null) return const SizedBox();

    final hasPhoto = utilisateur.photoUrl != null && utilisateur.photoUrl!.isNotEmpty;

    return PopupMenuButton<String>(
      icon: Row(
        children: [
          if (hasPhoto)
            CircleAvatar(
              radius: 16,
              backgroundImage: CachedNetworkImageProvider(utilisateur.photoUrl!),
            )
          else
            CircleAvatar(
              radius: 16,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Text(
                utilisateur.prenom.isNotEmpty ? utilisateur.prenom[0].toUpperCase() : 'U',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          const SizedBox(width: 4),
          const Icon(Icons.arrow_drop_down, size: 20),
        ],
      ),
      onSelected: (value) async {
        switch (value) {
          case 'dashboard':
            if (utilisateur.role == RoleUtilisateur.bailleur) {
              context.go(AppConstants.routeLandlordDashboard);
            } else if (utilisateur.role == RoleUtilisateur.administrateur) {
              context.go(AppConstants.routeAdminDashboard);
            } else {
              context.go(AppConstants.routeClientDashboard);
            }
            break;
          case 'messages':
            context.go(AppConstants.routeChat);
            break;
          case 'publish':
            context.go('/properties/publish');
            break;
          case 'profile':
            context.push(AuthRoutes.profile);
            break;
          case 'favorites':
            context.go(AppConstants.routeFavorites);
            break;
          case 'settings':
            context.go(AppConstants.routeSettings);
            break;
          case 'logout':
            await ref.read(authProvider.notifier).deconnexion();
            if (context.mounted) {
              context.go(AppConstants.routeHome);
            }
            break;
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'dashboard',
          child: Row(
            children: [
              const Icon(Icons.dashboard),
              const SizedBox(width: 8),
              Text(utilisateur.role == RoleUtilisateur.bailleur ? 'Espace Bailleur' : 'Mon Tableau de Bord'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'messages',
          child: Row(
            children: [
              const Icon(Icons.chat),
              const SizedBox(width: 8),
              Text(unreadMessages > 0 ? 'Messagerie ($unreadMessages)' : 'Messagerie'),
            ],
          ),
        ),
        if (utilisateur.role == RoleUtilisateur.bailleur)
          const PopupMenuItem(
            value: 'publish',
            child: Row(
              children: [
                Icon(Icons.add_home),
                SizedBox(width: 8),
                Text('Publier un bien'),
              ],
            ),
          ),
        const PopupMenuItem(
          value: 'profile',
          child: Row(
            children: [
              Icon(Icons.person),
              SizedBox(width: 8),
              Text('Mon Profil'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'favorites',
          child: Row(
            children: [
              const Icon(Icons.favorite, color: Colors.pink),
              const SizedBox(width: 8),
              Text(favCount > 0 ? 'Mes Favoris ($favCount)' : 'Mes Favoris'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'settings',
          child: Row(
            children: [
              Icon(Icons.settings),
              SizedBox(width: 8),
              Text('Paramètres'),
            ],
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 'logout',
          child: Row(
            children: [
              Icon(Icons.logout, color: Colors.red),
              SizedBox(width: 8),
              Text('Déconnexion', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
    );
  }
}

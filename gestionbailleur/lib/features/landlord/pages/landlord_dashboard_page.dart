import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:async';
import '../../../core/constants/app_constants.dart';
import '../../../shared/design_system/buttons/ds_button.dart';
import '../../../shared/design_system/spacing/ds_spacing.dart';
import '../../authentication/models/enums/role_utilisateur.dart';
import '../../authentication/models/enums/statut_compte.dart';
import '../../authentication/providers/auth_provider.dart';
import '../../chat/models/conversation_model.dart';
import '../../domain/models/visite.dart';
import '../../home/models/property_model.dart';
import '../../home/providers/property_provider.dart';
import '../models/dashboard_summary_model.dart';
import '../providers/dashboard_provider.dart';
import '../../notifications/providers/notifications_provider.dart';

/// Dashboard Bailleur basé à 100% sur les données réelles backend Django/PostgreSQL.
class LandlordDashboardPage extends ConsumerStatefulWidget {
  const LandlordDashboardPage({super.key});

  @override
  ConsumerState<LandlordDashboardPage> createState() => _LandlordDashboardPageState();
}

class _LandlordDashboardPageState extends ConsumerState<LandlordDashboardPage> {
  int _selectedNavIndex = 0;
  Timer? _notificationTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(dashboardProvider.notifier).loadDashboard();
    });
    _startNotificationRefresh();
  }

  @override
  void dispose() {
    _notificationTimer?.cancel();
    super.dispose();
  }

  void _startNotificationRefresh() {
    // Rafraîchir les notifications toutes les 30 secondes
    _notificationTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      final authState = ref.read(authProvider);
      if (authState.estAuthentifie) {
        ref.read(notificationsProvider.notifier).refreshUnreadCount();
        // Rafraîchir aussi le profil pour mettre à jour le statut après validation admin
        ref.read(authProvider.notifier).refreshProfile();
        // Rafraîchir le dashboard pour avoir les données en temps réel
        ref.read(dashboardProvider.notifier).loadDashboard(isRefresh: true);
      }
    });
  }

  Future<void> _refreshData() async {
    await ref.read(dashboardProvider.notifier).loadDashboard(isRefresh: true);
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _formatTimeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'À l\'instant';
    if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Il y a ${diff.inHours} h';
    if (diff.inDays < 7) return 'Il y a ${diff.inDays} j';
    return _formatDate(date);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final dashboardState = ref.watch(dashboardProvider);
    final utilisateur = authState.utilisateur;
    final theme = Theme.of(context);
    final isDesktop = MediaQuery.of(context).size.width >= 900;
    final isVerified = utilisateur?.statut == StatutCompte.actif;

    // 1. Vérification sécurité authentification
    if (!authState.estAuthentifie || utilisateur == null || dashboardState.isUnauthorized) {
      return _buildUnauthorizedView(context, theme);
    }

    // 2. Vérification sécurité rôle bailleur - restaurée pour la sécurité
    if (utilisateur.role != RoleUtilisateur.bailleur || dashboardState.isForbidden) {
      return _buildForbiddenView(context, theme);
    }

    return Scaffold(
      appBar: isDesktop
          ? null
          : AppBar(
              leading: Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                  tooltip: 'Menu de navigation',
                ),
              ),
              title: const Text(
                'Dashboard Bailleur',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              actions: [
                IconButton(
                  icon: const Icon(Icons.home_outlined),
                  onPressed: () => context.go(AppConstants.routeHome),
                  tooltip: 'Accueil',
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _refreshData,
                  tooltip: 'Actualiser',
                ),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications_outlined),
                      onPressed: () => context.go(AppConstants.routeNotifications),
                      tooltip: 'Notifications',
                    ),
                    if ((dashboardState.summary?.unreadNotificationsCount ?? 0) > 0)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${dashboardState.summary!.unreadNotificationsCount}',
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
                PopupMenuButton<String>(
                  tooltip: 'Profil',
                  offset: const Offset(0, 40),
                  onSelected: (value) async {
                    if (value == 'profile') {
                      context.go(AppConstants.routeProfile);
                    } else if (value == 'settings') {
                      context.go(AppConstants.routeSettings);
                    } else if (value == 'logout') {
                      await ref.read(authProvider.notifier).deconnexion();
                      if (context.mounted) {
                        context.go(AppConstants.routeHome);
                      }
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(value: 'profile', child: Text('Mon profil')),
                    PopupMenuItem(value: 'settings', child: Text('Paramètres')),
                    PopupMenuItem(value: 'logout', child: Text('Déconnexion')),
                  ],
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: theme.colorScheme.primaryContainer,
                      backgroundImage: utilisateur.photoUrl != null && utilisateur.photoUrl!.isNotEmpty
                          ? CachedNetworkImageProvider(utilisateur.photoUrl!)
                          : null,
                      child: utilisateur.photoUrl == null || utilisateur.photoUrl!.isEmpty
                          ? Icon(Icons.person, size: 16, color: theme.colorScheme.onPrimaryContainer)
                          : null,
                    ),
                  ),
                ),
              ],
            ),
      drawer: isDesktop
          ? null
          : Drawer(
              child: _buildSidebar(
                context,
                theme,
                utilisateur,
                isVerified,
                dashboardState.summary,
                isDrawer: true,
              ),
            ),
      body: isDesktop
          ? Row(
              children: [
                // Sidebar de Navigation Desktop / Web
                _buildSidebar(context, theme, utilisateur, isVerified, dashboardState.summary),
                const VerticalDivider(thickness: 1, width: 1),
                // Zone principale fluide
                Expanded(
                  child: Scaffold(
                    appBar: AppBar(
                      title: Text(
                        _getNavigationTitle(_selectedNavIndex),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      elevation: 0,
                      backgroundColor: theme.colorScheme.surface,
                      foregroundColor: theme.colorScheme.onSurface,
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
                          tooltip: 'Retour à l\'accueil',
                        ),
                        IconButton(
                          icon: const Icon(Icons.refresh_outlined),
                          onPressed: _refreshData,
                          tooltip: 'Actualiser',
                        ),
                        const SizedBox(width: DSSpacing.md),
                      ],
                    ),
                    body: RefreshIndicator(
                      onRefresh: _refreshData,
                      child: _buildMainContent(
                        context,
                        dashboardState,
                        utilisateur,
                        isVerified,
                        theme,
                        isDesktop: true,
                      ),
                    ),
                  ),
                ),
              ],
            )
          : RefreshIndicator(
              onRefresh: _refreshData,
              child: _buildMainContent(
                context,
                dashboardState,
                utilisateur,
                isVerified,
                theme,
                isDesktop: false,
              ),
            ),
    );
  }

  String _getNavigationTitle(int index) {
    switch (index) {
      case 0:
        return 'Vue d\'ensemble';
      case 1:
        return 'Mes Logements Réels';
      case 2:
        return 'Demandes de visites';
      case 3:
        return 'Conversations Client';
      case 4:
        return 'Statistiques & Historique';
      default:
        return 'Dashboard Bailleur';
    }
  }

  Widget _buildSidebar(
    BuildContext context,
    ThemeData theme,
    dynamic utilisateur,
    bool isVerified,
    DashboardSummaryModel? summary, {
    bool isDrawer = false,
  }) {
    void closeDrawerIfOpen() {
      if (isDrawer && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    }
    return Container(
      width: 280,
      color: theme.colorScheme.surface,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(DSSpacing.lg),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.05),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => context.go(AppConstants.routeProfile),
                  child: CircleAvatar(
                    radius: 24,
                    backgroundColor: theme.colorScheme.primary,
                    backgroundImage: utilisateur.photoUrl != null && utilisateur.photoUrl!.isNotEmpty
                        ? CachedNetworkImageProvider(utilisateur.photoUrl!)
                        : null,
                    child: utilisateur.photoUrl == null || utilisateur.photoUrl!.isEmpty
                        ? Text(
                            utilisateur.prenom.isNotEmpty == true ? utilisateur.prenom[0].toUpperCase() : 'B',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: DSSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${utilisateur?.prenom ?? ''} ${utilisateur?.nom ?? ''}'.trim(),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      _buildStatusBadge(utilisateur?.statut, theme),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: DSSpacing.md),
              children: [
                ListTile(
                  leading: Icon(
                    _selectedNavIndex == 0 ? Icons.dashboard : Icons.dashboard_outlined,
                    color: _selectedNavIndex == 0 ? theme.colorScheme.primary : null,
                  ),
                  title: const Text('Vue d\'ensemble'),
                  selected: _selectedNavIndex == 0,
                  onTap: () {
                    closeDrawerIfOpen();
                    setState(() => _selectedNavIndex = 0);
                  },
                ),
                ListTile(
                  leading: Icon(
                    _selectedNavIndex == 1 ? Icons.home_work : Icons.home_work_outlined,
                    color: _selectedNavIndex == 1 ? theme.colorScheme.primary : null,
                  ),
                  title: const Text('Mes Logements'),
                  trailing: summary != null
                      ? Chip(
                          label: Text('${summary.totalPropertiesCount}'),
                          padding: EdgeInsets.zero,
                          labelStyle: const TextStyle(fontSize: 11),
                        )
                      : null,
                  selected: _selectedNavIndex == 1,
                  onTap: () {
                    closeDrawerIfOpen();
                    setState(() => _selectedNavIndex = 1);
                  },
                ),
                ListTile(
                  leading: Icon(
                    _selectedNavIndex == 2 ? Icons.calendar_month : Icons.calendar_month_outlined,
                    color: _selectedNavIndex == 2 ? theme.colorScheme.primary : null,
                  ),
                  title: const Text('Demandes de visites'),
                  trailing: (summary?.pendingVisitsCount ?? 0) > 0
                      ? CircleAvatar(
                          radius: 10,
                          backgroundColor: Colors.orange,
                          child: Text(
                            '${summary!.pendingVisitsCount}',
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        )
                      : null,
                  selected: _selectedNavIndex == 2,
                  onTap: () {
                    closeDrawerIfOpen();
                    context.go('/visits/landlord');
                  },
                ),
                ListTile(
                  leading: Icon(
                    _selectedNavIndex == 3 ? Icons.chat : Icons.chat_outlined,
                    color: _selectedNavIndex == 3 ? theme.colorScheme.primary : null,
                  ),
                  title: const Text('Messages Client'),
                  trailing: (summary?.unreadMessagesCount ?? 0) > 0
                      ? CircleAvatar(
                          radius: 10,
                          backgroundColor: theme.colorScheme.primary,
                          child: Text(
                            '${summary!.unreadMessagesCount}',
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        )
                      : null,
                  selected: _selectedNavIndex == 3,
                  onTap: () {
                    closeDrawerIfOpen();
                    context.go(AppConstants.routeChat);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.notifications_outlined),
                  title: const Text('Notifications'),
                  trailing: (summary?.unreadNotificationsCount ?? 0) > 0
                      ? CircleAvatar(
                          radius: 10,
                          backgroundColor: Colors.red,
                          child: Text(
                            '${summary!.unreadNotificationsCount}',
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        )
                      : null,
                  onTap: () {
                    closeDrawerIfOpen();
                    context.go(AppConstants.routeNotifications);
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: const Text('Mon Profil'),
                  onTap: () {
                    closeDrawerIfOpen();
                    context.go(AppConstants.routeProfile);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.settings_outlined),
                  title: const Text('Paramètres'),
                  onTap: () {
                    closeDrawerIfOpen();
                    context.go(AppConstants.routeSettings);
                  },
                ),
              ],
            ),
          ),
          if (isVerified)
            Padding(
              padding: const EdgeInsets.all(DSSpacing.md),
              child: DSButton(
                text: 'Publier un logement',
                icon: Icons.add_home_outlined,
                onPressed: () => context.go('/properties/publish'),
                isFullWidth: true,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMainContent(
    BuildContext context,
    DashboardState state,
    dynamic utilisateur,
    bool isVerified,
    ThemeData theme, {
    required bool isDesktop,
  }) {
    // État Chargement
    if (state.isLoading && state.summary == null) {
      return _buildSkeletonLoading(context, theme);
    }

    // État Erreur
    if (state.errorMessage != null && state.summary == null) {
      return _buildErrorView(context, state, theme);
    }

    final summary = state.summary ??
        DashboardSummaryModel(
          properties: [],
          visits: [],
          conversations: [],
          unreadNotificationsCount: 0,
        );

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.all(isDesktop ? DSSpacing.xl : DSSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Bandeau compte en attente
          if (!isVerified) _buildAccountPendingBanner(context, theme),

          // 2. Header Profil sur Mobile/Tablette
          if (!isDesktop) ...[
            _buildHeaderCard(context, utilisateur, utilisateur.statut, theme),
            const SizedBox(height: DSSpacing.lg),
          ],

          // 3. Cartes de statistiques réelles
          _buildStatCardsGrid(context, summary, theme, isDesktop),

          const SizedBox(height: DSSpacing.xl),

          // 4. Actions Rapides
          _buildQuickActions(context, isVerified, theme),

          const SizedBox(height: DSSpacing.xl),

          // 5. État vide global ou contenu principal
          if (summary.totalPropertiesCount == 0 && summary.totalVisitsCount == 0)
            _buildEmptyDashboard(context, theme, isVerified)
          else ...[
            // Section Logements Réels du bailleur
            _buildLandlordPropertiesSection(context, summary.properties, isVerified, theme),

            const SizedBox(height: DSSpacing.xl),

            // Section Logements les plus demandés (champs réels viewsCount/inquiriesCount)
            if (summary.properties.isNotEmpty) ...[
              _buildTopPropertiesSection(context, summary.topProperties, theme),
              const SizedBox(height: DSSpacing.xl),
            ],

            // Grille 2 colonnes sur Desktop pour Visites récentes & Conversations récentes
            if (isDesktop)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildRecentVisitsSection(context, summary.recentVisits, theme),
                  ),
                  const SizedBox(width: DSSpacing.xl),
                  Expanded(
                    child: _buildRecentConversationsSection(context, summary.recentConversations, theme),
                  ),
                ],
              )
            else
              Column(
                children: [
                  _buildRecentVisitsSection(context, summary.recentVisits, theme),
                  const SizedBox(height: DSSpacing.xl),
                  _buildRecentConversationsSection(context, summary.recentConversations, theme),
                ],
              ),

            const SizedBox(height: DSSpacing.xxl),
          ],
        ],
      ),
    );
  }

  Widget _buildAccountPendingBanner(BuildContext context, ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(DSSpacing.md),
      margin: const EdgeInsets.only(bottom: DSSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.shade300),
      ),
      child: Row(
        children: [
          Icon(Icons.hourglass_top_rounded, color: Colors.amber.shade900, size: 28),
          const SizedBox(width: DSSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Compte en attente de validation administrateur',
                  style: TextStyle(
                    color: Colors.amber.shade900,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Votre profil bailleur est en cours d\'examen. La publication d\'annonces sera activée dès validation.',
                  style: TextStyle(color: Colors.amber.shade900, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(
    BuildContext context,
    dynamic utilisateur,
    StatutCompte? statut,
    ThemeData theme,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(DSSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withValues(alpha: 0.85),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.go(AppConstants.routeProfile),
            child: CircleAvatar(
              radius: 30,
              backgroundColor: Colors.white,
              backgroundImage: utilisateur.photoUrl != null && utilisateur.photoUrl!.isNotEmpty
                  ? CachedNetworkImageProvider(utilisateur.photoUrl!)
                  : null,
              child: utilisateur.photoUrl == null || utilisateur.photoUrl!.isEmpty
                  ? Text(
                      utilisateur.prenom.isNotEmpty == true ? utilisateur.prenom[0].toUpperCase() : 'B',
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    )
                  : null,
            ),
          ),
          const SizedBox(width: DSSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Bonjour, ${utilisateur?.prenom ?? 'Bailleur'}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    _buildStatusBadge(statut, theme),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  utilisateur?.email ?? '',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCardsGrid(
    BuildContext context,
    DashboardSummaryModel summary,
    ThemeData theme,
    bool isDesktop,
  ) {
    final items = [
      _StatItem(
        title: 'Total Logements',
        value: '${summary.totalPropertiesCount}',
        subtitle: '${summary.activePropertiesCount} actif(s) • ${summary.draftPropertiesCount} brouillon(s)',
        icon: Icons.home_work_rounded,
        color: theme.colorScheme.primary,
      ),
      _StatItem(
        title: 'Demandes de visite',
        value: '${summary.totalVisitsCount}',
        subtitle: summary.pendingVisitsCount > 0
            ? '${summary.pendingVisitsCount} en attente'
            : 'Toutes traitées',
        icon: Icons.calendar_month_rounded,
        color: summary.pendingVisitsCount > 0 ? Colors.orange : Colors.blue,
      ),
      _StatItem(
        title: 'Messages non lus',
        value: '${summary.unreadMessagesCount}',
        subtitle: '${summary.totalConversationsCount} conversation(s)',
        icon: Icons.chat_bubble_outline_rounded,
        color: summary.unreadMessagesCount > 0 ? Colors.green : Colors.teal,
      ),
      _StatItem(
        title: 'Notifications',
        value: '${summary.unreadNotificationsCount}',
        subtitle: 'Alertes non lues',
        icon: Icons.notifications_none_rounded,
        color: summary.unreadNotificationsCount > 0 ? Colors.red : Colors.purple,
      ),
    ];

    if (isDesktop) {
      return Row(
        children: items
            .map((item) => Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(right: DSSpacing.md),
                    child: _buildStatCardItem(item, theme),
                  ),
                ))
            .toList(),
      );
    }

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: DSSpacing.md,
      mainAxisSpacing: DSSpacing.md,
      childAspectRatio: 1.45,
      children: items.map((item) => _buildStatCardItem(item, theme)).toList(),
    );
  }

  Widget _buildStatCardItem(_StatItem item, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(DSSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: item.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(item.icon, color: item.color, size: 22),
              ),
              Text(
                item.value,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 2),
              Text(
                item.subtitle,
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  fontSize: 11,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, bool isVerified, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Actions rapides',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: DSSpacing.md),
        Wrap(
          spacing: DSSpacing.md,
          runSpacing: DSSpacing.md,
          children: [
            ElevatedButton.icon(
              onPressed: isVerified ? () => context.go('/properties/publish') : null,
              icon: const Icon(Icons.add_home_work_outlined),
              label: const Text('Publier un logement'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            OutlinedButton.icon(
              onPressed: () => context.go('/visits/landlord'),
              icon: const Icon(Icons.calendar_month_outlined),
              label: const Text('Demandes de visites'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            OutlinedButton.icon(
              onPressed: () => context.go(AppConstants.routeChat),
              icon: const Icon(Icons.chat_outlined),
              label: const Text('Messagerie'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            OutlinedButton.icon(
              onPressed: () => context.go(AppConstants.routeSearch),
              icon: const Icon(Icons.search_rounded),
              label: const Text('Explorer le marché'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmptyDashboard(BuildContext context, ThemeData theme, bool isVerified) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(DSSpacing.xxl),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.other_houses_outlined,
              size: 64,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: DSSpacing.lg),
          Text(
            'Bienvenue sur votre Dashboard Bailleur',
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: DSSpacing.sm),
          Text(
            'Vous n\'avez actuellement aucun logement publié ni aucune demande de visite répertoriée dans la base de données.',
            style: TextStyle(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: DSSpacing.xl),
          if (isVerified)
            DSButton(
              text: 'Publier mon premier logement réel',
              icon: Icons.add_home,
              onPressed: () => context.go('/properties/publish'),
            )
          else
            Text(
              'Votre compte sera activé sous peu par un administrateur.',
              style: TextStyle(
                color: Colors.orange.shade800,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLandlordPropertiesSection(
    BuildContext context,
    List<PropertyModel> properties,
    bool isVerified,
    ThemeData theme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Mes Logements Réels (${properties.length})',
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isVerified)
              TextButton.icon(
                onPressed: () => context.go('/properties/publish'),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Nouveau'),
              ),
          ],
        ),
        const SizedBox(height: DSSpacing.md),
        if (properties.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(DSSpacing.lg),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.dividerColor.withValues(alpha: 0.3)),
            ),
            child: const Text(
              'Aucun logement enregistré pour ce bailleur.',
              style: TextStyle(color: Colors.grey),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: properties.length,
            separatorBuilder: (ctx, idx) => const SizedBox(height: DSSpacing.md),
            itemBuilder: (ctx, idx) {
              final property = properties[idx];
              return _buildPropertyCard(context, property, theme);
            },
          ),
      ],
    );
  }

  Widget _buildPropertyCard(BuildContext context, PropertyModel property, ThemeData theme) {
    final location = [
      if (property.city.isNotEmpty) property.city,
      if (property.district.isNotEmpty) property.district,
    ].join(' • ');

    final image = ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: property.mainPhoto != null && property.mainPhoto!.isNotEmpty
          ? CachedNetworkImage(
              imageUrl: property.mainPhoto!,
              width: double.infinity,
              height: 160,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                height: 160,
                color: theme.colorScheme.primary.withValues(alpha: 0.08),
                child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
              ),
              errorWidget: (context, url, error) => Container(
                height: 160,
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                child: Icon(Icons.home, color: theme.colorScheme.primary, size: 40),
              ),
            )
          : Container(
              height: 160,
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              child: Icon(Icons.home, color: theme.colorScheme.primary, size: 40),
            ),
    );

    final titleBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          property.title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          maxLines: 2,
          softWrap: true,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 6),
        if (location.isNotEmpty)
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  location,
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              property.formattedPrice,
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            _buildFeatureChip(Icons.bed, '${property.bedrooms}'),
            _buildFeatureChip(Icons.bathtub_outlined, '${property.bathrooms}'),
            if (property.surface > 0)
              _buildFeatureChip(Icons.square_foot, property.formattedSurface),
            _buildFeatureChip(Icons.visibility_outlined, '${property.viewsCount}'),
            _buildListingStatusBadge(property.status, theme),
          ],
        ),
      ],
    );

    final actions = Wrap(
      spacing: 4,
      runSpacing: 4,
      children: [
        IconButton(
          icon: const Icon(Icons.visibility_outlined, size: 20),
          tooltip: 'Voir',
          onPressed: () => context.go('/properties/${property.id}'),
        ),
        IconButton(
          icon: const Icon(Icons.edit, size: 20),
          tooltip: 'Modifier',
          onPressed: () => context.go('/properties/${property.id}/edit'),
        ),
        IconButton(
          icon: const Icon(Icons.bar_chart, size: 20),
          tooltip: 'Statistiques',
          onPressed: () => _showPropertyStatistics(context, property, theme),
        ),
        IconButton(
          icon: Icon(
            property.isVisible ? Icons.visibility : Icons.visibility_off,
            size: 20,
            color: property.isVisible ? Colors.green : Colors.grey,
          ),
          tooltip: 'Statut de publication',
          onPressed: () => _togglePropertyVisibility(context, property),
        ),
        IconButton(
          icon: const Icon(Icons.delete, size: 20, color: Colors.red),
          tooltip: 'Supprimer',
          onPressed: () => _showDeletePropertyDialog(context, property),
        ),
      ],
    );

    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => context.go('/properties/${property.id}'),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: theme.dividerColor.withValues(alpha: 0.3)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(DSSpacing.md),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 560;
              if (isNarrow) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    image,
                    const SizedBox(height: DSSpacing.md),
                    titleBlock,
                    const SizedBox(height: DSSpacing.sm),
                    actions,
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: 180, child: image),
                  const SizedBox(width: DSSpacing.md),
                  Expanded(child: titleBlock),
                  const SizedBox(width: DSSpacing.sm),
                  actions,
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureChip(IconData icon, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(value, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
      ],
    );
  }

  Widget _buildTopPropertiesSection(
    BuildContext context,
    List<PropertyModel> topProperties,
    ThemeData theme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.star_outline_rounded, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              'Logements les plus demandés',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Classement basé sur les vues et demandes d\'information réelles transmises au backend.',
          style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 12),
        ),
        const SizedBox(height: DSSpacing.md),
        SizedBox(
          height: 250,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: topProperties.length,
            separatorBuilder: (ctx, idx) => const SizedBox(width: DSSpacing.md),
            itemBuilder: (ctx, idx) {
              final prop = topProperties[idx];
              return Container(
                width: 200,
                height: 210,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.dividerColor.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image du logement
                    Expanded(
                      flex: 3,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                        child: prop.images.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: prop.images.first,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  color: theme.colorScheme.surface.withValues(alpha: 0.5),
                                  child: const Center(child: CircularProgressIndicator()),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  color: theme.colorScheme.surface.withValues(alpha: 0.5),
                                  child: Icon(Icons.home, color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
                                ),
                              )
                            : Container(
                                color: theme.colorScheme.surface.withValues(alpha: 0.5),
                                child: Icon(Icons.home, color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
                              ),
                      ),
                    ),
                    // Info section
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              prop.title,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                              maxLines: 1,
                              softWrap: false,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              prop.formattedPrice,
                              style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 10),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.visibility, size: 10, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                                    const SizedBox(width: 2),
                                    Text('${prop.viewsCount}', style: const TextStyle(fontSize: 9)),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Icon(Icons.question_answer, size: 10, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                                    const SizedBox(width: 2),
                                    Text('${prop.inquiriesCount}', style: const TextStyle(fontSize: 9)),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecentVisitsSection(
    BuildContext context,
    List<Visite> visits,
    ThemeData theme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Demandes de visite récentes',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () => context.go('/visits/landlord'),
              child: const Text('Tout voir'),
            ),
          ],
        ),
        const SizedBox(height: DSSpacing.sm),
        if (visits.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(DSSpacing.lg),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.dividerColor.withValues(alpha: 0.3)),
            ),
            child: const Row(
              children: [
                Icon(Icons.event_available, color: Colors.grey),
                SizedBox(width: DSSpacing.md),
                Text(
                  'Aucune demande de visite enregistrée.',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: visits.length,
            separatorBuilder: (ctx, idx) => const SizedBox(height: DSSpacing.sm),
            itemBuilder: (ctx, idx) {
              final visit = visits[idx];
              return Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.dividerColor.withValues(alpha: 0.3)),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                    child: Icon(Icons.calendar_month, color: theme.colorScheme.primary, size: 20),
                  ),
                  title: Text(
                    visit.clientName ?? 'Client Inconnu',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  subtitle: Text(
                    '${visit.propertyTitle ?? 'Logement'} • ${visit.requestedTime} le ${_formatDate(visit.requestedDate)}',
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: _buildVisitStatusBadge(visit.status, theme),
                  onTap: () => context.go('/visits/landlord'),
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildRecentConversationsSection(
    BuildContext context,
    List<ConversationModel> conversations,
    ThemeData theme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Messages récents',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () => context.go(AppConstants.routeChat),
              child: const Text('Messagerie'),
            ),
          ],
        ),
        const SizedBox(height: DSSpacing.sm),
        if (conversations.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(DSSpacing.lg),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.dividerColor.withValues(alpha: 0.3)),
            ),
            child: const Row(
              children: [
                Icon(Icons.mark_chat_read_outlined, color: Colors.grey),
                SizedBox(width: DSSpacing.md),
                Text(
                  'Aucune conversation active pour le moment.',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: conversations.length,
            separatorBuilder: (ctx, idx) => const SizedBox(height: DSSpacing.sm),
            itemBuilder: (ctx, idx) {
              final conv = conversations[idx];
              return Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.dividerColor.withValues(alpha: 0.3)),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: theme.colorScheme.secondary.withValues(alpha: 0.1),
                    child: Text(
                      conv.otherParticipantName.isNotEmpty
                          ? conv.otherParticipantName[0].toUpperCase()
                          : 'C',
                      style: TextStyle(color: theme.colorScheme.secondary, fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(
                    conv.otherParticipantName,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  subtitle: Text(
                    conv.lastMessage?.content ?? 'Pas de message récent',
                    style: const TextStyle(fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _formatTimeAgo(conv.lastMessageAt),
                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                      if (conv.unreadCount > 0) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${conv.unreadCount}',
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ],
                  ),
                  onTap: () => context.go('/chat/${conv.id}'),
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildSkeletonLoading(BuildContext context, ThemeData theme) {
    return ListView(
      padding: const EdgeInsets.all(DSSpacing.lg),
      children: [
        Container(
          height: 100,
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        const SizedBox(height: DSSpacing.lg),
        Row(
          children: List.generate(
            4,
            (index) => Expanded(
              child: Container(
                height: 90,
                margin: const EdgeInsets.only(right: DSSpacing.sm),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: DSSpacing.xl),
        Container(
          height: 180,
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorView(BuildContext context, DashboardState state, ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(DSSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off_rounded, size: 64, color: Colors.redAccent),
            const SizedBox(height: DSSpacing.lg),
            Text(
              'Erreur de chargement du Dashboard',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: DSSpacing.sm),
            Text(
              state.errorMessage ?? 'Une erreur réseau est survenue.',
              style: const TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: DSSpacing.xl),
            DSButton(
              text: 'Réessayer',
              icon: Icons.refresh_rounded,
              onPressed: _refreshData,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnauthorizedView(BuildContext context, ThemeData theme) {
    return Scaffold(
      appBar: AppBar(title: const Text('Accès non autorisé')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(DSSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline, size: 64, color: Colors.orange),
              const SizedBox(height: DSSpacing.lg),
              const Text(
                'Veuillez vous connecter',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: DSSpacing.sm),
              const Text(
                'Vous devez être connecté pour accéder au tableau de bord bailleur.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: DSSpacing.xl),
              DSButton(
                text: 'Se connecter',
                icon: Icons.login,
                onPressed: () => context.go(AppConstants.routeLogin),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildForbiddenView(BuildContext context, ThemeData theme) {
    return Scaffold(
      appBar: AppBar(title: const Text('Accès refusé')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(DSSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.gpp_maybe_outlined, size: 64, color: Colors.red),
              const SizedBox(height: DSSpacing.lg),
              const Text(
                'Accès réservé aux Bailleurs',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: DSSpacing.sm),
              const Text(
                'Votre compte n\'a pas les privilèges d\'un bailleur. L\'accès au dashboard bailleur est strictly refusé.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: DSSpacing.xl),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => context.go(AppConstants.routeHome),
                    icon: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.asset(
                        'assetes/images/logo.png',
                        width: 18,
                        height: 18,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.home, size: 18);
                        },
                      ),
                    ),
                    label: const Text('Retour à l\'accueil'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListingStatusBadge(String status, ThemeData theme) {
    Color bg;
    Color fg;
    String label;

    switch (status.toUpperCase()) {
      case 'PUBLISHED':
        bg = Colors.green.withValues(alpha: 0.15);
        fg = Colors.green.shade800;
        label = 'Publié';
        break;
      case 'DRAFT':
        bg = Colors.grey.withValues(alpha: 0.2);
        fg = Colors.grey.shade800;
        label = 'Brouillon';
        break;
      case 'RENTED':
        bg = Colors.blue.withValues(alpha: 0.15);
        fg = Colors.blue.shade800;
        label = 'Loué';
        break;
      case 'SUSPENDED':
        bg = Colors.orange.withValues(alpha: 0.15);
        fg = Colors.orange.shade800;
        label = 'Suspendu';
        break;
      case 'REFUSED':
        bg = Colors.red.withValues(alpha: 0.15);
        fg = Colors.red.shade800;
        label = 'Refusé';
        break;
      default:
        bg = Colors.orange.withValues(alpha: 0.15);
        fg = Colors.orange.shade800;
        label = 'En attente';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(color: fg, fontWeight: FontWeight.bold, fontSize: 11),
      ),
    );
  }

  Widget _buildStatusBadge(StatutCompte? statut, ThemeData theme) {
    if (statut == null) return const SizedBox.shrink();

    switch (statut) {
      case StatutCompte.enAttenteValidation:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.amber.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.amber.withValues(alpha: 0.5)),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.access_time_rounded, size: 12, color: Colors.amber),
              SizedBox(width: 4),
              Text('En attente', style: TextStyle(color: Colors.amber, fontSize: 11, fontWeight: FontWeight.w600)),
            ],
          ),
        );
      case StatutCompte.actif:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.green.withValues(alpha: 0.5)),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.verified_rounded, size: 12, color: Colors.green),
              SizedBox(width: 4),
              Text('Validé', style: TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.w600)),
            ],
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  void _showPropertyStatistics(BuildContext context, PropertyModel property, ThemeData theme) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.bar_chart, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            const Text('Statistiques du logement'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                property.title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 16),
              _buildStatRow('Vues', '${property.viewsCount}', Icons.visibility, theme),
              _buildStatRow('Demandes', '${property.inquiriesCount}', Icons.mail, theme),
              _buildStatRow('Statut', property.status, Icons.info, theme),
              _buildStatRow('Type', property.propertyType, Icons.home, theme),
              _buildStatRow('Prix', property.formattedPrice, Icons.attach_money, theme),
              const SizedBox(height: 16),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _showDeletePropertyDialog(BuildContext context, PropertyModel property) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.delete, color: Colors.red),
            SizedBox(width: 8),
            Text('Supprimer le logement'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Êtes-vous sûr de vouloir supprimer "${property.title}" ?',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text('Cette action est irréversible. Toutes les données associées à ce logement seront perdues.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              Navigator.of(context).pop();
              try {
                await ref.read(propertyProvider.notifier).deleteProperty(property.id);
                if (mounted) {
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(
                      content: Text('Logement supprimé avec succès'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text('Erreur lors de la suppression: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  void _togglePropertyVisibility(BuildContext context, PropertyModel property) {
    final isVisible = property.isVisible;
    final action = isVisible ? 'masquer' : 'afficher';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(isVisible ? Icons.visibility_off : Icons.visibility, color: Colors.orange),
            const SizedBox(width: 8),
            Text('${isVisible ? 'Masquer' : 'Afficher'} le logement'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Êtes-vous sûr de vouloir $action "${property.title}" ?',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              isVisible 
                ? 'Le logement ne sera plus visible par les locataires.'
                : 'Le logement sera de nouveau visible par les locataires.',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              Navigator.of(context).pop();
              try {
                if (isVisible) {
                  await ref.read(propertyProvider.notifier).hideProperty(property.id);
                } else {
                  await ref.read(propertyProvider.notifier).unhideProperty(property.id);
                }
                if (mounted) {
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text('Logement ${isVisible ? 'masqué' : 'affiché'} avec succès'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text('Erreur: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildVisitStatusBadge(String status, ThemeData theme) {
    Color color;
    String label;

    switch (status.toUpperCase()) {
      case 'ACCEPTED':
        color = Colors.green;
        label = 'Acceptée';
        break;
      case 'REJECTED':
        color = Colors.red;
        label = 'Refusée';
        break;
      case 'RESCHEDULED':
        color = Colors.purple;
        label = 'Reprogrammée';
        break;
      case 'COMPLETED':
        color = Colors.blue;
        label = 'Terminée';
        break;
      case 'CANCELLED':
        color = Colors.grey;
        label = 'Annulée';
        break;
      default:
        color = Colors.orange;
        label = 'En attente';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11),
      ),
    );
  }
}

class _StatItem {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  _StatItem({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });
}

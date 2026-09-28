import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/design_system/spacing/ds_spacing.dart';
import '../../../shared/design_system/buttons/ds_button.dart';
import '../../authentication/providers/auth_provider.dart';
import '../providers/admin_provider.dart';
import '../models/admin_user_model.dart';

/// Dashboard Admin pour la gestion des utilisateurs
class AdminDashboardPage extends ConsumerStatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  ConsumerState<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends ConsumerState<AdminDashboardPage> {
  @override
  void initState() {
    super.initState();
    // Charger les utilisateurs au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(adminProvider.notifier).loadUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final adminState = ref.watch(adminProvider);
    final adminNotifier = ref.read(adminProvider.notifier);
    final utilisateur = authState.utilisateur;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Administration'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => adminNotifier.loadUsers(),
            tooltip: 'Actualiser',
          ),
          PopupMenuButton<String>(
            icon: CircleAvatar(
              radius: 16,
              backgroundColor: Colors.white,
              child: Text(
                utilisateur?.prenom.isNotEmpty == true 
                    ? utilisateur!.prenom[0].toUpperCase() 
                    : 'A',
                style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
              ),
            ),
            onSelected: (value) async {
              if (value == 'logout') {
                await ref.read(authProvider.notifier).deconnexion();
                if (context.mounted) {
                  context.go(AppConstants.routeHome);
                }
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 8),
                    Text('Déconnexion'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Header avec statistiques
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(DSSpacing.xl),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.primary.withValues(alpha: 0.8),
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tableau de bord',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: DSSpacing.lg),
                Row(
                  children: [
                    _buildStatCard(context, adminNotifier.users.length.toString(), 'Total', Icons.people, theme),
                    SizedBox(width: DSSpacing.md),
                    _buildStatCard(context, adminNotifier.users.where((u) => u.isClient).length.toString(), 'Clients', Icons.person, theme),
                    SizedBox(width: DSSpacing.md),
                    _buildStatCard(context, adminNotifier.users.where((u) => u.isLandlord).length.toString(), 'Bailleurs', Icons.business, theme),
                    SizedBox(width: DSSpacing.md),
                    _buildStatCard(context, adminNotifier.users.where((u) => u.etatCompte == 'EN_ATTENTE').length.toString(), 'En attente', Icons.pending, theme),
                  ],
                ),
              ],
            ),
          ),
          
          // Filtres
          Container(
            padding: EdgeInsets.all(DSSpacing.md),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('Tous', 'all', adminNotifier),
                  SizedBox(width: DSSpacing.sm),
                  _buildFilterChip('Clients', 'clients', adminNotifier),
                  SizedBox(width: DSSpacing.sm),
                  _buildFilterChip('Bailleurs', 'landlords', adminNotifier),
                  SizedBox(width: DSSpacing.sm),
                  _buildFilterChip('En attente', 'pending', adminNotifier),
                  SizedBox(width: DSSpacing.sm),
                  _buildFilterChip('Bloqués', 'blocked', adminNotifier),
                ],
              ),
            ),
          ),
          
          // Liste des utilisateurs
          Expanded(
            child: adminState == AdminState.loading
                ? const Center(child: CircularProgressIndicator())
                : adminState == AdminState.error
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, size: 64, color: Colors.red),
                            const SizedBox(height: 16),
                            Text(
                              adminNotifier.errorMessage ?? 'Erreur de chargement',
                              style: const TextStyle(color: Colors.red),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => adminNotifier.loadUsers(),
                              child: const Text('Réessayer'),
                            ),
                          ],
                        ),
                      )
                    : adminNotifier.users.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.people_outline, size: 64, color: Colors.grey),
                                SizedBox(height: 16),
                                Text(
                                  'Aucun utilisateur trouvé',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: EdgeInsets.all(DSSpacing.md),
                            itemCount: adminNotifier.users.length,
                            itemBuilder: (context, index) {
                              final user = adminNotifier.users[index];
                              return _buildUserCard(context, user, theme, adminNotifier);
                            },
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String value,
    String label,
    IconData icon,
    ThemeData theme,
  ) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(DSSpacing.md),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 24),
            SizedBox(height: DSSpacing.sm),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, AdminNotifier adminNotifier) {
    final isSelected = adminNotifier.selectedFilter == value;
    final theme = Theme.of(context);
    
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        adminNotifier.setFilter(value);
      },
      selectedColor: theme.colorScheme.primary.withValues(alpha: 0.2),
      checkmarkColor: theme.colorScheme.primary,
    );
  }

  Widget _buildUserCard(BuildContext context, AdminUserModel user, ThemeData theme, AdminNotifier adminNotifier) {
    return Container(
      margin: EdgeInsets.only(bottom: DSSpacing.md),
      padding: EdgeInsets.all(DSSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                child: Text(
                  user.prenom.isNotEmpty ? user.prenom[0].toUpperCase() : 'U',
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(width: DSSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.nomComplet,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      user.email,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatusBadge(user.etatCompte, theme),
            ],
          ),
          SizedBox(height: DSSpacing.sm),
          Row(
            children: [
              Icon(Icons.phone, size: 16, color: theme.colorScheme.primary),
              SizedBox(width: 4),
              Text(
                user.telephone ?? 'Non renseigné',
                style: theme.textTheme.bodySmall,
              ),
              SizedBox(width: DSSpacing.md),
              Icon(Icons.badge, size: 16, color: theme.colorScheme.primary),
              SizedBox(width: 4),
              Text(
                user.role ?? 'Non défini',
                style: theme.textTheme.bodySmall,
              ),
              SizedBox(width: DSSpacing.md),
              Icon(Icons.calendar_today, size: 16, color: theme.colorScheme.primary),
              SizedBox(width: 4),
              Text(
                _formatDate(user.createdAt),
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
          SizedBox(height: DSSpacing.md),
          Row(
            children: [
              Expanded(
                child: DSButton(
                  text: 'Voir détails',
                  icon: Icons.visibility,
                  type: DSButtonType.secondary,
                  onPressed: () {},
                  isFullWidth: false,
                ),
              ),
              SizedBox(width: DSSpacing.sm),
              Expanded(
                child: DSButton(
                  text: 'Modifier',
                  icon: Icons.edit,
                  type: DSButtonType.secondary,
                  onPressed: () {},
                  isFullWidth: false,
                ),
              ),
              SizedBox(width: DSSpacing.sm),
              if (user.roleCode == 'BAILLEUR' && user.etatCompte == 'EN_ATTENTE')
                Expanded(
                  child: DSButton(
                    text: 'Valider',
                    icon: Icons.check,
                    onPressed: () => _validateUser(context, user, adminNotifier),
                    isFullWidth: false,
                  ),
                ),
              SizedBox(width: DSSpacing.sm),
              if (user.roleCode == 'BAILLEUR' && user.etatCompte == 'EN_ATTENTE')
                Expanded(
                  child: DSButton(
                    text: 'Rejeter',
                    icon: Icons.close,
                    type: DSButtonType.secondary,
                    onPressed: () => _rejectUser(context, user, adminNotifier),
                    isFullWidth: false,
                  ),
                ),
              SizedBox(width: DSSpacing.sm),
              if (user.etatCompte == 'ACTIF')
                Expanded(
                  child: DSButton(
                    text: 'Désactiver',
                    icon: Icons.block,
                    type: DSButtonType.secondary,
                    onPressed: () => _deactivateUser(context, user, adminNotifier),
                    isFullWidth: false,
                  ),
                ),
              SizedBox(width: DSSpacing.sm),
              if (user.etatCompte == 'INACTIF')
                Expanded(
                  child: DSButton(
                    text: 'Activer',
                    icon: Icons.check_circle,
                    type: DSButtonType.secondary,
                    onPressed: () => _activateUser(context, user, adminNotifier),
                    isFullWidth: false,
                  ),
                ),
              SizedBox(width: DSSpacing.sm),
              IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () => _showDeleteDialog(context, user, adminNotifier),
                tooltip: 'Supprimer',
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  void _validateUser(BuildContext context, AdminUserModel user, AdminNotifier adminNotifier) async {
    final messenger = ScaffoldMessenger.of(context);
    await adminNotifier.approveLandlord(user.id);
    if (mounted) {
      messenger.showSnackBar(
        SnackBar(content: Text('${user.nomComplet} a été validé avec succès')),
      );
    }
  }

  void _rejectUser(BuildContext context, AdminUserModel user, AdminNotifier adminNotifier) async {
    final messenger = ScaffoldMessenger.of(context);
    await adminNotifier.rejectLandlord(user.id);
    if (mounted) {
      messenger.showSnackBar(
        SnackBar(content: Text('${user.nomComplet} a été rejeté')),
      );
    }
  }

  void _deactivateUser(BuildContext context, AdminUserModel user, AdminNotifier adminNotifier) async {
    final messenger = ScaffoldMessenger.of(context);
    await adminNotifier.deactivateUser(user.id);
    if (mounted) {
      messenger.showSnackBar(
        SnackBar(content: Text('${user.nomComplet} a été désactivé')),
      );
    }
  }

  void _activateUser(BuildContext context, AdminUserModel user, AdminNotifier adminNotifier) async {
    final messenger = ScaffoldMessenger.of(context);
    await adminNotifier.activateUser(user.id);
    if (mounted) {
      messenger.showSnackBar(
        SnackBar(content: Text('${user.nomComplet} a été activé')),
      );
    }
  }

  Widget _buildStatusBadge(String status, ThemeData theme) {
    Color color;
    String label;
    
    switch (status) {
      case 'ACTIF':
        color = Colors.green;
        label = 'Actif';
        break;
      case 'EN_ATTENTE':
        color = Colors.orange;
        label = 'En attente';
        break;
      case 'BLOQUE':
        color = Colors.red;
        label = 'Bloqué';
        break;
      case 'SUSPENDU':
        color = Colors.orange.shade700;
        label = 'Suspendu';
        break;
      default:
        color = Colors.grey;
        label = status;
    }
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: DSSpacing.sm,
        vertical: DSSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, AdminUserModel user, AdminNotifier adminNotifier) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text('Voulez-vous vraiment supprimer le compte de ${user.nomComplet} ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              Navigator.pop(context);
              await adminNotifier.deleteUser(user.id);
              if (mounted) {
                messenger.showSnackBar(
                  SnackBar(content: Text('${user.nomComplet} a été supprimé avec succès')),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}

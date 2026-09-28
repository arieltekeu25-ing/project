import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/design_system/buttons/ds_button.dart';
import '../../../shared/design_system/spacing/ds_spacing.dart';
import '../providers/auth_provider.dart';

/// Page de compte en attente de validation (pour les bailleurs)
class AccountPendingPage extends ConsumerWidget {
  const AccountPendingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primary.withValues(alpha: 0.05),
              theme.colorScheme.surface,
              theme.colorScheme.primary.withValues(alpha: 0.02),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: size.width > 600 ? DSSpacing.xxl : DSSpacing.lg,
                vertical: DSSpacing.xl,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: DSSpacing.xl),
                    
                    // Illustration animée
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            theme.colorScheme.primary.withValues(alpha: 0.2),
                            theme.colorScheme.primary.withValues(alpha: 0.1),
                          ],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.hourglass_empty_rounded,
                        size: 60,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: DSSpacing.xl),
                    
                    // Badge de statut
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: DSSpacing.md,
                        vertical: DSSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.orange.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 16,
                            color: Colors.orange,
                          ),
                          const SizedBox(width: DSSpacing.xs),
                          Text(
                            'En attente de validation',
                            style: TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: DSSpacing.lg),
                    
                    Text(
                      'Votre compte est en cours de validation',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: DSSpacing.md),
                    Text(
                      'Nous examinons votre demande de compte bailleur. '
                      'Vous serez notifié dès que votre compte sera validé.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: DSSpacing.xl),
                    
                    // Carte d'information
                    Container(
                      padding: const EdgeInsets.all(DSSpacing.lg),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.info_outline_rounded,
                                  color: theme.colorScheme.primary,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: DSSpacing.md),
                              Expanded(
                                child: Text(
                                  'Informations importantes',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: DSSpacing.md),
                          _buildInfoItem(
                            icon: Icons.verified_user_rounded,
                            title: 'Vérification en cours',
                            description: 'Notre équipe vérifie vos informations',
                            theme: theme,
                          ),
                          const SizedBox(height: DSSpacing.md),
                          _buildInfoItem(
                            icon: Icons.schedule_rounded,
                            title: 'Délai de traitement',
                            description: '24 à 48 heures ouvrées',
                            theme: theme,
                          ),
                          const SizedBox(height: DSSpacing.md),
                          _buildInfoItem(
                            icon: Icons.email_rounded,
                            title: 'Notification',
                            description: 'Email envoyé après validation',
                            theme: theme,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: DSSpacing.xl),
                    
                    // Informations utilisateur
                    if (authState.utilisateur != null)
                      Container(
                        padding: const EdgeInsets.all(DSSpacing.lg),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: theme.colorScheme.outline.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Vos informations',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: DSSpacing.md),
                            _buildUserInfoRow(
                              Icons.person_outline_rounded,
                              'Nom complet',
                              '${authState.utilisateur!.prenom} ${authState.utilisateur!.nom}',
                              theme,
                            ),
                            const SizedBox(height: DSSpacing.sm),
                            _buildUserInfoRow(
                              Icons.email_outlined,
                              'Email',
                              authState.utilisateur!.email,
                              theme,
                            ),
                            const SizedBox(height: DSSpacing.sm),
                            if (authState.utilisateur!.telephone != null)
                              _buildUserInfoRow(
                                Icons.phone_outlined,
                                'Téléphone',
                                authState.utilisateur!.telephone!,
                                theme,
                              ),
                          ],
                        ),
                      ),
                    const SizedBox(height: DSSpacing.xl),
                    
                    // Bouton de déconnexion
                    DSButton(
                      text: 'Se déconnecter',
                      onPressed: () async {
                        await ref.read(authProvider.notifier).deconnexion();
                        if (context.mounted) {
                          context.go('/');
                        }
                      },
                      type: DSButtonType.secondary,
                      isFullWidth: true,
                      size: DSButtonSize.large,
                    ),
                    const SizedBox(height: DSSpacing.md),
                    
                    // Bouton de retour accueil
                    DSButton(
                      text: 'Retour à l\'accueil',
                      onPressed: () {
                        context.go('/');
                      },
                      type: DSButtonType.text,
                      isFullWidth: true,
                    ),
                    const SizedBox(height: DSSpacing.md),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String description,
    required ThemeData theme,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 18,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(width: DSSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUserInfoRow(
    IconData icon,
    String label,
    String value,
    ThemeData theme,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
        ),
        const SizedBox(width: DSSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

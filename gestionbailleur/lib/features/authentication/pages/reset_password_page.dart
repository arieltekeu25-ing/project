import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/design_system/inputs/ds_text_field.dart';
import '../../../shared/design_system/buttons/ds_button.dart';
import '../../../shared/design_system/spacing/ds_spacing.dart';
import '../providers/auth_provider.dart';
import '../routes/auth_routes.dart';

/// Page de réinitialisation du mot de passe
class ResetPasswordPage extends ConsumerStatefulWidget {
  final String token;

  const ResetPasswordPage({super.key, required this.token});

  @override
  ConsumerState<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends ConsumerState<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _motDePasseController = TextEditingController();
  final _motDePasseConfirmController = TextEditingController();

  @override
  void dispose() {
    _motDePasseController.dispose();
    _motDePasseConfirmController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    if (_formKey.currentState!.validate()) {
      await ref.read(authProvider.notifier).resetPassword(
        token: widget.token,
        nouveauMotDePasse: _motDePasseController.text,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mot de passe réinitialisé avec succès'),
            duration: Duration(seconds: 3),
          ),
        );
        Navigator.of(context).pushReplacementNamed(AuthRoutes.login);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final theme = Theme.of(context);

    return AppScaffold(
      title: 'Réinitialiser le mot de passe',
      showBackButton: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(DSSpacing.xl),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: DSSpacing.xl),
              
              // Icone d'illustration
              Icon(
                Icons.lock_reset,
                size: 80,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: DSSpacing.lg),
              
              Text(
                'Nouveau mot de passe',
                style: theme.textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: DSSpacing.sm),
              Text(
                'Entrez votre nouveau mot de passe',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: DSSpacing.xl),
              
              // Champ mot de passe
              DSTextField(
                controller: _motDePasseController,
                label: 'Nouveau mot de passe',
                hint: 'Entrez votre nouveau mot de passe',
                type: DSTextFieldType.password,
                prefixIcon: const Icon(Icons.lock_outline),
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre mot de passe';
                  }
                  if (value.length < 8) {
                    return 'Le mot de passe doit contenir au moins 8 caractères';
                  }
                  if (!value.contains(RegExp(r'[0-9]'))) {
                    return 'Le mot de passe doit contenir au moins un chiffre';
                  }
                  if (!value.contains(RegExp(r'[A-Z]'))) {
                    return 'Le mot de passe doit contenir au moins une majuscule';
                  }
                  if (!value.contains(RegExp(r'[a-z]'))) {
                    return 'Le mot de passe doit contenir au moins une minuscule';
                  }
                  return null;
                },
              ),
              const SizedBox(height: DSSpacing.md),
              
              // Champ confirmation mot de passe
              DSTextField(
                controller: _motDePasseConfirmController,
                label: 'Confirmer le mot de passe',
                hint: 'Confirmez votre mot de passe',
                type: DSTextFieldType.password,
                prefixIcon: const Icon(Icons.lock_outline),
                textInputAction: TextInputAction.done,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez confirmer votre mot de passe';
                  }
                  if (value != _motDePasseController.text) {
                    return 'Les mots de passe ne correspondent pas';
                  }
                  return null;
                },
              ),
              const SizedBox(height: DSSpacing.lg),
              
              // Message d'erreur
              if (authState.messageErreur != null)
                Container(
                  padding: const EdgeInsets.all(DSSpacing.md),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: theme.colorScheme.error),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: theme.colorScheme.error),
                      const SizedBox(width: DSSpacing.sm),
                      Expanded(
                        child: Text(
                          authState.messageErreur!,
                          style: TextStyle(color: theme.colorScheme.error),
                        ),
                      ),
                    ],
                  ),
                ),
              if (authState.messageErreur != null)
                const SizedBox(height: DSSpacing.md),
              
              // Bouton de réinitialisation
              DSButton(
                text: 'Réinitialiser',
                onPressed: authState.estChargement ? null : _handleResetPassword,
                isLoading: authState.estChargement,
                isFullWidth: true,
                size: DSButtonSize.large,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

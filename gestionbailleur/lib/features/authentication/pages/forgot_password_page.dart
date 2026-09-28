import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/design_system/inputs/ds_text_field.dart';
import '../../../shared/design_system/buttons/ds_button.dart';
import '../../../shared/design_system/spacing/ds_spacing.dart';
import '../providers/auth_provider.dart';
import '../routes/auth_routes.dart';
import 'package:go_router/go_router.dart';

/// Page de mot de passe oublié
class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSendResetLink() async {
    if (_formKey.currentState!.validate()) {
      await ref.read(authProvider.notifier).reinitialiserMotDePasse(
        _emailController.text.trim(),
      );
      
      if (mounted) {
        final theme = Theme.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Si un compte existe avec cet email, vous recevrez un lien de réinitialisation.'),
            backgroundColor: theme.colorScheme.primary,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                constraints: const BoxConstraints(maxWidth: 500),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Bouton retour
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: Icon(
                          Icons.arrow_back_rounded,
                          color: theme.colorScheme.onSurface,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: theme.colorScheme.surface,
                          padding: const EdgeInsets.all(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: DSSpacing.lg),
                    
                    // Illustration
                    Container(
                      width: 100,
                      height: 100,
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
                        Icons.lock_reset_rounded,
                        size: 50,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: DSSpacing.xl),
                    
                    Text(
                      'Mot de passe oublié ?',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: DSSpacing.md),
                    Text(
                      'Entrez votre adresse email pour recevoir un lien de réinitialisation de votre mot de passe.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: DSSpacing.xl),
                    
                    // Carte de formulaire
                    Container(
                      padding: const EdgeInsets.all(DSSpacing.xl),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            DSTextField(
                              controller: _emailController,
                              label: 'Adresse email',
                              hint: 'exemple@email.com',
                              type: DSTextFieldType.email,
                              prefixIcon: const Icon(Icons.email_outlined),
                              textInputAction: TextInputAction.done,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Veuillez entrer votre email';
                                }
                                final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
                                if (!emailRegex.hasMatch(value.trim())) {
                                  return 'Format d\'email invalide';
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
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: theme.colorScheme.error.withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.error_outline_rounded,
                                      color: theme.colorScheme.error,
                                      size: 20,
                                    ),
                                    const SizedBox(width: DSSpacing.sm),
                                    Expanded(
                                      child: Text(
                                        authState.messageErreur!,
                                        style: TextStyle(
                                          color: theme.colorScheme.error,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            if (authState.messageErreur != null)
                              const SizedBox(height: DSSpacing.md),
                            
                            DSButton(
                              text: 'Envoyer le lien',
                              onPressed: authState.estChargement ? null : _handleSendResetLink,
                              isLoading: authState.estChargement,
                              loadingText: 'Envoi en cours...',
                              isFullWidth: true,
                              size: DSButtonSize.large,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: DSSpacing.xl),
                    
                    // Lien vers connexion
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          'Vous vous souvenez de votre mot de passe ? ',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            context.push(AuthRoutes.login);
                          },
                          child: Text(
                            'Se connecter',
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
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

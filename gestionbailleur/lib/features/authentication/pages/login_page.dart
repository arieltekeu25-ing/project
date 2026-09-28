import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/design_system/inputs/ds_text_field.dart';
import '../../../shared/design_system/buttons/ds_button.dart';
import '../../../shared/design_system/spacing/ds_spacing.dart';
import '../../../core/constants/app_constants.dart';
import '../providers/auth_provider.dart';
import '../routes/auth_routes.dart';
import 'package:go_router/go_router.dart';

/// Page de connexion
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _identifiantController = TextEditingController();
  final _motDePasseController = TextEditingController();

  @override
  void dispose() {
    _identifiantController.dispose();
    _motDePasseController.dispose();
    super.dispose();
  }

  Future<void> _handleConnexion() async {
    if (_formKey.currentState!.validate()) {
      await ref.read(authProvider.notifier).connexion(
        identifiant: _identifiantController.text.trim(),
        motDePasse: _motDePasseController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final theme = Theme.of(context);

    // Redirection automatique après connexion réussie
    if (authState.estAuthentifie && authState.utilisateur != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final notifier = ref.read(authProvider.notifier);
        final route = notifier.getRouteRedirection();
        context.go(route);
      });
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary.withValues(alpha: 0.1),
              theme.colorScheme.secondary.withValues(alpha: 0.1),
              theme.colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(DSSpacing.xl),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Container(
                  padding: const EdgeInsets.all(DSSpacing.xl),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: theme.colorScheme.outline.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: DSSpacing.lg),
                        
                        // Logo et titre
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              'assetes/images/logo.png',
                              width: 80,
                              height: 80,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.home_rounded,
                                  size: 48,
                                  color: theme.colorScheme.primary,
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: DSSpacing.lg),
                        
                        Text(
                          'Bienvenue',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: DSSpacing.sm),
                        Text(
                          'Connectez-vous pour continuer',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: DSSpacing.xl),
                        
                        // Champ email
                        DSTextField(
                          controller: _identifiantController,
                          label: 'Email',
                          hint: 'Entrez votre email',
                          type: DSTextFieldType.email,
                          prefixIcon: const Icon(Icons.email_outlined),
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer votre email';
                            }
                            if (!value.contains('@') || !value.contains('.')) {
                              return 'Email invalide';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: DSSpacing.md),
                        
                        // Champ mot de passe
                        DSTextField(
                          controller: _motDePasseController,
                          label: 'Mot de passe',
                          hint: 'Entrez votre mot de passe',
                          type: DSTextFieldType.password,
                          prefixIcon: const Icon(Icons.lock_outline),
                          textInputAction: TextInputAction.done,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer votre mot de passe';
                            }
                            if (value.length < 8) {
                              return 'Le mot de passe doit contenir au moins 8 caractères';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: DSSpacing.sm),
                        
                        // Lien mot de passe oublié
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              context.push(AuthRoutes.forgotPassword);
                            },
                            child: Text(
                              'Mot de passe oublié ?',
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: DSSpacing.lg),
                        
                        // Message d'erreur
                        if (authState.messageErreur != null)
                          Container(
                            padding: const EdgeInsets.all(DSSpacing.md),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.error.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: theme.colorScheme.error.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.error_outline, color: theme.colorScheme.error, size: 20),
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
                        
                        // Bouton de connexion
                        DSButton(
                          text: 'Se connecter',
                          onPressed: authState.estChargement ? null : _handleConnexion,
                          isLoading: authState.estChargement,
                          loadingText: 'Connexion en cours...',
                          isFullWidth: true,
                          size: DSButtonSize.large,
                        ),
                        const SizedBox(height: DSSpacing.xl),
                        
                        // Séparateur
                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                color: theme.colorScheme.outline.withValues(alpha: 0.2),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: DSSpacing.md),
                              child: Text(
                                'ou',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: theme.colorScheme.outline.withValues(alpha: 0.2),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: DSSpacing.xl),
                        
                        // Bouton Continuer avec Google
                        Container(
                          width: double.infinity,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.3)),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('La connexion avec Google sera bientôt disponible.'),
                                    backgroundColor: Colors.orange,
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: Image.network(
                                      'https://www.google.com/favicon.ico',
                                      errorBuilder: (context, error, stackTrace) {
                                        return const Icon(Icons.g_mobiledata, size: 24, color: Colors.grey);
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    'Continuer avec Google',
                                    style: TextStyle(
                                      color: Colors.black87,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: DSSpacing.xl),
                        
                        // Lien vers inscription
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Pas encore de compte ? ',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                context.push(AuthRoutes.register);
                              },
                              child: Text(
                                'S\'inscrire',
                                style: TextStyle(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: DSSpacing.md),
                        
                        // Lien vers l'accueil (mode visiteur)
                        Center(
                          child: TextButton(
                            onPressed: () {
                              context.go(AppConstants.routeHome);
                            },
                            child: Text(
                              'Continuer en tant que visiteur',
                              style: TextStyle(
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

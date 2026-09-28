import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/design_system/inputs/ds_text_field.dart';
import '../../../shared/design_system/inputs/ds_phone_field.dart';
import '../../../shared/design_system/buttons/ds_button.dart';
import '../../../shared/design_system/spacing/ds_spacing.dart';
import '../providers/auth_provider.dart';
import '../routes/auth_routes.dart';
import 'package:go_router/go_router.dart';

/// Page d'inscription
class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _telephoneController = TextEditingController();
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _motDePasseController = TextEditingController();
  final _motDePasseConfirmController = TextEditingController();
  
  String _userType = 'client'; // 'client' ou 'landlord'
  bool _acceptTerms = false;

  @override
  void dispose() {
    _emailController.dispose();
    _telephoneController.dispose();
    _nomController.dispose();
    _prenomController.dispose();
    _motDePasseController.dispose();
    _motDePasseConfirmController.dispose();
    super.dispose();
  }

  Future<void> _handleInscription() async {
    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez accepter le Contrat de Licence et les CGU pour continuer.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }
    if (_formKey.currentState!.validate()) {
      // Nettoyer le numéro de téléphone : enlever tous les espaces et ajouter +237
      String telephone = '+237${_telephoneController.text.trim().replaceAll(' ', '')}';
      
      if (_userType == 'client') {
        await ref.read(authProvider.notifier).inscriptionClient(
          email: _emailController.text.trim(),
          motDePasse: _motDePasseController.text,
          nom: _nomController.text.trim(),
          prenom: _prenomController.text.trim(),
          telephone: telephone,
        );
      } else {
        await ref.read(authProvider.notifier).inscriptionBailleur(
          email: _emailController.text.trim(),
          motDePasse: _motDePasseController.text,
          nom: _nomController.text.trim(),
          prenom: _prenomController.text.trim(),
          telephone: telephone,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final theme = Theme.of(context);

    // Redirection automatique après inscription réussie
    if (authState.estAuthentifie && authState.utilisateur != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final notifier = ref.read(authProvider.notifier);
        final route = notifier.getRouteRedirection();
        Navigator.of(context).pushReplacementNamed(route);
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
                constraints: const BoxConstraints(maxWidth: 600),
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
                                  Icons.person_add_rounded,
                                  size: 48,
                                  color: theme.colorScheme.primary,
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: DSSpacing.lg),
                        
                        Text(
                          'Créer un compte',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: DSSpacing.sm),
                        Text(
                          'Rejoignez-nous en quelques secondes',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: DSSpacing.xl),
                        
                        // Sélection du type d'utilisateur
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: theme.colorScheme.outline.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() => _userType = 'client'),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    decoration: BoxDecoration(
                                      color: _userType == 'client'
                                          ? theme.colorScheme.primary
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.person,
                                          size: 20,
                                          color: _userType == 'client'
                                              ? Colors.white
                                              : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Locataire',
                                          style: TextStyle(
                                            color: _userType == 'client'
                                                ? Colors.white
                                                : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                            fontWeight: _userType == 'client'
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() => _userType = 'landlord'),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    decoration: BoxDecoration(
                                      color: _userType == 'landlord'
                                          ? theme.colorScheme.primary
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.business,
                                          size: 20,
                                          color: _userType == 'landlord'
                                              ? Colors.white
                                              : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Bailleur',
                                          style: TextStyle(
                                            color: _userType == 'landlord'
                                                ? Colors.white
                                                : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                            fontWeight: _userType == 'landlord'
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: DSSpacing.xl),
                        
                        // Champ nom
                        DSTextField(
                          controller: _nomController,
                          label: 'Nom',
                          hint: 'Entrez votre nom',
                          prefixIcon: const Icon(Icons.person_outline),
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Veuillez entrer votre nom';
                            }
                            if (value.trim().length < 2) {
                              return 'Le nom doit contenir au moins 2 caractères';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: DSSpacing.md),
                        
                        // Champ prénom
                        DSTextField(
                          controller: _prenomController,
                          label: 'Prénom',
                          hint: 'Entrez votre prénom',
                          prefixIcon: const Icon(Icons.person_outline),
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Veuillez entrer votre prénom';
                            }
                            if (value.trim().length < 2) {
                              return 'Le prénom doit contenir au moins 2 caractères';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: DSSpacing.md),
                        
                        // Champ email
                        DSTextField(
                          controller: _emailController,
                          label: 'Email',
                          hint: 'Entrez votre email',
                          type: DSTextFieldType.email,
                          prefixIcon: const Icon(Icons.email_outlined),
                          textInputAction: TextInputAction.next,
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
                        const SizedBox(height: DSSpacing.md),
                        
                        // Champ téléphone avec drapeau Cameroun
                        DSPhoneField(
                          controller: _telephoneController,
                          labelText: 'Téléphone',
                          hintText: '6XX XXX XXX',
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Veuillez entrer votre numéro de téléphone';
                            }
                            // Vérifier que le numéro a 9 chiffres
                            final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
                            if (digits.length != 9) {
                              return 'Numéro de téléphone invalide (9 chiffres requis)';
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
                        const SizedBox(height: DSSpacing.md),
                        
                        // Info pour les bailleurs
                        if (_userType == 'landlord')
                          Container(
                            padding: const EdgeInsets.all(DSSpacing.md),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.info_outline, color: theme.colorScheme.primary, size: 20),
                                const SizedBox(width: DSSpacing.sm),
                                Expanded(
                                  child: Text(
                                    'Votre compte sera soumis à validation par un administrateur avant de pouvoir publier des logements.',
                                    style: TextStyle(
                                      color: theme.colorScheme.primary,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: DSSpacing.lg),
                        
                        // Message d'erreur
                        if (authState.messageErreur != null && !authState.estAuthentifie)
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
                        if (authState.messageErreur != null && !authState.estAuthentifie)
                          const SizedBox(height: DSSpacing.md),
                        
                        // Acceptation des termes et contrat de licence
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Checkbox(
                              value: _acceptTerms,
                              onChanged: (val) => setState(() => _acceptTerms = val ?? false),
                              activeColor: theme.colorScheme.primary,
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => context.push('/terms'),
                                child: Text.rich(
                                  TextSpan(
                                    text: 'J\'accepte le ',
                                    style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurface),
                                    children: [
                                      TextSpan(
                                        text: 'Contrat de Licence',
                                        style: TextStyle(
                                          color: theme.colorScheme.primary,
                                          fontWeight: FontWeight.bold,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                      const TextSpan(text: ' et les '),
                                      TextSpan(
                                        text: 'CGU de GestBailleur',
                                        style: TextStyle(
                                          color: theme.colorScheme.primary,
                                          fontWeight: FontWeight.bold,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                      const TextSpan(text: '.'),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: DSSpacing.md),
                        
                        // Bouton d'inscription
                        DSButton(
                          text: 'S\'inscrire',
                          onPressed: authState.estChargement ? null : _handleInscription,
                          isLoading: authState.estChargement,
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
                        
                        // Lien vers connexion
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Déjà un compte ? ',
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
                        const SizedBox(height: DSSpacing.md),
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

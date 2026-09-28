import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/app_scaffold.dart';

/// Page affichant le Contrat de Licence et les Conditions Générales d'Utilisation (CGU)
class TermsAndLicensePage extends StatefulWidget {
  final bool requireAcceptance;

  const TermsAndLicensePage({
    super.key,
    this.requireAcceptance = false,
  });

  @override
  State<TermsAndLicensePage> createState() => _TermsAndLicensePageState();
}

class _TermsAndLicensePageState extends State<TermsAndLicensePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _hasReadAndAgreed = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppScaffold(
      title: 'Contrat & Licences',
      showBackButton: true,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.gavel_rounded,
                          color: AppColors.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'GestBailleur Legal & Licences',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Veuillez lire attentivement les termes ci-dessous',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TabBar(
                    controller: _tabController,
                    labelColor: AppColors.primary,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: AppColors.primary,
                    tabs: const [
                      Tab(text: 'Contrat de Licence (EULA)'),
                      Tab(text: 'Conditions Générales (CGU)'),
                    ],
                  ),
                ],
              ),
            ),

            // Contenu
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildEulaSection(theme),
                  _buildCguSection(theme),
                ],
              ),
            ),

            // Footer d'acceptation si requis
            if (widget.requireAcceptance)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -3),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CheckboxListTile(
                      value: _hasReadAndAgreed,
                      onChanged: (val) => setState(() => _hasReadAndAgreed = val ?? false),
                      activeColor: AppColors.primary,
                      title: const Text(
                        'J\'ai lu et j\'accepte le Contrat de Licence et les CGU de GestBailleur.',
                        style: TextStyle(fontSize: 13),
                      ),
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _hasReadAndAgreed
                            ? () => Navigator.of(context).pop(true)
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Accepter et Continuer',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEulaSection(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'CONTRAT DE LICENCE UTILISATEUR FINAL (EULA)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
              SizedBox(height: 12),
              Text(
                '1. Octroi de licence\n'
                'GestBailleur vous octroie une licence non exclusive, non transférable et révocable pour utiliser l\'application mobile GestBailleur conformément au présent contrat.\n\n'
                '2. Engagements du Bailleur\n'
                'Le bailleur certifie détenir les droits légaux ou mandats valides sur chaque bien publié sur la plateforme. Tout bien fictif, annonce frauduleuse ou prix trompeur entraînera la suspension immédiate du compte.\n\n'
                '3. Engagements du Locataire\n'
                'Le locataire s\'engage à fournir des informations exactes lors des demandes de visites et échanges avec les propriétaires.\n\n'
                '4. Protection des Données Personnelles\n'
                'Vos informations (coordonnées, historique de visites) sont protégées par le système de sécurité GestBailleur et ne sont communiquées qu\'aux bailleurs directement concernés.\n\n'
                '5. Service d\'Assistance IA (GestBailleur AI)\n'
                'Le Chatbot IA fournit des informations basées sur les logements enregistrés en base de données. Les accords définitifs de bail restent de la responsabilité directe des parties.',
                style: TextStyle(fontSize: 14, height: 1.5, color: Colors.black87),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCguSection(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'CONDITIONS GÉNÉRALES D\'UTILISATION (CGU)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
              SizedBox(height: 12),
              Text(
                'Article 1 : Accès au service\n'
                'L\'accès à GestBailleur est gratuit pour les recherches de logement. La publication d\'offres par les bailleurs nécessite un compte vérifié et validé par l\'administration.\n\n'
                'Article 2 : Propriété intellectuelle\n'
                'La marque GestBailleur, le logo, le code source et le système de correspondance IA sont la propriété exclusive de GestBailleur.\n\n'
                'Article 3 : Responsabilité\n'
                'GestBailleur met à disposition la plateforme de mise en relation mais n\'est pas partie prenante aux contrats de bail signés entre bailleurs et locataires.\n\n'
                'Article 4 : Modification des termes\n'
                'GestBailleur se réserve le droit de modifier les présentes conditions à tout moment. L\'utilisation continue de l\'application vaut acceptation des modifications.',
                style: TextStyle(fontSize: 14, height: 1.5, color: Colors.black87),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

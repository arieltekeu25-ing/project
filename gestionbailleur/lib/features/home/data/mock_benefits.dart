import '../models/benefit_model.dart';

/// Données fictives pour les avantages
class MockBenefits {
  static List<BenefitModel> getAll() {
    return [
      BenefitModel(
        id: '1',
        title: 'Recherche rapide',
        description: 'Trouvez votre logement idéal en quelques clics grâce à nos filtres avancés et notre algorithme intelligent.',
        icon: 'search',
      ),
      BenefitModel(
        id: '2',
        title: 'Bailleurs vérifiés',
        description: 'Tous nos propriétaires sont vérifiés pour garantir votre sécurité et une location sereine.',
        icon: 'verified',
      ),
      BenefitModel(
        id: '3',
        title: 'Support intelligent',
        description: 'Notre chatbot est disponible 24/7 pour répondre à toutes vos questions.',
        icon: 'support_agent',
      ),
      BenefitModel(
        id: '4',
        title: 'Chat sécurisé',
        description: 'Communiquez en toute sécurité avec les propriétaires via notre messagerie cryptée.',
        icon: 'chat',
      ),
    ];
  }
}

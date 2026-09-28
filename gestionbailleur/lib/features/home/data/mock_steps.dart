import '../models/step_model.dart';

/// Données fictives pour les étapes de fonctionnement
class MockSteps {
  static List<StepModel> getAll() {
    return [
      StepModel(
        id: '1',
        title: 'Rechercher',
        description: 'Utilisez nos filtres pour trouver le logement parfait selon vos critères.',
        icon: 'search',
        order: 1,
      ),
      StepModel(
        id: '2',
        title: 'Choisir',
        description: 'Sélectionnez les annonces qui vous intéressent et ajoutez-les à vos favoris.',
        icon: 'favorite',
        order: 2,
      ),
      StepModel(
        id: '3',
        title: 'Contacter',
        description: 'Échangez avec le propriétaire via notre messagerie sécurisée.',
        icon: 'chat',
        order: 3,
      ),
      StepModel(
        id: '4',
        title: 'Visiter',
        description: 'Planifiez une visite et signez votre bail en toute confiance.',
        icon: 'home',
        order: 4,
      ),
    ];
  }
}

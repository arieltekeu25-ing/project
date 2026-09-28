/// Modèle de données pour une étape de fonctionnement
class StepModel {
  final String id;
  final String title;
  final String description;
  final String icon;
  final int order;

  StepModel({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.order,
  });
}

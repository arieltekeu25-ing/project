/// Modèle de données pour un témoignage
class TestimonialModel {
  final String id;
  final String authorName;
  final String authorRole;
  final String content;
  final double rating;
  final String imageUrl;

  TestimonialModel({
    required this.id,
    required this.authorName,
    required this.authorRole,
    required this.content,
    required this.rating,
    required this.imageUrl,
  });
}

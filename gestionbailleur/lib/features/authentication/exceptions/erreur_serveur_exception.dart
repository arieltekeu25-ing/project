/// Exception levée lors d'une erreur serveur
class ErreurServeurException implements Exception {
  final String message;
  final String? code;
  final int? statusCode;

  ErreurServeurException({
    this.message = 'Une erreur serveur est survenue',
    this.code,
    this.statusCode,
  });

  @override
  String toString() => message;
}

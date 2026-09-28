/// Exception levée lorsque la session est expirée
class SessionExpireeException implements Exception {
  final String message;
  final String? code;

  SessionExpireeException({
    this.message = 'La session a expiré',
    this.code,
  });

  @override
  String toString() => message;
}

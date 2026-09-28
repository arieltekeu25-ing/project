/// Exception levée lorsque le mot de passe est invalide
class MotDePasseInvalideException implements Exception {
  final String message;
  final String? code;

  MotDePasseInvalideException({
    this.message = 'Le mot de passe est invalide',
    this.code,
  });

  @override
  String toString() => message;
}

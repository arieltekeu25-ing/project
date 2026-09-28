/// Exception levée lorsque l'email est invalide
class EmailInvalideException implements Exception {
  final String message;
  final String? code;

  EmailInvalideException({
    this.message = 'L\'adresse email est invalide',
    this.code,
  });

  @override
  String toString() => message;
}

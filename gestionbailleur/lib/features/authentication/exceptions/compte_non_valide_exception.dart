/// Exception levée lorsque le compte n'est pas valide
class CompteNonValideException implements Exception {
  final String message;
  final String? code;

  CompteNonValideException({
    this.message = 'Le compte n\'est pas valide',
    this.code,
  });

  @override
  String toString() => message;
}

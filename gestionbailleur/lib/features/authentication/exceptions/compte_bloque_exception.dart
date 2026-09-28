/// Exception levée lorsque le compte est bloqué
class CompteBloqueException implements Exception {
  final String message;
  final String? code;
  final DateTime? dateDeblocage;

  CompteBloqueException({
    this.message = 'Le compte est bloqué',
    this.code,
    this.dateDeblocage,
  });

  @override
  String toString() => message;
}

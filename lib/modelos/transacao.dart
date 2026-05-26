
class Transacao {
  final String id;
  final String titulo;
  final double valor;
  final bool isReceita;

  Transacao({
    required this.id,
    required this.titulo,
    required this.valor,
    required this.isReceita,
  });
}
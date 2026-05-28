class Transacao {
  final String id;
  final String titulo;
  final double valor;
  final bool isReceita;
  final String categoria;
  final DateTime data;
  final String formaPagamento;

  Transacao({
    required this.id,
    required this.titulo,
    required this.valor,
    required this.isReceita,
    required this.categoria,
    required this.data,
    required this.formaPagamento,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'valor': valor,
      'isReceita': isReceita,
      'categoria': categoria,
      'data': data.toIso8601String(),
      'formaPagamento': formaPagamento,
    };
  }

  factory Transacao.fromJson(Map<String, dynamic> json) {
    return Transacao(
      id: json['id'],
      titulo: json['titulo'],
      valor: json['valor'],
      isReceita: json['isReceita'],
      categoria: json['categoria'] ?? 'Outros',
      data: json['data'] != null ? DateTime.parse(json['data']) : DateTime.now(),
      formaPagamento: json['formaPagamento'] ?? 'Pix/Dinheiro', 
    );
  }
}
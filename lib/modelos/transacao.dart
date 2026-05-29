class Transacao {
  final String id;
  final String titulo;
  final double valor;
  final bool isReceita;
  final String categoria;
  final DateTime data;
  final String formaPagamento;
  final bool statusPago;

  Transacao({
    required this.id,
    required this.titulo,
    required this.valor,
    required this.isReceita,
    required this.categoria,
    required this.data,
    required this.formaPagamento,
    this.statusPago = false, 
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'titulo': titulo,
    'valor': valor,
    'isReceita': isReceita,
    'categoria': categoria,
    'data': data.toIso8601String(),
    'formaPagamento': formaPagamento,
    'statusPago': statusPago, 
  };

  factory Transacao.fromJson(Map<String, dynamic> json) {
    return Transacao(
      id: json['id'] ?? '',
      titulo: json['titulo'] ?? 'Transação Antiga',
      valor: (json['valor'] as num?)?.toDouble() ?? 0.0,
      isReceita: json['isReceita'] ?? false,
      categoria: json['categoria'] ?? 'Outros',
      data: json['data'] != null ? DateTime.parse(json['data']) : DateTime.now(),
      formaPagamento: json['formaPagamento'] ?? 'Pix/Dinheiro',
      statusPago: json['statusPago'] ?? false, 
    );
  }
}
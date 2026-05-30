class AtivoModel {
  final String id;
  final String ticker;
  final String nome;
  final double quantidade;
  final double precoMedio;
  final String tipo;

  AtivoModel({
    required this.id,
    required this.ticker,
    required this.nome,
    required this.quantidade,
    required this.precoMedio,
    required this.tipo,
  });

  double get totalInvestido => quantidade * precoMedio;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ticker': ticker.toUpperCase().trim(),
      'nome': nome,
      'quantidade': quantidade,
      'precoMedio': precoMedio,
      'tipo': tipo,
    };
  }

  factory AtivoModel.fromMap(Map<String, dynamic> map) {
    return AtivoModel(
      id: map['id'] ?? '',
      ticker: map['ticker'] ?? '',
      nome: map['nome'] ?? '',
      quantidade: (map['quantidade'] as num).toDouble(),
      precoMedio: (map['precoMedio'] as num).toDouble(),
      tipo: map['tipo'] ?? 'Outros',
    );
  }
}
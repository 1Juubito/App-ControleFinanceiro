class MetaEconomia {
  String id;
  String titulo;
  double valorObjetivo;
  double valorAtual;
  String icone;

  MetaEconomia({
    required this.id,
    required this.titulo,
    required this.valorObjetivo,
    this.valorAtual = 0.0,
    this.icone = 'star_rounded',
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'titulo': titulo,
    'valorObjetivo': valorObjetivo,
    'valorAtual': valorAtual,
    'icone': icone,
  };

  factory MetaEconomia.fromJson(Map<String, dynamic> json) => MetaEconomia(
    id: json['id'],
    titulo: json['titulo'],
    valorObjetivo: json['valorObjetivo'],
    valorAtual: json['valorAtual'],
    icone: json['icone'] ?? 'star_rounded',
  );

  double get percentualConcluido {
    if (valorObjetivo <= 0) return 0.0;
    final percentual = valorAtual / valorObjetivo;
    return percentual > 1.0 ? 1.0 : percentual; 
  }
}
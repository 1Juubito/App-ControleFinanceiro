import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../modelos/transacao.dart';

class TelaRelatorios extends StatelessWidget {
  final List<Transacao> transacoes;
  final DateTime mesReferencia;

  const TelaRelatorios({super.key, required this.transacoes, required this.mesReferencia});

  @override
  Widget build(BuildContext context) {
    final _formatador = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final _nomesMeses = ['Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho', 'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'];
    
    final despesas = transacoes.where((t) => !t.isReceita).toList();
    final totalGasto = despesas.fold(0.0, (soma, t) => soma + t.valor);

    Map<String, double> agrupado = {};
    for (var t in despesas) { agrupado[t.categoria] = (agrupado[t.categoria] ?? 0.0) + t.valor; }

    final List<Color> cores = [
      Colors.indigo[400]!, Colors.pink[400]!, Colors.teal[400]!,
      Colors.orange[400]!, Colors.purple[400]!, Colors.green[400]!,
      Colors.red[400]!, Colors.blue[400]!, Colors.amber[400]!,
    ];

    int corIndex = 0;
    List<PieChartSectionData> secoes = [];
    final listaOrdenada = agrupado.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    if (totalGasto > 0) {
      for (var entry in listaOrdenada) {
        final percentual = entry.value / totalGasto;
        secoes.add(
          PieChartSectionData(
            color: cores[corIndex % cores.length],
            value: entry.value,
            title: '${(percentual * 100).toStringAsFixed(0)}%',
            radius: 50,
            titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
          )
        );
        corIndex++;
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('Relatório de ${_nomesMeses[mesReferencia.month - 1]}', style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: true,
      ),
      body: totalGasto == 0 
        ? const Center(child: Text('Nenhuma despesa neste mês.'))
        : Column(
            children: [
              const SizedBox(height: 32),
              SizedBox(
                height: 220,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 65,
                        sections: secoes,
                        borderData: FlBorderData(show: false),
                      ),
                      swapAnimationDuration: const Duration(milliseconds: 800),
                      swapAnimationCurve: Curves.easeOutQuint,
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Total Gasto', style: TextStyle(fontSize: 14, color: Colors.grey[500], fontWeight: FontWeight.w600)),
                        Text(_formatador.format(totalGasto), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
                  ),
                  child: ListView.builder(
                    itemCount: listaOrdenada.length,
                    itemBuilder: (context, index) {
                      final entry = listaOrdenada[index];
                      final percentual = entry.value / totalGasto;
                      final cor = cores[index % cores.length];

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 20.0),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(color: cor.withOpacity(0.1), shape: BoxShape.circle),
                              child: Icon(Icons.category_rounded, color: cor, size: 20),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(entry.key, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                      Text(_formatador.format(entry.value), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(4),
                                          child: LinearProgressIndicator(
                                            value: percentual,
                                            backgroundColor: Colors.grey[100],
                                            valueColor: AlwaysStoppedAnimation<Color>(cor),
                                            minHeight: 6,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text('${(percentual * 100).toStringAsFixed(1)}%', style: TextStyle(color: Colors.grey[500], fontSize: 12, fontWeight: FontWeight.bold)),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              )
            ],
          ),
    );
  }
}
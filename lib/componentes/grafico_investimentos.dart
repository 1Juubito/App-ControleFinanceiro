import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../modelos/ativo_model.dart';

class GraficoInvestimentos extends StatefulWidget {
  final double patrimonioTotal;
  final List<AtivoModel> listaAtivos;

  const GraficoInvestimentos({
    super.key,
    required this.patrimonioTotal,
    required this.listaAtivos,
  });

  @override
  State<GraficoInvestimentos> createState() => _GraficoInvestimentosState();
}

class _GraficoInvestimentosState extends State<GraficoInvestimentos> {
  int _indiceTocado = -1;
  final NumberFormat _formatador = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 280,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Patrimônio Total',
                style: TextStyle(
                  color: Colors.green[200], 
                  fontSize: 13,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _formatador.format(widget.patrimonioTotal),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          if (widget.listaAtivos.isNotEmpty)
            PieChart(
              PieChartData(
                pieTouchData: PieTouchData(
                  touchCallback: (FlTouchEvent event, pieTouchResponse) {
                    setState(() {
                      if (!event.isInterestedForInteractions ||
                          pieTouchResponse == null ||
                          pieTouchResponse.touchedSection == null) {
                        _indiceTocado = -1;
                        return;
                      }
                      _indiceTocado = pieTouchResponse.touchedSection!.touchedSectionIndex;
                    });
                  },
                ),
                borderData: FlBorderData(show: false),
                sectionsSpace: 4,
                centerSpaceRadius: 85,
                sections: _gerarSecoesReais(),
              ),
            ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _gerarSecoesReais() {
    final List<Color> coresPaleta = [
      Colors.blueAccent,
      Colors.greenAccent,
      Colors.amberAccent,
      Colors.deepPurpleAccent,
      Colors.redAccent,
    ];

    return List.generate(widget.listaAtivos.length, (i) {
      final ativo = widget.listaAtivos[i];
      final isTocado = i == _indiceTocado;
      
      final double percentual = widget.patrimonioTotal > 0 
          ? (ativo.totalInvestido / widget.patrimonioTotal) * 100 
          : 0;

      final double fontSize = isTocado ? 16.0 : 12.0;
      final double radius = isTocado ? 45.0 : 30.0; 
      final cor = coresPaleta[i % coresPaleta.length];

      return PieChartSectionData(
        color: cor,
        value: percentual,
        title: isTocado ? '${ativo.ticker}\n${percentual.toStringAsFixed(1)}%' : ativo.ticker,
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: const [Shadow(color: Colors.black45, blurRadius: 4)],
        ),
      );
    });
  }
}
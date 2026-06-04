import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'tela_cadastro.dart';
import 'tela_metas.dart';
import 'tela_relatorios.dart';
import '../modelos/transacao.dart';
import '../servicos/notificacao_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TelaInicial extends StatefulWidget {
  const TelaInicial({super.key});

  @override
  State<TelaInicial> createState() => _TelaInicialState();
}

class _TelaInicialState extends State<TelaInicial> {
  List<Transacao> _transacoesGlobais = [];
  final NumberFormat _formatador = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
  
  String _termoBusca = '';
  String _filtroStatus = 'Todos';
  
  DateTime _mesAtual = DateTime.now();
  final List<String> _nomesMeses = ['Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho', 'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'];

  bool _menuAberto = false;

  final Map<String, IconData> _iconesCategoria = {
    'Alimentação': Icons.restaurant_menu_rounded,
    'Restaurante': Icons.restaurant_rounded,
    'Lanche': Icons.fastfood_rounded,
    'Padaria': Icons.cake_rounded,
    'Supermercado': Icons.local_grocery_store_rounded,
    'Transporte': Icons.directions_car_rounded,
    'Moradia': Icons.home_rounded,
    'Saúde': Icons.medical_services_rounded,
    'Lazer': Icons.theater_comedy_rounded,
    'Jogos': Icons.sports_esports_rounded,
    'Compras Online': Icons.shopping_bag_rounded,
    'Assinaturas': Icons.subscriptions_rounded,
    'Educação': Icons.school_rounded,
    'Cuidados Pessoais': Icons.content_cut_rounded,
    'Salário': Icons.work_rounded,
    'Investimentos': Icons.monetization_on_rounded,
    'Freelance': Icons.laptop_mac_rounded,
    'Crédito Vale': Icons.fastfood_rounded,
    'Outros': Icons.category_rounded,
  };

  IconData _iconeNuvem = Icons.cloud_done_rounded;
  Color _corNuvem = Colors.greenAccent;

  void _piscarNuvemSincronizacao() async {
    setState(() {
      _iconeNuvem = Icons.cloud_sync_rounded; 
      _corNuvem = Colors.white70;
    });
    
    await Future.delayed(const Duration(milliseconds: 1500));
    
    setState(() {
      _iconeNuvem = Icons.cloud_done_rounded; 
      _corNuvem = Colors.greenAccent;
    });
  }

  @override
  void initState() {
    super.initState();
    _carregarDados();
    NotificacaoService().inicializar();
  }

  void _carregarDados() async {
    final box = Hive.box('cofre_financeiro');
    final dados = box.get('transacoes_salvas');
    
    if (dados != null && (dados as List).isNotEmpty) {
      setState(() {
        _transacoesGlobais = dados.map((item) {
          final mapaConvertido = Map<String, dynamic>.from(item);
          return Transacao.fromJson(mapaConvertido);
        }).toList();
      });
    } else {
      debugPrint("Hive vazio ou recém-instalado. Buscando backup no Firebase...");
      
      try {
        final snapshot = await FirebaseFirestore.instance.collection('transacoes').get();
        
        if (snapshot.docs.isNotEmpty) {
          List<Transacao> transacoesRecuperadas = [];
          
          for (var doc in snapshot.docs) {
            final dadosNuvem = doc.data();
            
            if (dadosNuvem['data'] != null) {
              if (dadosNuvem['data'].runtimeType.toString().contains('Timestamp')) {
                 DateTime dataConvertida = dadosNuvem['data'].toDate();
                 dadosNuvem['data'] = dataConvertida.toIso8601String();
              } else if (dadosNuvem['data'] is DateTime) {
                 dadosNuvem['data'] = (dadosNuvem['data'] as DateTime).toIso8601String();
              }
            }
            
            transacoesRecuperadas.add(Transacao.fromJson(dadosNuvem));
          }
          
          setState(() {
            _transacoesGlobais = transacoesRecuperadas;
          });
          
          _salvarDados(); 
          debugPrint("Backup do Firebase restaurado com sucesso no Hive!");
        } else {
           debugPrint("Nenhuma transação encontrada no Firebase também.");
        }
      } catch (e) {
        debugPrint("Erro crítico ao buscar dados no Firebase: $e");
      }
    }
  }

  void _salvarDados() {
    final box = Hive.box('cofre_financeiro');
    final dadosNativos = _transacoesGlobais.map((t) => t.toJson()).toList();
    box.put('transacoes_salvas', dadosNativos);
  }

  List<Transacao> get _transacoesDoMes {
    return _transacoesGlobais.where((t) {
      return t.data.year == _mesAtual.year && t.data.month == _mesAtual.month;
    }).toList();
  }

  bool _isEfetivada(Transacao t) {
    if (t.statusPago) return true;
    
    final hoje = DateTime.now();
    final dataT = DateTime(t.data.year, t.data.month, t.data.day);
    final dataH = DateTime(hoje.year, hoje.month, hoje.day);
    return !dataT.isAfter(dataH);
  }

  double get _saldoConta {
    final receitasGlobais = _transacoesGlobais.where((t) => t.isReceita && t.formaPagamento != 'Vale Alimentação' && _isEfetivada(t)).fold(0.0, (s, t) => s + t.valor);
    final despesasGlobais = _transacoesGlobais.where((t) => !t.isReceita && t.formaPagamento != 'Cartão de Crédito' && t.formaPagamento != 'Vale Alimentação' && _isEfetivada(t)).fold(0.0, (s, t) => s + t.valor);
    return receitasGlobais - despesasGlobais;
  }
  
  double get _saldoVale => _transacoesGlobais.where((t) => t.formaPagamento == 'Vale Alimentação' && _isEfetivada(t)).fold(0.0, (s, t) => s + (t.isReceita ? t.valor : -t.valor));

  double get _totalReceitasMes => _transacoesDoMes.where((t) => t.isReceita && t.formaPagamento != 'Vale Alimentação' && _isEfetivada(t)).fold(0.0, (s, t) => s + t.valor);
  double get _totalCartaoMes => _transacoesDoMes.where((t) => !t.isReceita && t.formaPagamento == 'Cartão de Crédito').fold(0.0, (s, t) => s + t.valor);
  double get _totalDespesasGeralMes => _transacoesDoMes.where((t) => !t.isReceita).fold(0.0, (s, t) => s + t.valor);

  void _mudarMes(int incremento) {
    setState(() {
      _mesAtual = DateTime(_mesAtual.year, _mesAtual.month + incremento, 1);
      _termoBusca = '';
      _filtroStatus = 'Todos'; 
    });
  }

  void _encaminharParaCadastro({bool? iniciarComoReceita, String? formaPagamento}) async {
    setState(() { _menuAberto = false; }); 
    
    final transacaoRecebida = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TelaCadastro(iniciarComoReceita: iniciarComoReceita, iniciarFormaPagamento: formaPagamento),
      ),
    );

if (transacaoRecebida != null) {
      final novasTransacoes = transacaoRecebida is List 
          ? transacaoRecebida as Iterable<Transacao> 
          : [transacaoRecebida as Transacao];

      setState(() {
        _transacoesGlobais.addAll(novasTransacoes);
        _salvarDados();
      });

      for (var transacao in novasTransacoes) {
        NotificacaoService().agendarNotificacao(transacao);
      }
      _piscarNuvemSincronizacao();
    }
  }

  Widget _buildMiniFabCirculo({required String titulo, required IconData icone, required Color cor, required VoidCallback onTap}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: cor.withOpacity(0.3), blurRadius: 12, spreadRadius: 1)],
          ),
          child: Material(
            color: const Color(0xFF1A1A1A),
            shape: CircleBorder(side: BorderSide(color: cor.withOpacity(0.8), width: 1.5)),
            child: InkWell(
              onTap: onTap,
              customBorder: const CircleBorder(),
              splashColor: cor.withOpacity(0.3),
              child: Padding(
                padding: const EdgeInsets.all(14.0), 
                child: Icon(icone, color: cor, size: 24),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(titulo, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
      ],
    );
  }

  Widget _buildCardMetas() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: BorderSide(color: Colors.grey[200]!)),
      child: InkWell(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const TelaMetas()));
        },
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.blue[50], shape: BoxShape.circle),
                    child: Icon(Icons.savings_rounded, color: Colors.blue[700], size: 24),
                  ),
                  const SizedBox(width: 16),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Meus Cofrinhos', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
                      SizedBox(height: 2),
                      Text('Acompanhe suas metas', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ],
              ),
              Icon(Icons.chevron_right_rounded, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardGrafico(List<Transacao> transacoesDoMes) {
    final despesas = transacoesDoMes.where((t) => !t.isReceita).toList();
    final totalGasto = despesas.fold(0.0, (soma, t) => soma + t.valor);
    
    if (totalGasto == 0) return const SizedBox.shrink();

    Map<String, double> agrupado = {};
    for (var t in despesas) { agrupado[t.categoria] = (agrupado[t.categoria] ?? 0.0) + t.valor; }

    final List<Color> cores = [
      Colors.indigo[400]!, Colors.pink[400]!, Colors.teal[400]!,
      Colors.orange[400]!, Colors.purple[400]!, Colors.green[400]!,
      Colors.red[400]!, Colors.blue[400]!, Colors.amber[400]!,
    ];

    int corIndex = 0;
    List<PieChartSectionData> secoes = [];
    List<Widget> legendas = [];

    final listaOrdenada = agrupado.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    for (var entry in listaOrdenada) {
      final percentual = entry.value / totalGasto;
      final cor = cores[corIndex % cores.length];

      secoes.add(
        PieChartSectionData(
          color: cor,
          value: entry.value,
          title: '${(percentual * 100).toStringAsFixed(0)}%',
          radius: 35, 
          titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
        )
      );

      legendas.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            children: [
              Container(width: 10, height: 10, decoration: BoxDecoration(color: cor, shape: BoxShape.circle)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  entry.key, 
                  style: TextStyle(fontSize: 12, color: Colors.grey[700], fontWeight: FontWeight.w600),
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        )
      );
      corIndex++;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: BorderSide(color: Colors.grey[200]!)),
      child: InkWell(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => TelaRelatorios(transacoes: transacoesDoMes, mesReferencia: _mesAtual)));
        },
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.donut_large_rounded, color: Colors.indigo[400], size: 20),
                      const SizedBox(width: 8),
                      Text('Análise de Despesas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey[800])),
                    ],
                  ),
                  Icon(Icons.chevron_right_rounded, color: Colors.grey[400]),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  SizedBox(
                    height: 150,
                    width: 150,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        PieChart(
                          PieChartData(
                            sectionsSpace: 2,
                            centerSpaceRadius: 45, 
                            sections: secoes,
                            borderData: FlBorderData(show: false),
                          ),
                          swapAnimationDuration: const Duration(milliseconds: 800), 
                          swapAnimationCurve: Curves.easeOutQuint,
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Total', style: TextStyle(fontSize: 11, color: Colors.grey[500], fontWeight: FontWeight.w600)),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(_formatador.format(totalGasto), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: legendas,
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardLancamentos() {
    var listaFiltrada = _transacoesDoMes.where((t) {
      if (_termoBusca.isNotEmpty && !t.titulo.toLowerCase().contains(_termoBusca)) {
        return false;
      }
      if (_filtroStatus == 'Pendentes' && t.statusPago) return false;
      if (_filtroStatus == 'Pagos' && !t.statusPago) return false;

      return true;
    }).toList();

    listaFiltrada.sort((a, b) => b.data.compareTo(a.data));

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: BorderSide(color: Colors.grey[200]!)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8.0, bottom: 12, top: 4),
              child: Row(
                children: [
                  Icon(Icons.receipt_long_rounded, color: Colors.green[800], size: 20),
                  const SizedBox(width: 8),
                  Text('Fluxo de Caixa', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey[800])),
                ],
              ),
            ),
            if (listaFiltrada.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(
                  child: Text('Nenhum lançamento encontrado.', style: TextStyle(color: Colors.grey, fontSize: 14)),
                ),
              )
            else
              ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true, 
                physics: const NeverScrollableScrollPhysics(), 
                itemCount: listaFiltrada.length,
                itemBuilder: (context, index) {
                  final transacao = listaFiltrada[index];
                  final bool isAgendado = !_isEfetivada(transacao);
                  
                  Color corValor = transacao.isReceita ? Colors.green[600]! : Colors.red[600]!;
                  if (transacao.formaPagamento == 'Vale Alimentação') corValor = Colors.orange[700]!;
                  if (isAgendado) corValor = Colors.orange[700]!;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Slidable(
                      key: Key(transacao.id),
                      
                      endActionPane: ActionPane(
                        motion: const StretchMotion(),
                        extentRatio: 0.22,
                        children: [
                          SlidableAction(
                            onPressed: (context) {
                              FirebaseFirestore.instance.collection('transacoes').doc(transacao.id).delete();

                              setState(() {
                                _transacoesGlobais.removeWhere((t) => t.id == transacao.id);
                                _salvarDados();
                              });
                              _piscarNuvemSincronizacao();
                            },
                            backgroundColor: Colors.red[600]!,
                            foregroundColor: Colors.white,
                            icon: Icons.delete_sweep_rounded,
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ],
                      ),

                      startActionPane: isAgendado
                          ? ActionPane(
                              motion: const StretchMotion(),
                              extentRatio: 0.22,
                              children: [
                                SlidableAction(
                                  onPressed: (context) {
                                    setState(() {
                                      final indexOriginal = _transacoesGlobais.indexWhere((t) => t.id == transacao.id);
                                      if (indexOriginal != -1) {
                                        _transacoesGlobais[indexOriginal] = Transacao(
                                          id: transacao.id,
                                          titulo: transacao.titulo,
                                          valor: transacao.valor,
                                          isReceita: transacao.isReceita,
                                          categoria: transacao.categoria,
                                          data: transacao.data,
                                          formaPagamento: transacao.formaPagamento,
                                          statusPago: true, 
                                        );
                                        _salvarDados();
                                      }
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                      content: Text(
                                        transacao.isReceita ? 'Recebimento antecipado efetuado! ✅' : 'Pagamento antecipado efetuado! ✅', 
                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                                      ), 
                                      backgroundColor: Colors.green[700], 
                                      behavior: SnackBarBehavior.floating,
                                    ));
                                  },
                                  backgroundColor: Colors.green[600]!,
                                  foregroundColor: Colors.white,
                                  icon: Icons.check_circle_rounded,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ],
                            )
                          : null,

                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () async {
                              final transacaoEditada = await Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => TelaCadastro(transacaoParaEdicao: transacao)),
                              );
                              if (transacaoEditada != null) {
                                setState(() {
                                  final indexOriginal = _transacoesGlobais.indexWhere((t) => t.id == transacaoEditada.id);
                                  if (indexOriginal != -1) {
                                    _transacoesGlobais[indexOriginal] = transacaoEditada;
                                    _salvarDados();
                                  }
                                });
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: transacao.formaPagamento == 'Vale Alimentação' ? Colors.orange[50] : (transacao.isReceita ? Colors.green[50] : Colors.red[50]),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      transacao.formaPagamento == 'Vale Alimentação' ? Icons.fastfood_rounded : (_iconesCategoria[transacao.categoria] ?? Icons.category_rounded), 
                                      color: transacao.formaPagamento == 'Vale Alimentação' ? Colors.orange[700] : (transacao.isReceita ? Colors.green[700] : Colors.red[700]),
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 12),

                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(transacao.titulo, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 14)),
                                        const SizedBox(height: 4),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Flexible(
                                              child: Text(
                                                '${transacao.categoria} • ${DateFormat('dd/MM').format(transacao.data)}', 
                                                style: TextStyle(color: Colors.grey[500], fontSize: 11, fontWeight: FontWeight.w500),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            if (transacao.formaPagamento == 'Vale Alimentação')
                                              Padding(
                                                padding: const EdgeInsets.only(left: 4.0),
                                                child: Icon(Icons.fastfood, size: 11, color: Colors.orange[700]),
                                              ),
                                            if (!transacao.isReceita && transacao.formaPagamento == 'Cartão de Crédito')
                                              Padding(
                                                padding: const EdgeInsets.only(left: 4.0),
                                                child: Icon(Icons.credit_card_rounded, size: 11, color: Colors.blue[700]),
                                              ),
                                          ],
                                        ),
                                        if (isAgendado)
                                          Padding(
                                            padding: const EdgeInsets.only(top: 6.0),
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: Colors.orange[50], 
                                                borderRadius: BorderRadius.circular(6), 
                                                border: Border.all(color: Colors.orange[200]!)
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(Icons.schedule_rounded, size: 10, color: Colors.orange[700]),
                                                  const SizedBox(width: 4),
                                                  Text('AGENDADO', style: TextStyle(color: Colors.orange[700], fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                                                ],
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),

                                  ConstrainedBox(
                                    constraints: const BoxConstraints(maxWidth: 100), 
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        '${transacao.isReceita ? '+' : '-'} ${_formatador.format(transacao.valor)}',
                                        style: TextStyle(color: corValor, fontWeight: FontWeight.bold, fontSize: 14),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), 
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [const Color(0xFF111111), Colors.green[900]!, Colors.green[800]!],
                    ),
                    borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(32), bottomRight: Radius.circular(32)),
                  ),
                  padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      FittedBox(
                                        fit: BoxFit.scaleDown,
                                        alignment: Alignment.centerLeft,
                                        child: const Text(
                                          'Olá Allan', 
                                          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 0.5), 
                                        ),
                                      ),
                                      FittedBox(
                                        fit: BoxFit.scaleDown,
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          'Seu controle de gastos', 
                                          style: TextStyle(color: Colors.green[200], fontSize: 13), 
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 4),
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 400),
                                  transitionBuilder: (Widget child, Animation<double> animation) {
                                    return FadeTransition(opacity: animation, child: child);
                                  },
                                  child: Icon(
                                    _iconeNuvem,
                                    key: ValueKey<IconData>(_iconeNuvem), 
                                    color: _corNuvem,
                                    size: 24, 
                                  ),
                                ),
                                const SizedBox(width: 8),
                              ],
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6), 
                            child: Row(
                              children: [
                                IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(), 
                                  icon: const Icon(Icons.chevron_left, color: Colors.white, size: 22), 
                                  onPressed: () => _mudarMes(-1)
                                ),
                                
                                SizedBox(
                                  width: 70, 
                                  child: Center(
                                    child: Text(
                                      _nomesMeses[_mesAtual.month - 1], 
                                      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)
                                    ),
                                  ),
                                ),
                                
                                IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(), 
                                  icon: const Icon(Icons.chevron_right, color: Colors.white, size: 22), 
                                  onPressed: () => _mudarMes(1)
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white.withOpacity(0.15), width: 1.5)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.account_balance_wallet_rounded, size: 14, color: Colors.green[200]),
                                      const SizedBox(width: 6),
                                      const Text('Disponível', style: TextStyle(fontSize: 12, color: Colors.white70)),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(_formatador.format(_saldoConta), style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: _saldoConta >= 0 ? Colors.white : Colors.red[300])),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(color: Colors.white.withOpacity(0.07), borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white.withOpacity(0.1), width: 1.5)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.credit_card_rounded, size: 14, color: Colors.blue[200]),
                                      const SizedBox(width: 6),
                                      const Text('Fatura Aberta', style: TextStyle(fontSize: 12, color: Colors.white70)),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(_formatador.format(_totalCartaoMes), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Color(0xFFE65100), Color(0xFFE65100)]),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.orangeAccent.withOpacity(0.3), width: 1.5),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)]
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                                  child: const Icon(Icons.fastfood_rounded, color: Colors.white, size: 18),
                                ),
                                const SizedBox(width: 14),
                                const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Vale Alimentação', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                                    Text('Saldo de Benefício', style: TextStyle(color: Colors.white70, fontSize: 11)),
                                  ],
                                )
                              ],
                            ),
                            Text(_formatador.format(_saldoVale), style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      )
                    ],
                  ),
                ),

                _buildResumoDespesas(),

                Padding(
                  padding: const EdgeInsets.fromLTRB(28.0, 16.0, 28.0, 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.arrow_circle_up_rounded, color: Colors.green[600], size: 16),
                          const SizedBox(width: 4),
                          Text('Entradas: ${_formatador.format(_totalReceitasMes)}', style: TextStyle(color: Colors.grey[600], fontSize: 11, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(Icons.arrow_circle_down_rounded, color: Colors.red[400], size: 16),
                          const SizedBox(width: 4),
                          Text('Previsão Saídas: ${_formatador.format(_totalDespesasGeralMes)}', style: TextStyle(color: Colors.grey[600], fontSize: 11, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ),
                
                _buildCentroDeComando(),

                _buildCardMetas(),
                _buildCardLancamentos(),
                _buildCardGrafico(_transacoesDoMes),

                const SizedBox(height: 100), 
              ],
            ),
          ),

          if (_menuAberto)
            GestureDetector(
              onTap: () => setState(() { _menuAberto = false; }),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 6.0, sigmaY: 6.0),
                child: Container(color: Colors.black.withOpacity(0.3)),
              ),
            ),
        ],
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_menuAberto) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildMiniFabCirculo(titulo: 'Receita', icone: Icons.arrow_upward_rounded, cor: Colors.greenAccent[400]!, onTap: () => _encaminharParaCadastro(iniciarComoReceita: true)),
                const SizedBox(width: 24),
                _buildMiniFabCirculo(titulo: 'Cartão', icone: Icons.credit_card_rounded, cor: Colors.blueAccent[400]!, onTap: () => _encaminharParaCadastro(iniciarComoReceita: false, formaPagamento: 'Cartão de Crédito')),
                const SizedBox(width: 24),
                _buildMiniFabCirculo(titulo: 'À Vista', icone: Icons.arrow_downward_rounded, cor: Colors.redAccent[400]!, onTap: () => _encaminharParaCadastro(iniciarComoReceita: false, formaPagamento: 'Pix/Dinheiro')),
              ],
            ),
            const SizedBox(height: 24),
          ],
          FloatingActionButton(
            heroTag: 'btn_principal',
            onPressed: () => setState(() => _menuAberto = !_menuAberto),
            backgroundColor: _menuAberto ? Colors.red[600] : const Color(0xFF111111),
            child: AnimatedRotation(
              turns: _menuAberto ? 0.125 : 0, 
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutBack,
              child: const Icon(Icons.add_rounded, color: Colors.white, size: 36),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildResumoDespesas() {
    double totalDespesas = 0;
    double totalPago = 0;

    for (var t in _transacoesGlobais) {
      if (!t.isReceita && t.data.month == _mesAtual.month && t.data.year == _mesAtual.year) {
        totalDespesas += t.valor;
        if (t.statusPago) {
          totalPago += t.valor;
        }
      }
    }

    double totalPendente = totalDespesas - totalPago;
    double progresso = totalDespesas > 0 ? (totalPago / totalDespesas) : 0.0;

    if (totalDespesas == 0) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Status das Despesas',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 16),
            
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progresso,
                minHeight: 12,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(
                  progresso == 1.0 ? Colors.green : Colors.orange,
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Já pago', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                    Text(
                      _formatador.format(totalPago),
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Falta pagar', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                    Text(
                      _formatador.format(totalPendente),
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.orange),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCentroDeComando() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        children: [
          TextField(
            onChanged: (valor) {
              setState(() {
                _termoBusca = valor.toLowerCase();
              });
            },
            decoration: InputDecoration(
              hintText: 'Pesquisar lançamento...',
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildChipStatus('Todos'),
              _buildChipStatus('Pendentes'),
              _buildChipStatus('Pagos'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChipStatus(String titulo) {
    final isSelecionado = _filtroStatus == titulo;
    return ChoiceChip(
      label: Text(
        titulo,
        style: TextStyle(
          color: isSelecionado ? Colors.white : Colors.grey[700],
          fontWeight: isSelecionado ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelecionado,
      selectedColor: Colors.black87,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: isSelecionado ? Colors.transparent : Colors.grey[300]!),
      ),
      onSelected: (bool selecionado) {
        if (selecionado) {
          setState(() {
            _filtroStatus = titulo;
          });
        }
      },
    );
  }
}
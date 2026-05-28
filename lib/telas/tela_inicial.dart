import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'tela_cadastro.dart';
import '../modelos/transacao.dart';

class TelaInicial extends StatefulWidget {
  const TelaInicial({super.key});

  @override
  State<TelaInicial> createState() => _TelaInicialState();
}

class _TelaInicialState extends State<TelaInicial> {
  List<Transacao> _transacoesGlobais = [];
  final NumberFormat _formatador = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
  String _filtroCategoriaAtivo = 'Todas';
  
  DateTime _mesAtual = DateTime.now();
  final List<String> _nomesMeses = ['Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho', 'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'];

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    final prefs = await SharedPreferences.getInstance();
    final dadosString = prefs.getString('transacoes_salvas');
    if (dadosString != null) {
      final List<dynamic> dadosDecodificados = jsonDecode(dadosString);
      setState(() {
        _transacoesGlobais = dadosDecodificados.map((item) => Transacao.fromJson(item)).toList();
      });
    }
  }

  Future<void> _salvarDados() async {
    final prefs = await SharedPreferences.getInstance();
    final dadosString = jsonEncode(_transacoesGlobais.map((t) => t.toJson()).toList());
    await prefs.setString('transacoes_salvas', dadosString);
  }

  List<Transacao> get _transacoesDoMes {
    return _transacoesGlobais.where((t) {
      return t.data.year == _mesAtual.year && t.data.month == _mesAtual.month;
    }).toList();
  }

  bool _isEfetivada(DateTime dataTransacao) {
    final hoje = DateTime.now();
    final dataT = DateTime(dataTransacao.year, dataTransacao.month, dataTransacao.day);
    final dataH = DateTime(hoje.year, hoje.month, hoje.day);
    return !dataT.isAfter(dataH);
  }

  double get _totalReceitas => _transacoesDoMes
      .where((t) => t.isReceita && _isEfetivada(t.data))
      .fold(0.0, (s, t) => s + t.valor);
  
  double get _totalDespesasAVista => _transacoesDoMes
      .where((t) => !t.isReceita && t.formaPagamento != 'Cartão de Crédito' && _isEfetivada(t.data))
      .fold(0.0, (s, t) => s + t.valor);
  
  double get _totalCartao => _transacoesDoMes
      .where((t) => !t.isReceita && t.formaPagamento == 'Cartão de Crédito')
      .fold(0.0, (s, t) => s + t.valor);
  
  double get _saldoConta => _totalReceitas - _totalDespesasAVista;
  
  double get _totalDespesasGeral => _transacoesDoMes.where((t) => !t.isReceita).fold(0.0, (s, t) => s + t.valor);

  void _mudarMes(int incremento) {
    setState(() {
      _mesAtual = DateTime(_mesAtual.year, _mesAtual.month + incremento, 1);
      _filtroCategoriaAtivo = 'Todas'; 
    });
  }

  IconData _getIconeCategoria(String categoria) {
    switch (categoria) {
      case 'Alimentação': return Icons.restaurant;
      case 'Transporte': return Icons.directions_car;
      case 'Moradia': return Icons.home;
      case 'Saúde': return Icons.medical_services;
      case 'Lazer': return Icons.sports_esports;
      case 'Cuidados Pessoais': return Icons.content_cut;
      case 'Salário': return Icons.work;
      case 'Investimentos': return Icons.monetization_on;
      case 'Freelance': return Icons.laptop_mac;
      default: return Icons.category;
    }
  }

  Widget _buildGraficoResumo(List<Transacao> despesas) {
    final totalGasto = despesas.fold(0.0, (soma, t) => soma + t.valor);
    if (totalGasto == 0) return const SizedBox.shrink();

    Map<String, double> agrupado = {};
    for (var t in despesas) { agrupado[t.categoria] = (agrupado[t.categoria] ?? 0.0) + t.valor; }

    return Card(
      margin: const EdgeInsets.only(bottom: 16.0, top: 8.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Divisão de Gastos do Mês', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87)),
            const SizedBox(height: 12),
            ...agrupado.entries.map((entry) {
              final percentual = entry.value / totalGasto;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(entry.key, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                        Text('${(percentual * 100).toStringAsFixed(1)}% (${_formatador.format(entry.value)})', style: TextStyle(fontSize: 12, color: Colors.grey[700])),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(value: percentual, backgroundColor: Colors.grey[200], color: Colors.red[400], minHeight: 6, borderRadius: BorderRadius.circular(3)),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildListaTransacoes(List<Transacao> transacoesDaAba, {bool mostrarGrafico = false}) {
    final listaFinal = _filtroCategoriaAtivo == 'Todas' 
        ? transacoesDaAba 
        : transacoesDaAba.where((t) => t.categoria == _filtroCategoriaAtivo).toList();

    listaFinal.sort((a, b) => b.data.compareTo(a.data));
    final bool temGrafico = mostrarGrafico && transacoesDaAba.isNotEmpty;

    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: ['Todas', 'Alimentação', 'Transporte', 'Moradia', 'Saúde', 'Lazer', 'Cuidados Pessoais', 'Salário', 'Investimentos', 'Freelance', 'Outros'].map((categoria) {
              final isSelecionado = _filtroCategoriaAtivo == categoria;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: FilterChip(
                  label: Text(categoria),
                  selected: isSelecionado,
                  selectedColor: Colors.green[100],
                  checkmarkColor: Colors.green[700],
                  onSelected: (selecionado) { setState(() { _filtroCategoriaAtivo = selecionado ? categoria : 'Todas'; }); },
                ),
              );
            }).toList(),
          ),
        ),
        
        Expanded(
          child: (listaFinal.isEmpty && !temGrafico)
              ? const Center(child: Text('Nenhuma transação neste mês.', style: TextStyle(color: Colors.grey)))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  itemCount: listaFinal.length + (temGrafico ? 1 : 0),
                  itemBuilder: (context, index) {
                    
                    if (temGrafico && index == 0) return _buildGraficoResumo(transacoesDaAba);

                    final transacao = listaFinal[temGrafico ? index - 1 : index];
                    
                    final bool isAgendado = !_isEfetivada(transacao.data);
                    
                    Color corValor = transacao.isReceita ? Colors.green : Colors.red;
                    if (isAgendado) corValor = Colors.orange;

                    return Dismissible(
                      key: Key(transacao.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(12)),
                        child: const Icon(Icons.delete, color: Colors.white, size: 30),
                      ),
                      onDismissed: (direction) {
                        setState(() {
                          _transacoesGlobais.removeWhere((t) => t.id == transacao.id);
                          _salvarDados();
                        });
                      },
                      child: Card(
                        elevation: 1,
                        margin: const EdgeInsets.only(bottom: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: isAgendado ? Colors.orange[50] : (transacao.isReceita ? Colors.green[100] : Colors.red[100]),
                            child: Icon(_getIconeCategoria(transacao.categoria), color: isAgendado ? Colors.orange : (transacao.isReceita ? Colors.green : Colors.red)),
                          ),
                          title: Text(transacao.titulo, style: const TextStyle(fontWeight: FontWeight.w500)),
                          subtitle: Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 6.0,
                            children: [
                              Text('${transacao.categoria} • ${DateFormat('dd/MM').format(transacao.data)}', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                              
                              if (!transacao.isReceita && transacao.formaPagamento == 'Cartão de Crédito')
                                const Icon(Icons.credit_card, size: 14, color: Colors.blue),
                              
                              if (isAgendado) 
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.schedule, size: 14, color: Colors.orange),
                                    const SizedBox(width: 2),
                                    const Text('Agendado', style: TextStyle(color: Colors.orange, fontSize: 10, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                            ],
                          ),
                          trailing: Text(
                            '${transacao.isReceita ? '+' : '-'} ${_formatador.format(transacao.valor)}',
                            style: TextStyle(color: corValor, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
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
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Visão Geral', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            color: Colors.green[700], 
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(icon: const Icon(Icons.chevron_left, color: Colors.white, size: 30), onPressed: () => _mudarMes(-1)),
                SizedBox(
                  width: 150, 
                  child: Text(
                    '${_nomesMeses[_mesAtual.month - 1]} ${_mesAtual.year}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(icon: const Icon(Icons.chevron_right, color: Colors.white, size: 30), onPressed: () => _mudarMes(1)),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
            child: Row(
              children: [
                Expanded(
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Saldo em Conta', style: TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w500)),
                          const SizedBox(height: 8),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              _formatador.format(_saldoConta), 
                              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: _saldoConta >= 0 ? Colors.black87 : Colors.red),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                
                Expanded(
                  child: Card(
                    color: Colors.blue[600],
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Fatura Aberta', style: TextStyle(fontSize: 13, color: Colors.white70, fontWeight: FontWeight.w500)),
                          const SizedBox(height: 8),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              _formatador.format(_totalCartao), 
                              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.arrow_upward, color: Colors.green, size: 16),
                    const SizedBox(width: 4),
                    Text('Entradas: ${_formatador.format(_totalReceitas)}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.arrow_downward, color: Colors.red, size: 16),
                    const SizedBox(width: 4),
                    Text('Saídas Previstas: ${_formatador.format(_totalDespesasGeral)}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
          
          Expanded(
            child: DefaultTabController(
              length: 3, 
              child: Column(
                children: [
                  TabBar(
                    labelColor: Colors.green, unselectedLabelColor: Colors.grey, indicatorColor: Colors.green,
                    onTap: (index) => setState(() { _filtroCategoriaAtivo = 'Todas'; }),
                    tabs: const [Tab(text: 'Todas'), Tab(text: 'Receitas'), Tab(text: 'Despesas')],
                  ),
                  Expanded(
                    child: TabBarView(
                      physics: const NeverScrollableScrollPhysics(), 
                      children: [
                        _buildListaTransacoes(_transacoesDoMes), 
                        _buildListaTransacoes(_transacoesDoMes.where((t) => t.isReceita).toList()), 
                        _buildListaTransacoes(_transacoesDoMes.where((t) => !t.isReceita).toList(), mostrarGrafico: true), 
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final transacaoRecebida = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TelaCadastro()),
          );
          if (transacaoRecebida != null) {
            setState(() {
              _transacoesGlobais.addAll(transacaoRecebida is List ? transacaoRecebida as Iterable<Transacao> : [transacaoRecebida as Transacao]);
              _salvarDados();
            });
          }
        },
        backgroundColor: Colors.green[700],
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
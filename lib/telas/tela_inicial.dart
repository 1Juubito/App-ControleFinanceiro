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

  double get _totalReceitas => _transacoesDoMes.where((t) => t.isReceita).fold(0.0, (s, t) => s + t.valor);
  double get _totalDespesas => _transacoesDoMes.where((t) => !t.isReceita).fold(0.0, (s, t) => s + t.valor);
  double get _saldoTotal => _totalReceitas - _totalDespesas;

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
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
        
        if (mostrarGrafico && transacoesDaAba.isNotEmpty) _buildGraficoResumo(transacoesDaAba),

        Expanded(
          child: listaFinal.isEmpty
              ? const Center(child: Text('Nenhuma transação neste mês.', style: TextStyle(color: Colors.grey)))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  itemCount: listaFinal.length,
                  itemBuilder: (context, index) {
                    final transacao = listaFinal[index];

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
                            backgroundColor: transacao.isReceita ? Colors.green[100] : Colors.red[100],
                            child: Icon(_getIconeCategoria(transacao.categoria), color: transacao.isReceita ? Colors.green : Colors.red),
                          ),
                          title: Text(transacao.titulo, style: const TextStyle(fontWeight: FontWeight.w500)),
                          subtitle: Text('${transacao.categoria} • ${DateFormat('dd/MM').format(transacao.data)}', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                          trailing: Text(
                            '${transacao.isReceita ? '+' : '-'} ${_formatador.format(transacao.valor)}',
                            style: TextStyle(color: transacao.isReceita ? Colors.green : Colors.red, fontWeight: FontWeight.bold, fontSize: 16),
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
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Saldo do Mês', style: TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    Text(
                      _formatador.format(_saldoTotal), 
                      style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: _saldoTotal >= 0 ? Colors.black87 : Colors.red)
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.arrow_upward, color: Colors.green, size: 20)),
                            const SizedBox(width: 12),
                            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              const Text('Receitas', style: TextStyle(color: Colors.grey, fontSize: 14)),
                              Text(_formatador.format(_totalReceitas), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                            ]),
                          ],
                        ),
                        Row(
                          children: [
                            Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.arrow_downward, color: Colors.red, size: 20)),
                            const SizedBox(width: 12),
                            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              const Text('Despesas', style: TextStyle(color: Colors.grey, fontSize: 14)),
                              Text(_formatador.format(_totalDespesas), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                            ]),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
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
          final resultado = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TelaCadastro()),
          );
          if (resultado != null) {
            setState(() {
              if (resultado is List<Transacao>) {
                _transacoesGlobais.addAll(resultado);
              } else if (resultado is Transacao) {
                _transacoesGlobais.add(resultado);
              }
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
import 'dart:convert';
import 'dart:ui';
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

  bool _menuAberto = false;

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

  double get _saldoConta {
    final receitasGlobais = _transacoesGlobais.where((t) => t.isReceita && t.formaPagamento != 'Vale Alimentação' && _isEfetivada(t.data)).fold(0.0, (s, t) => s + t.valor);
    final despesasGlobais = _transacoesGlobais.where((t) => !t.isReceita && t.formaPagamento != 'Cartão de Crédito' && t.formaPagamento != 'Vale Alimentação' && _isEfetivada(t.data)).fold(0.0, (s, t) => s + t.valor);
    return receitasGlobais - despesasGlobais;
  }
  
  double get _saldoVale => _transacoesGlobais.where((t) => t.formaPagamento == 'Vale Alimentação').fold(0.0, (s, t) => s + (t.isReceita ? t.valor : -t.valor));

  double get _totalReceitasMes => _transacoesDoMes.where((t) => t.isReceita && t.formaPagamento != 'Vale Alimentação' && _isEfetivada(t.data)).fold(0.0, (s, t) => s + t.valor);
  double get _totalCartaoMes => _transacoesDoMes.where((t) => !t.isReceita && t.formaPagamento == 'Cartão de Crédito').fold(0.0, (s, t) => s + t.valor);
  double get _totalDespesasGeralMes => _transacoesDoMes.where((t) => !t.isReceita).fold(0.0, (s, t) => s + t.valor);

  void _mudarMes(int incremento) {
    setState(() {
      _mesAtual = DateTime(_mesAtual.year, _mesAtual.month + incremento, 1);
      _filtroCategoriaAtivo = 'Todas'; 
    });
  }

  IconData _getIconeCategoria(String categoria) {
    switch (categoria) {
      case 'Alimentação': return Icons.restaurant_rounded;
      case 'Transporte': return Icons.directions_car_rounded;
      case 'Moradia': return Icons.home_rounded;
      case 'Saúde': return Icons.medical_services_rounded;
      case 'Lazer': return Icons.sports_esports_rounded;
      case 'Cuidados Pessoais': return Icons.content_cut_rounded;
      case 'Salário': return Icons.work_rounded;
      case 'Investimentos': return Icons.monetization_on_rounded;
      case 'Freelance': return Icons.laptop_mac_rounded;
      default: return Icons.category_rounded;
    }
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
      setState(() {
        _transacoesGlobais.addAll(transacaoRecebida is List ? transacaoRecebida as Iterable<Transacao> : [transacaoRecebida as Transacao]);
        _salvarDados();
      });
    }
  }

  Widget _buildBotaoMenuPremium({required String titulo, required IconData icone, required Color cor, required VoidCallback onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        splashColor: cor.withOpacity(0.3),
        child: Container(
          width: 230, 
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A), 
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: cor.withOpacity(0.6), width: 1.5), 
            boxShadow: [BoxShadow(color: cor.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 5))],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: cor.withOpacity(0.15), borderRadius: BorderRadius.circular(14)),
                child: Icon(icone, color: cor, size: 22),
              ),
              const SizedBox(width: 16),
              Text(titulo, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGraficoResumo(List<Transacao> despesas) {
    final totalGasto = despesas.fold(0.0, (soma, t) => soma + t.valor);
    if (totalGasto == 0) return const SizedBox.shrink();

    Map<String, double> agrupado = {};
    for (var t in despesas) { agrupado[t.categoria] = (agrupado[t.categoria] ?? 0.0) + t.valor; }

    return Card(
      margin: const EdgeInsets.only(bottom: 24.0, top: 8.0),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: BorderSide(color: Colors.grey[200]!)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Divisão de Gastos', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey[800])),
            const SizedBox(height: 16),
            ...agrupado.entries.map((entry) {
              final percentual = entry.value / totalGasto;
              return Padding(
                padding: const EdgeInsets.only(bottom: 14.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(entry.key, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                        Text('${(percentual * 100).toStringAsFixed(1)}% (${_formatador.format(entry.value)})', style: TextStyle(fontSize: 13, color: Colors.grey[600], fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    LinearProgressIndicator(value: percentual, backgroundColor: Colors.grey[100], color: Colors.red[400], minHeight: 8, borderRadius: BorderRadius.circular(4)),
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
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          child: Row(
            children: ['Todas', 'Alimentação', 'Transporte', 'Moradia', 'Saúde', 'Lazer', 'Cuidados Pessoais', 'Salário', 'Investimentos', 'Freelance', 'Outros'].map((categoria) {
              final isSelecionado = _filtroCategoriaAtivo == categoria;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: FilterChip(
                  label: Text(categoria),
                  selected: isSelecionado,
                  selectedColor: Colors.green[50],
                  labelStyle: TextStyle(color: isSelecionado ? Colors.green[800] : Colors.grey[700]),
                  checkmarkColor: Colors.green[700],
                  backgroundColor: Colors.white,
                  side: BorderSide(color: isSelecionado ? Colors.green[300]! : Colors.grey[200]!),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  onSelected: (selecionado) { setState(() { _filtroCategoriaAtivo = selecionado ? categoria : 'Todas'; }); },
                ),
              );
            }).toList(),
          ),
        ),
        
        Expanded(
          child: (listaFinal.isEmpty && !temGrafico)
              ? const Center(child: Text('Nenhum lançamento por aqui.', style: TextStyle(color: Colors.grey, fontSize: 15)))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  itemCount: listaFinal.length + (temGrafico ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (temGrafico && index == 0) return _buildGraficoResumo(transacoesDaAba);
                    final transacao = listaFinal[temGrafico ? index - 1 : index];
                    final bool isAgendado = !_isEfetivada(transacao.data);
                    
                    Color corValor = transacao.isReceita ? Colors.green[600]! : Colors.red[600]!;
                    if (transacao.formaPagamento == 'Vale Alimentação') corValor = Colors.orange[700]!;
                    if (isAgendado) corValor = Colors.orange[700]!;

                    return Dismissible(
                      key: Key(transacao.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 24),
                        decoration: BoxDecoration(color: Colors.red[100], borderRadius: BorderRadius.circular(20)),
                        child: Icon(Icons.delete_sweep_rounded, color: Colors.red[700], size: 28),
                      ),
                      onDismissed: (direction) {
                        setState(() {
                          _transacoesGlobais.removeWhere((t) => t.id == transacao.id);
                          _salvarDados();
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
                          border: Border.all(color: Colors.grey[100]!),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          leading: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: transacao.formaPagamento == 'Vale Alimentação' 
                                  ? Colors.orange[50] 
                                  : (isAgendado ? Colors.orange[50] : (transacao.isReceita ? Colors.green[50] : Colors.red[50])),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              transacao.formaPagamento == 'Vale Alimentação' ? Icons.fastfood_rounded : _getIconeCategoria(transacao.categoria), 
                              color: transacao.formaPagamento == 'Vale Alimentação' 
                                  ? Colors.orange[700] 
                                  : (isAgendado ? Colors.orange[700] : (transacao.isReceita ? Colors.green[700] : Colors.red[700])),
                              size: 20,
                            ),
                          ),
                          title: Text(transacao.titulo, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 15)),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 6.0, 
                              children: [
                                Text('${transacao.categoria} • ${DateFormat('dd/MM').format(transacao.data)}', style: TextStyle(color: Colors.grey[500], fontSize: 12, fontWeight: FontWeight.w500)),
                                if (transacao.formaPagamento == 'Vale Alimentação')
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(color: Colors.orange[50], borderRadius: BorderRadius.circular(6)),
                                    child: Icon(Icons.fastfood, size: 12, color: Colors.orange[700]),
                                  ),
                                if (!transacao.isReceita && transacao.formaPagamento == 'Cartão de Crédito')
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(6)),
                                    child: Icon(Icons.credit_card_rounded, size: 12, color: Colors.blue[700]),
                                  ),
                              ],
                            ),
                          ),
                          trailing: Text(
                            '${transacao.isReceita ? '+' : '-'} ${_formatador.format(transacao.valor)}',
                            style: TextStyle(color: corValor, fontWeight: FontWeight.bold, fontSize: 15),
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
      backgroundColor: const Color(0xFFF8FAFC), 
      body: Stack(
        children: [
          Column(
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
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Olá, Allan', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                            Text('Seu controle de gastos', style: TextStyle(color: Colors.green[200], fontSize: 13)),
                          ],
                        ),
                        Container(
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                          child: Row(
                            children: [
                              IconButton(icon: const Icon(Icons.chevron_left, color: Colors.white, size: 22), onPressed: () => _mudarMes(-1)),
                              Text('${_nomesMeses[_mesAtual.month - 1]}', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                              IconButton(icon: const Icon(Icons.chevron_right, color: Colors.white, size: 22), onPressed: () => _mudarMes(1)),
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
              
              Expanded(
                child: DefaultTabController(
                  length: 3, 
                  child: Column(
                    children: [
                      TabBar(
                        labelColor: Colors.green[800], unselectedLabelColor: Colors.grey[500], indicatorColor: Colors.green[700],
                        tabs: const [Tab(text: 'Linha do Tempo'), Tab(text: 'Entradas'), Tab(text: 'Saídas')],
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
            _buildBotaoMenuPremium(titulo: 'Nova Receita', icone: Icons.arrow_upward_rounded, cor: Colors.greenAccent[400]!, onTap: () => _encaminharParaCadastro(iniciarComoReceita: true)),
            const SizedBox(height: 12),
            _buildBotaoMenuPremium(titulo: 'Despesa À Vista', icone: Icons.arrow_downward_rounded, cor: Colors.redAccent[400]!, onTap: () => _encaminharParaCadastro(iniciarComoReceita: false, formaPagamento: 'Pix/Dinheiro')),
            const SizedBox(height: 12),
            _buildBotaoMenuPremium(titulo: 'Gasto no Cartão', icone: Icons.credit_card_rounded, cor: Colors.blueAccent[400]!, onTap: () => _encaminharParaCadastro(iniciarComoReceita: false, formaPagamento: 'Cartão de Crédito')),
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
}
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'tela_cadastro.dart';
import '../modelos/transacao.dart';

class TelaInicial extends StatefulWidget {
  const TelaInicial({super.key});

  @override
  State<TelaInicial> createState() => _TelaInicialState();
}

class _TelaInicialState extends State<TelaInicial> {
  final List<Transacao> _transacoes = [];

  final NumberFormat _formatador = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

  double get _totalReceitas {
    return _transacoes.where((t) => t.isReceita).fold(0.0, (soma, t) => soma + t.valor);
  }

  double get _totalDespesas {
    return _transacoes.where((t) => !t.isReceita).fold(0.0, (soma, t) => soma + t.valor);
  }

  double get _saldoTotal {
    return _totalReceitas - _totalDespesas;
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
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Saldo Atual', 
                    style: TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.w500)
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatador.format(_saldoTotal), 
                    style: TextStyle(
                      fontSize: 36, 
                      fontWeight: FontWeight.bold, 
                      color: _saldoTotal >= 0 ? Colors.black87 : Colors.red,
                    )
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(8)),
                            child: const Icon(Icons.arrow_upward, color: Colors.green, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Receitas', style: TextStyle(color: Colors.grey, fontSize: 14)),
                              Text(
                                _formatador.format(_totalReceitas),
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)
                              ),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(8)),
                            child: const Icon(Icons.arrow_downward, color: Colors.red, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Despesas', style: TextStyle(color: Colors.grey, fontSize: 14)),
                              Text(
                                _formatador.format(_totalDespesas),
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          const Text('Últimas Transações', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 12),

          if (_transacoes.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32.0),
              child: Center(child: Text('Nenhuma transação registrada ainda.', style: TextStyle(color: Colors.grey))),
            )
          else
            ..._transacoes.reversed.map((transacao) {
              
              return Dismissible(
                key: Key(transacao.id),
                direction: DismissDirection.endToStart,
                
                background: Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.delete, color: Colors.white, size: 30),
                ),
                
                onDismissed: (direction) {
                  setState(() {
                    _transacoes.removeWhere((t) => t.id == transacao.id);
                  });
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${transacao.titulo} apagada!'),
                      duration: const Duration(seconds: 2),
                      action: SnackBarAction(
                        label: 'Ok',
                        onPressed: () {},
                      ),
                    ),
                  );
                },
                
                child: Card(
                  elevation: 1,
                  margin: const EdgeInsets.only(bottom: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: transacao.isReceita ? Colors.green[100] : Colors.red[100],
                      child: Icon(
                        transacao.isReceita ? Icons.trending_up : Icons.shopping_cart, 
                        color: transacao.isReceita ? Colors.green : Colors.red
                      ),
                    ),
                    title: Text(transacao.titulo, style: const TextStyle(fontWeight: FontWeight.w500)),
                    trailing: Text(
                      '${transacao.isReceita ? '+' : '-'} ${_formatador.format(transacao.valor)}', 
                      style: TextStyle(
                        color: transacao.isReceita ? Colors.green : Colors.red, 
                        fontWeight: FontWeight.bold, 
                        fontSize: 16
                      ),
                    ),
                    onTap: () async {
                      final transacaoEditada = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TelaCadastro(transacaoParaEdicao: transacao),
                        ),
                      );

                      if (transacaoEditada != null) {
                        setState(() {
                          final index = _transacoes.indexWhere((t) => t.id == transacaoEditada.id);
                          if (index != -1) {
                            _transacoes[index] = transacaoEditada;
                          }
                        });
                      }
                    },
                  ),
                ),
              );
              
            }),
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
              _transacoes.add(transacaoRecebida);
            });
          }
        },
        backgroundColor: Colors.green[700],
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
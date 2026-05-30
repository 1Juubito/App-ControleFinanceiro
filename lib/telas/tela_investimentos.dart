import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../componentes/grafico_investimentos.dart';
import '../modelos/ativo_model.dart'; 
import 'tela_cadastro_investimento.dart';
import '../servicos/api_bolsa.dart';

class TelaInvestimentos extends StatefulWidget {
  const TelaInvestimentos({super.key});

  @override
  State<TelaInvestimentos> createState() => _TelaInvestimentosState();
}

class _TelaInvestimentosState extends State<TelaInvestimentos> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Minha Carteira',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('ativos').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.greenAccent));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'Nenhum investimento registrado ainda.',
                style: TextStyle(color: Colors.white.withOpacity(0.5)),
              ),
            );
          }

          final listaAtivos = snapshot.data!.docs.map((doc) {
            return AtivoModel.fromMap(doc.data() as Map<String, dynamic>);
          }).toList();

          final listaTickers = listaAtivos.map((a) => a.ticker).toList();

          return FutureBuilder<Map<String, double>>(
            future: ApiBolsa.buscarPrecosAtuais(listaTickers),
            builder: (context, apiSnapshot) {
              
              if (apiSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: Colors.blueAccent),
                      SizedBox(height: 16),
                      Text('Sincronizando com a B3...', style: TextStyle(color: Colors.white54)),
                    ],
                  ),
                );
              }

              final precosMercado = apiSnapshot.data ?? {};

              double patrimonioTotalReal = 0;
              for (var ativo in listaAtivos) {
                final precoAtual = precosMercado[ativo.ticker] ?? ativo.precoMedio;
                patrimonioTotalReal += (ativo.quantidade * precoAtual);
              }

              final List<Color> coresPaleta = [
                Colors.blueAccent,
                Colors.greenAccent,
                Colors.amberAccent,
                Colors.deepPurpleAccent,
                Colors.redAccent,
              ];

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05), 
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white.withOpacity(0.1)),
                      ),
                      child: GraficoInvestimentos(
                        patrimonioTotal: patrimonioTotalReal, 
                        listaAtivos: listaAtivos,
                      ),
                    ),

                    const SizedBox(height: 24),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Text(
                        'Meus Ativos',
                        style: TextStyle(
                          color: Colors.green[200],
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: listaAtivos.length,
                      itemBuilder: (context, index) {
                        final ativo = listaAtivos[index];
                        final corCard = coresPaleta[index % coresPaleta.length];
                        
                        final precoAtual = precosMercado[ativo.ticker] ?? ativo.precoMedio;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12, left: 16, right: 16),
                          child: Slidable(
                            key: Key(ativo.ticker),
                            endActionPane: ActionPane(
                              motion: const StretchMotion(),
                              extentRatio: 0.25,
                              children: [
                                SlidableAction(
                                  onPressed: (context) {
                                    FirebaseFirestore.instance
                                        .collection('ativos')
                                        .doc(ativo.ticker)
                                        .delete();
                                  },
                                  backgroundColor: Colors.red[600]!,
                                  foregroundColor: Colors.white,
                                  icon: Icons.delete_rounded,
                                  label: 'Excluir',
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ],
                            ),
                            child: _buildAtivoCard(
                              ticker: ativo.ticker,
                              quantidade: ativo.quantidade.toInt(),
                              precoMedio: ativo.precoMedio,
                              precoAtual: precoAtual,
                              cor: corCard,
                            ),
                          ),
                        );
                      },
                    ),
                    
                    const SizedBox(height: 40),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.greenAccent[400],
        child: const Icon(Icons.add_rounded, color: Colors.black, size: 32),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TelaCadastroInvestimento()),
          );
        },
      ),
    );
  }

  Widget _buildAtivoCard({
    required String ticker,
    required int quantidade,
    required double precoMedio,
    required double precoAtual,
    required Color cor,
  }) {
    final double totalInvestido = quantidade * precoMedio;
    final double totalAtual = quantidade * precoAtual;
    final double variacaoValor = totalAtual - totalInvestido;
    final double variacaoPercentual = (precoMedio > 0) ? (variacaoValor / totalInvestido) * 100 : 0;

    final bool noLucro = variacaoValor >= 0;
    final Color corVariacao = noLucro ? Colors.greenAccent : Colors.redAccent[400]!;
    final IconData iconeVariacao = noLucro ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 40,
            decoration: BoxDecoration(color: cor, borderRadius: BorderRadius.circular(6)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ticker, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                Text('$quantidade cotas', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('R\$ ${totalAtual.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              
              Row(
                children: [
                  Icon(iconeVariacao, color: corVariacao, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    '${variacaoPercentual.abs().toStringAsFixed(2)}%', 
                    style: TextStyle(color: corVariacao, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
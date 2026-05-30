import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../componentes/grafico_investimentos.dart';
import '../modelos/ativo_model.dart'; 
import 'tela_cadastro_investimento.dart';

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

          double patrimonioTotalReal = 0;
          for (var ativo in listaAtivos) {
            patrimonioTotalReal += ativo.totalInvestido;
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

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('${ativo.ticker} excluído com sucesso.'),
                                    backgroundColor: Colors.red[700],
                                  ),
                                );
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
                          nome: ativo.tipo, 
                          quantidade: ativo.quantidade.toInt(),
                          total: ativo.totalInvestido,
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
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.greenAccent[400],
        child: const Icon(Icons.add_rounded, color: Colors.black, size: 32),
        onPressed: () async {
          final novoAtivo = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const TelaCadastroInvestimento(),
            ),
          );
          
          if (novoAtivo == true) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Investimento registrado com sucesso!'),
                backgroundColor: Colors.green[700],
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildAtivoCard({
    required String ticker,
    required String nome,
    required int quantidade,
    required double total,
    required Color cor,
  }) {
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
            decoration: BoxDecoration(
              color: cor,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ticker, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                Text(nome, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('R\$ ${total.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              Text('$quantidade cotas', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}
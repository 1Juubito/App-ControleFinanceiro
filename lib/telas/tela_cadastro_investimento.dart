import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../modelos/ativo_model.dart'; 

class TelaCadastroInvestimento extends StatefulWidget {
  const TelaCadastroInvestimento({super.key});

  @override
  State<TelaCadastroInvestimento> createState() => _TelaCadastroInvestimentoState();
}

class _TelaCadastroInvestimentoState extends State<TelaCadastroInvestimento> {
  final _formKey = GlobalKey<FormState>();
  final _tickerController = TextEditingController();
  final _quantidadeController = TextEditingController();
  final _precoController = TextEditingController();
  
  String _tipoSelecionado = 'Ação';
  final List<String> _tiposAtivos = ['Ação', 'FII', 'ETF', 'BDR', 'Cripto'];

  bool _isSalvando = false;

  Future<void> _salvarAtivo() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSalvando = true);

      final double quantidadeNova = double.parse(_quantidadeController.text.replaceAll(',', '.'));
      final double precoNovo = double.parse(_precoController.text.replaceAll(',', '.'));
      final String tickerFormatado = _tickerController.text.toUpperCase().trim();

      final docRef = FirebaseFirestore.instance.collection('ativos').doc(tickerFormatado);

      try {
        await FirebaseFirestore.instance.runTransaction((transaction) async {
          final snapshot = await transaction.get(docRef);

          if (snapshot.exists) {
            final dadosAtuais = snapshot.data()!;
            final double quantidadeAtual = (dadosAtuais['quantidade'] as num).toDouble();
            final double precoMedioAtual = (dadosAtuais['precoMedio'] as num).toDouble();

            final double quantidadeTotal = quantidadeAtual + quantidadeNova;
            final double valorTotalAtual = quantidadeAtual * precoMedioAtual;
            final double valorTotalNovo = quantidadeNova * precoNovo;
            
            final double novoPrecoMedio = (valorTotalAtual + valorTotalNovo) / quantidadeTotal;

            transaction.update(docRef, {
              'quantidade': quantidadeTotal,
              'precoMedio': novoPrecoMedio,
            });
          } else {
            final novoAtivo = AtivoModel(
              id: tickerFormatado,
              ticker: tickerFormatado,
              nome: tickerFormatado, 
              quantidade: quantidadeNova,
              precoMedio: precoNovo,
              tipo: _tipoSelecionado,
            );
            
            transaction.set(docRef, novoAtivo.toMap());
          }
        });

        if (mounted) {
          Navigator.pop(context, true); 
        }
      } catch (e) {
        debugPrint('Erro ao salvar ativo: $e');
      } finally {
        if (mounted) setState(() => _isSalvando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Novo Investimento', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<String>(
                value: _tipoSelecionado,
                dropdownColor: Colors.grey[900],
                style: const TextStyle(color: Colors.white, fontSize: 16),
                decoration: _buildInputDecoration('Tipo de Ativo', Icons.category_rounded),
                items: _tiposAtivos.map((String tipo) {
                  return DropdownMenuItem(value: tipo, child: Text(tipo));
                }).toList(),
                onChanged: (String? novoValor) {
                  setState(() {
                    _tipoSelecionado = novoValor!;
                  });
                },
              ),
              const SizedBox(height: 20),
              
              TextFormField(
                controller: _tickerController,
                style: const TextStyle(color: Colors.white),
                textCapitalization: TextCapitalization.characters,
                decoration: _buildInputDecoration('Código do Ativo (Ticker)', Icons.tag_rounded),
                validator: (value) => value == null || value.isEmpty ? 'Informe o código do ativo' : null,
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _quantidadeController,
                style: const TextStyle(color: Colors.white),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: _buildInputDecoration('Quantidade', Icons.numbers_rounded),
                validator: (value) => value == null || value.isEmpty ? 'Informe a quantidade' : null,
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _precoController,
                style: const TextStyle(color: Colors.white),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: _buildInputDecoration('Preço de Compra (R\$)', Icons.attach_money_rounded),
                validator: (value) => value == null || value.isEmpty ? 'Informe o preço' : null,
              ),
              const SizedBox(height: 40),

              ElevatedButton(
                onPressed: _isSalvando ? null : _salvarAtivo,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.greenAccent[400],
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: _isSalvando 
                    ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 3))
                    : const Text('Registrar Compra', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label, IconData icone) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
      prefixIcon: Icon(icone, color: Colors.greenAccent[400]),
      filled: true,
      fillColor: Colors.white.withOpacity(0.05),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.greenAccent[400]!)),
    );
  }
}
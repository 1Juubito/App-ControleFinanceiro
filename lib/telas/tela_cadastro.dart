import 'package:flutter/material.dart';
import 'package:extended_masked_text/extended_masked_text.dart';
import '../modelos/transacao.dart';

class TelaCadastro extends StatefulWidget {
  final Transacao? transacaoParaEdicao;

  const TelaCadastro({super.key, this.transacaoParaEdicao});

  @override
  State<TelaCadastro> createState() => _TelaCadastroState();
}

class _TelaCadastroState extends State<TelaCadastro> {
  final _descricaoController = TextEditingController();
  final _valorController = MoneyMaskedTextController(
    leftSymbol: 'R\$ ', 
    decimalSeparator: ',', 
    thousandSeparator: '.',
  );
  bool _isReceita = false; 

  @override
  void initState() {
    super.initState();
    if (widget.transacaoParaEdicao != null) {
      _descricaoController.text = widget.transacaoParaEdicao!.titulo;
      _valorController.updateValue(widget.transacaoParaEdicao!.valor);
      _isReceita = widget.transacaoParaEdicao!.isReceita;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditando = widget.transacaoParaEdicao != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditando ? 'Editar Transação' : 'Nova Transação'),
        backgroundColor: _isReceita ? Colors.green[700] : Colors.red[700],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextField(
              controller: _descricaoController,
              decoration: const InputDecoration(labelText: 'Descrição', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _valorController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Valor', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Despesa', style: TextStyle(fontSize: 16)),
                Switch(
                  value: _isReceita,
                  onChanged: (valor) {
                    setState(() {
                      _isReceita = valor; 
                    });
                  },
                  activeThumbColor: Colors.green,
                  inactiveThumbColor: Colors.red,
                ),
                const Text('Receita', style: TextStyle(fontSize: 16)),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity, 
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  final textoDescricao = _descricaoController.text;
                  final valorConvertido = _valorController.numberValue;

                  if (textoDescricao.isEmpty || valorConvertido <= 0) return; 

                  final transacaoAtualizada = Transacao(
                    id: isEditando ? widget.transacaoParaEdicao!.id : DateTime.now().toString(), 
                    titulo: textoDescricao,
                    valor: valorConvertido,
                    isReceita: _isReceita,
                  );

                  Navigator.pop(context, transacaoAtualizada);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isReceita ? Colors.green : Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: Text(isEditando ? 'ATUALIZAR' : 'SALVAR', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
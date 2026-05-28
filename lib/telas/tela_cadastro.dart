import 'package:flutter/material.dart';
import 'package:extended_masked_text/extended_masked_text.dart';
import 'package:intl/intl.dart';
import '../modelos/transacao.dart';

class TelaCadastro extends StatefulWidget {
  final Transacao? transacaoParaEdicao;
  const TelaCadastro({super.key, this.transacaoParaEdicao});

  @override
  State<TelaCadastro> createState() => _TelaCadastroState();
}

class _TelaCadastroState extends State<TelaCadastro> {
  final _descricaoController = TextEditingController();
  final _valorController = MoneyMaskedTextController(leftSymbol: 'R\$ ', decimalSeparator: ',', thousandSeparator: '.');
  final _parcelasController = TextEditingController(text: '2');
  
  bool _isReceita = false; 
  DateTime _dataSelecionada = DateTime.now();
  
  final List<String> _categoriasDespesa = ['Alimentação', 'Transporte', 'Moradia', 'Saúde', 'Lazer', 'Cuidados Pessoais', 'Outros'];
  final List<String> _categoriasReceita = ['Salário', 'Investimentos', 'Freelance', 'Outros'];
  String _categoriaSelecionada = 'Outros';

  String _tipoRepeticao = 'Única'; 
  String _formaPagamento = 'Pix/Dinheiro';

  @override
  void initState() {
    super.initState();
    if (widget.transacaoParaEdicao != null) {
      _descricaoController.text = widget.transacaoParaEdicao!.titulo;
      _valorController.updateValue(widget.transacaoParaEdicao!.valor);
      _isReceita = widget.transacaoParaEdicao!.isReceita;
      _categoriaSelecionada = widget.transacaoParaEdicao!.categoria;
      _dataSelecionada = widget.transacaoParaEdicao!.data;
      _formaPagamento = widget.transacaoParaEdicao!.formaPagamento;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditando = widget.transacaoParaEdicao != null;
    final categoriasAtuais = _isReceita ? _categoriasReceita : _categoriasDespesa;

    if (!categoriasAtuais.contains(_categoriaSelecionada)) {
      _categoriaSelecionada = 'Outros';
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditando ? 'Editar Transação' : 'Nova Transação'),
        backgroundColor: _isReceita ? Colors.green[700] : Colors.red[700],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
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
              decoration: const InputDecoration(labelText: 'Valor da Parcela/Mês', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(4)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Data: ${DateFormat('dd/MM/yyyy').format(_dataSelecionada)}', style: const TextStyle(fontSize: 16)),
                  TextButton.icon(
                    icon: const Icon(Icons.calendar_month),
                    label: const Text('Alterar'),
                    onPressed: () async {
                      final dataEscolhida = await showDatePicker(
                        context: context,
                        initialDate: _dataSelecionada,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                      );
                      if (dataEscolhida != null) {
                        setState(() { _dataSelecionada = dataEscolhida; });
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Despesa', style: TextStyle(fontSize: 16)),
                Switch(
                  value: _isReceita,
                  onChanged: (valor) { 
                    setState(() { 
                      _isReceita = valor; 
                      if (_isReceita) _formaPagamento = 'Pix/Dinheiro'; 
                    }); 
                  },
                  activeColor: Colors.green,
                  inactiveThumbColor: Colors.red,
                ),
                const Text('Receita', style: TextStyle(fontSize: 16)),
              ],
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: _categoriaSelecionada,
              decoration: const InputDecoration(labelText: 'Categoria', border: OutlineInputBorder()),
              items: categoriasAtuais.map((String cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
              onChanged: (novoValor) { setState(() { _categoriaSelecionada = novoValor!; }); },
            ),
            const SizedBox(height: 16),

            if (!_isReceita) ...[
              const Divider(),
              const Text('Forma de Pagamento', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey)),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'Pix/Dinheiro', label: Text('À Vista', style: TextStyle(fontSize: 12)), icon: Icon(Icons.pix, size: 16)),
                  ButtonSegment(value: 'Cartão de Crédito', label: Text('Crédito', style: TextStyle(fontSize: 12)), icon: Icon(Icons.credit_card, size: 16)),
                ],
                selected: {_formaPagamento},
                onSelectionChanged: (Set<String> selecao) {
                  setState(() { _formaPagamento = selecao.first; });
                },
              ),
              const SizedBox(height: 16),
            ],

            if (!isEditando) ...[
              const Divider(),
              const Text('Repetição', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey)),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'Única', label: Text('Única', style: TextStyle(fontSize: 12))),
                  ButtonSegment(value: 'Fixa', label: Text('Fixa', style: TextStyle(fontSize: 12))),
                  ButtonSegment(value: 'Parcelada', label: Text('Parcelada', style: TextStyle(fontSize: 12))),
                ],
                selected: {_tipoRepeticao},
                onSelectionChanged: (Set<String> selecao) {
                  setState(() { _tipoRepeticao = selecao.first; });
                },
              ),
              const SizedBox(height: 16),
              
              if (_tipoRepeticao != 'Única')
                TextField(
                  controller: _parcelasController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: _tipoRepeticao == 'Parcelada' ? 'Quantidade de Parcelas' : 'Repetir por quantos meses?', 
                    border: const OutlineInputBorder()
                  ),
                ),
              const SizedBox(height: 32),
            ],

            SizedBox(
              width: double.infinity, 
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  final textoDescricao = _descricaoController.text;
                  final valorConvertido = _valorController.numberValue;

                  if (textoDescricao.isEmpty || valorConvertido <= 0) return; 

                  int quantidade = 1;
                  if (!isEditando && _tipoRepeticao != 'Única') {
                    quantidade = int.tryParse(_parcelasController.text) ?? 1;
                  }

                  List<Transacao> transacoesGeradas = [];

                  for (int i = 0; i < quantidade; i++) {
                    DateTime dataFutura = DateTime(_dataSelecionada.year, _dataSelecionada.month + i, _dataSelecionada.day);
                    String tituloFinal = textoDescricao;
                    
                    if (_tipoRepeticao == 'Parcelada') {
                      tituloFinal = '$textoDescricao (${i + 1}/$quantidade)';
                    }

                    transacoesGeradas.add(Transacao(
                      id: isEditando ? widget.transacaoParaEdicao!.id : DateTime.now().add(Duration(milliseconds: i)).toString(),
                      titulo: tituloFinal,
                      valor: valorConvertido,
                      isReceita: _isReceita,
                      categoria: _categoriaSelecionada,
                      data: dataFutura, 
                      formaPagamento: _formaPagamento,
                    ));
                  }

                  if (isEditando) {
                    Navigator.pop(context, transacoesGeradas.first);
                  } else {
                    Navigator.pop(context, transacoesGeradas);
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: _isReceita ? Colors.green : Colors.red, foregroundColor: Colors.white),
                child: Text(isEditando ? 'ATUALIZAR' : 'SALVAR', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
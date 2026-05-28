import 'package:flutter/material.dart';
import 'package:extended_masked_text/extended_masked_text.dart';
import 'package:intl/intl.dart';
import '../modelos/transacao.dart';

class TelaCadastro extends StatefulWidget {
  final Transacao? transacaoParaEdicao;
  final bool? iniciarComoReceita; 
  final String? iniciarFormaPagamento; 

  const TelaCadastro({
    super.key, 
    this.transacaoParaEdicao, 
    this.iniciarComoReceita, 
    this.iniciarFormaPagamento,
  });

  @override
  State<TelaCadastro> createState() => _TelaCadastroState();
}

class _TelaCadastroState extends State<TelaCadastro> {
  final _descricaoController = TextEditingController();
  late MoneyMaskedTextController _valorController;
  final _parcelasController = TextEditingController(text: '2');
  
  bool _isReceita = false; 
  DateTime _dataSelecionada = DateTime.now();
  
  final List<String> _categoriasDespesa = ['Alimentação', 'Transporte', 'Moradia', 'Saúde', 'Lazer', 'Cuidados Pessoais', 'Outros'];
  final List<String> _categoriasReceita = ['Salário', 'Investimentos', 'Freelance', 'Outros'];
  String _categoriaSelecionada = 'Outros';

  String _tipoRepeticao = 'Única'; 
  String _formaPagamento = 'Pix/Dinheiro'; 

  final Map<String, IconData> _iconesCategoria = {
    'Alimentação': Icons.restaurant,
    'Transporte': Icons.directions_car,
    'Moradia': Icons.home,
    'Saúde': Icons.medical_services,
    'Lazer': Icons.sports_esports,
    'Cuidados Pessoais': Icons.content_cut,
    'Salário': Icons.work,
    'Investimentos': Icons.monetization_on,
    'Freelance': Icons.laptop_mac,
    'Outros': Icons.category_rounded,
  };

  @override
  void initState() {
    super.initState();
    
    _valorController = MoneyMaskedTextController(leftSymbol: 'R\$ ', decimalSeparator: ',', thousandSeparator: '.');
    
    _valorController.addListener(() {
      setState(() {});
    });

    _descricaoController.addListener(() {
      setState(() {});
    });

    if (widget.transacaoParaEdicao != null) {
      _descricaoController.text = widget.transacaoParaEdicao!.titulo;
      _valorController.updateValue(widget.transacaoParaEdicao!.valor);
      _isReceita = widget.transacaoParaEdicao!.isReceita;
      _categoriaSelecionada = widget.transacaoParaEdicao!.categoria;
      _dataSelecionada = widget.transacaoParaEdicao!.data;
      _formaPagamento = widget.transacaoParaEdicao!.formaPagamento;
    } else {
      if (widget.iniciarComoReceita != null) {
        _isReceita = widget.iniciarComoReceita!;
        if (_isReceita) _formaPagamento = 'Pix/Dinheiro';
      }
      if (widget.iniciarFormaPagamento != null) {
        _formaPagamento = widget.iniciarFormaPagamento!;
      }
    }
  }

  Widget _buildCartaoImersivo() {
    final bool isCartao = _formaPagamento == 'Cartão de Crédito';
    final valorAtual = _valorController.text;
    final tituloAtual = _descricaoController.text.isEmpty ? 'Nova Transação' : _descricaoController.text;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      padding: const EdgeInsets.all(24),
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isCartao 
              ? [Colors.blue[800]!, Colors.blue[900]!, Colors.black87] 
              : (_isReceita ? [Colors.green[500]!, Colors.green[800]!] : [Colors.red[400]!, Colors.red[700]!]),
        ),
        boxShadow: [
          BoxShadow(
            color: (isCartao ? Colors.blue : (_isReceita ? Colors.green : Colors.red)).withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(isCartao ? Icons.credit_card_outlined : (_isReceita ? Icons.arrow_upward : Icons.arrow_downward), color: Colors.white70, size: 28),
              if (isCartao)
                Row(
                  children: [
                    const Icon(Icons.circle, color: Colors.white54, size: 16),
                    Transform.translate(
                      offset: const Offset(-6, 0),
                      child: const Icon(Icons.circle, color: Colors.white70, size: 16),
                    ),
                  ],
                )
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                valorAtual == 'R\$ 0,00' ? 'R\$ ---' : valorAtual,
                style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: -1),
              ),
              const SizedBox(height: 8),
              Text(
                tituloAtual.toUpperCase(),
                style: const TextStyle(fontSize: 14, color: Colors.white70, letterSpacing: 1.5),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isCartao
                  ? 'ALLAN CARTÃO'
                  : (_isReceita ? 'ALLAN RECEITAS' : 'ALLAN DESPESAS'),
                style: const TextStyle(fontSize: 14, color: Colors.white54, letterSpacing: 2, fontWeight: FontWeight.w600),
              ),
              Text(
                DateFormat('dd/MM').format(_dataSelecionada),
                style: const TextStyle(fontSize: 14, color: Colors.white54, letterSpacing: 2, fontWeight: FontWeight.w600)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildGridCategorias(List<String> categoriasAtuais) {
    return Wrap(
      spacing: 12,
      runSpacing: 16,
      children: categoriasAtuais.map((String cat) {
        final bool isSelecionado = _categoriaSelecionada == cat;
        return GestureDetector(
          onTap: () => setState(() => _categoriaSelecionada = cat),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelecionado ? (_isReceita ? Colors.green : Colors.blue[600]) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isSelecionado ? Colors.transparent : Colors.grey[300]!, width: 1.5),
              boxShadow: isSelecionado ? [BoxShadow(color: (_isReceita ? Colors.green : Colors.blue).withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))] : [],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(_iconesCategoria[cat] ?? Icons.category, size: 18, color: isSelecionado ? Colors.white : Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  cat,
                  style: TextStyle(color: isSelecionado ? Colors.white : Colors.grey[800], fontWeight: isSelecionado ? FontWeight.bold : FontWeight.normal),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditando = widget.transacaoParaEdicao != null;
    final categoriasAtuais = _isReceita ? _categoriasReceita : _categoriasDespesa;
    if (!categoriasAtuais.contains(_categoriaSelecionada)) _categoriaSelecionada = categoriasAtuais.first;

    final bool tecladoAberto = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      backgroundColor: Colors.grey[50], 
      appBar: AppBar(
        title: Text(isEditando ? 'Editar Lançamento' : (_formaPagamento == 'Cartão de Crédito' ? 'Novo Gasto' : (_isReceita ? 'Nova Receita' : 'Nova Despesa'))),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildCartaoImersivo(),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _valorController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'R\$ 0,00',
                    ),
                  ),
                  const SizedBox(height: 8),

                  TextField(
                    controller: _descricaoController,
                    style: const TextStyle(fontSize: 18),
                    decoration: InputDecoration(
                      labelText: 'Com o que foi?',
                      labelStyle: TextStyle(color: Colors.grey[600]),
                      prefixIcon: const Icon(Icons.edit_note),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),

                  const Text('Categoria', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                  const SizedBox(height: 16),
                  _buildGridCategorias(categoriasAtuais),
                  const SizedBox(height: 32),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey[200]!)),
                    child: Column(
                      children: [
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.blue[50], shape: BoxShape.circle), child: Icon(Icons.calendar_month, color: Colors.blue[700])),
                          title: const Text('Data do Lançamento', style: TextStyle(fontSize: 14, color: Colors.grey)),
                          subtitle: Text(DateFormat('dd/MM/yyyy').format(_dataSelecionada), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () async {
                            final dataEscolhida = await showDatePicker(context: context, initialDate: _dataSelecionada, firstDate: DateTime(2020), lastDate: DateTime(2030));
                            if (dataEscolhida != null) setState(() { _dataSelecionada = dataEscolhida; });
                          },
                        ),
                        
                        if (!isEditando) ...[
                          const Divider(height: 32),
                          const Text('Como deseja registrar?', style: TextStyle(fontSize: 14, color: Colors.grey)),
                          const SizedBox(height: 12),
                          SegmentedButton<String>(
                            style: SegmentedButton.styleFrom(
                              backgroundColor: Colors.grey[50],
                              selectedBackgroundColor: _isReceita ? Colors.green[100] : Colors.blue[100],
                            ),
                            segments: const [
                              ButtonSegment(value: 'Única', label: Text('Única', style: TextStyle(fontSize: 12))),
                              ButtonSegment(value: 'Fixa', label: Text('Mensal Fixo', style: TextStyle(fontSize: 12))),
                              ButtonSegment(value: 'Parcelada', label: Text('Parcelado', style: TextStyle(fontSize: 12))),
                            ],
                            selected: {_tipoRepeticao},
                            onSelectionChanged: (Set<String> selecao) { setState(() { _tipoRepeticao = selecao.first; }); },
                          ),
                          
                          if (_tipoRepeticao != 'Única') ...[
                            const SizedBox(height: 16),
                            TextField(
                              controller: _parcelasController,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                              decoration: InputDecoration(
                                labelText: _tipoRepeticao == 'Parcelada' ? 'Nº de Parcelas' : 'Repetir por quantos meses?',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                                filled: true,
                                fillColor: Colors.grey[50],
                              ),
                            ),
                          ]
                        ]
                      ],
                    ),
                  ),
                  const SizedBox(height: 120), 
                ],
              ),
            ),
          ),
        ],
      ),
      
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      
      floatingActionButton: tecladoAberto ? null : Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () {
              final textoDescricao = _descricaoController.text;
              final valorConvertido = _valorController.numberValue;

              if (textoDescricao.isEmpty || valorConvertido <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Preencha o valor e a descrição!'), backgroundColor: Colors.red));
                return; 
              }

              int quantidade = 1;
              if (!isEditando && _tipoRepeticao != 'Única') quantidade = int.tryParse(_parcelasController.text) ?? 1;

              List<Transacao> transacoesGeradas = [];

              for (int i = 0; i < quantidade; i++) {
                DateTime dataFutura = DateTime(_dataSelecionada.year, _dataSelecionada.month + i, _dataSelecionada.day);
                String tituloFinal = textoDescricao;
                if (_tipoRepeticao == 'Parcelada') tituloFinal = '$textoDescricao (${i + 1}/$quantidade)';

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
              Navigator.pop(context, isEditando ? transacoesGeradas.first : transacoesGeradas);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black87,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 8,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(isEditando ? Icons.check_circle : Icons.save_rounded),
                const SizedBox(width: 8),
                Text(isEditando ? 'ATUALIZAR' : 'SALVAR LANÇAMENTO', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
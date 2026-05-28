import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:extended_masked_text/extended_masked_text.dart';
import 'package:intl/intl.dart';
import '../modelos/meta.dart';

class TelaMetas extends StatefulWidget {
  const TelaMetas({super.key});

  @override
  State<TelaMetas> createState() => _TelaMetasState();
}

class _TelaMetasState extends State<TelaMetas> {
  List<MetaEconomia> _metas = [];
  final NumberFormat _formatador = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

  @override
  void initState() {
    super.initState();
    _carregarMetas();
  }

  Future<void> _carregarMetas() async {
    final prefs = await SharedPreferences.getInstance();
    final dadosString = prefs.getString('metas_salvas');
    if (dadosString != null) {
      final List<dynamic> dadosDecodificados = jsonDecode(dadosString);
      setState(() {
        _metas = dadosDecodificados.map((item) => MetaEconomia.fromJson(item)).toList();
      });
    }
  }

  Future<void> _salvarMetas() async {
    final prefs = await SharedPreferences.getInstance();
    final dadosString = jsonEncode(_metas.map((m) => m.toJson()).toList());
    await prefs.setString('metas_salvas', dadosString);
  }

  void _abrirDialogNovaMeta() {
    final tituloController = TextEditingController();
    final valorController = MoneyMaskedTextController(leftSymbol: 'R\$ ', decimalSeparator: ',', thousandSeparator: '.');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Novo Cofrinho', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: tituloController,
              decoration: InputDecoration(
                labelText: 'Qual é o seu objetivo?',
                hintText: 'Ex: Viagem, Upgrade PC...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: valorController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Quanto precisa juntar?',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCELAR', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () {
              if (tituloController.text.isNotEmpty && valorController.numberValue > 0) {
                setState(() {
                  _metas.add(MetaEconomia(
                    id: DateTime.now().toString(),
                    titulo: tituloController.text,
                    valorObjetivo: valorController.numberValue,
                    icone: 'savings_rounded',
                  ));
                  _salvarMetas();
                });
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green[700], foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text('CRIAR META'),
          ),
        ],
      ),
    );
  }

  void _abrirDialogDeposito(MetaEconomia meta, int index) {
    final depositoController = MoneyMaskedTextController(leftSymbol: 'R\$ ', decimalSeparator: ',', thousandSeparator: '.');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Guardar em: ${meta.titulo}', style: const TextStyle(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: depositoController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Valor a depositar',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCELAR', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () {
              if (depositoController.numberValue > 0) {
                setState(() {
                  _metas[index].valorAtual += depositoController.numberValue;
                  _salvarMetas();
                });
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.black87, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text('DEPOSITAR'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Meus Cofrinhos', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: true,
      ),
      body: _metas.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.savings_outlined, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text('Nenhum cofrinho criado ainda.', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: _metas.length,
              itemBuilder: (context, index) {
                final meta = _metas[index];
                final percentual = meta.percentualConcluido;
                final bool isConcluido = percentual >= 1.0;

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  elevation: 0,
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(color: isConcluido ? Colors.green[50] : Colors.blue[50], shape: BoxShape.circle),
                                  child: Icon(isConcluido ? Icons.emoji_events_rounded : Icons.savings_rounded, color: isConcluido ? Colors.green[700] : Colors.blue[700], size: 22),
                                ),
                                const SizedBox(width: 12),
                                Text(meta.titulo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
                              ],
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  _metas.removeAt(index);
                                  _salvarMetas();
                                });
                              },
                            )
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(_formatador.format(meta.valorAtual), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: isConcluido ? Colors.green[700] : Colors.black87)),
                            Text('de ${_formatador.format(meta.valorObjetivo)}', style: TextStyle(color: Colors.grey[500], fontSize: 13, fontWeight: FontWeight.w600)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: percentual,
                            minHeight: 10,
                            backgroundColor: Colors.grey[100],
                            valueColor: AlwaysStoppedAnimation<Color>(isConcluido ? Colors.green[500]! : Colors.blue[600]!),
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (!isConcluido)
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () => _abrirDialogDeposito(meta, index),
                              icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
                              label: const Text('Guardar Dinheiro'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.blue[700],
                                side: BorderSide(color: Colors.blue[200]!),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          )
                        else
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(12)),
                            child: const Center(child: Text('OBJETIVO ALCANÇADO! 🎉', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold))),
                          )
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _abrirDialogNovaMeta,
        backgroundColor: const Color(0xFF111111),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Nova Meta', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
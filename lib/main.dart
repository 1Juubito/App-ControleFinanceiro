import 'package:flutter/material.dart';
import 'telas/tela_inicial.dart';

void main() {
  runApp(const MeuControleFinanceiroApp());
}

class MeuControleFinanceiroApp extends StatelessWidget {
  const MeuControleFinanceiroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Controle Financeiro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const TelaInicial(),
    );
  }
}
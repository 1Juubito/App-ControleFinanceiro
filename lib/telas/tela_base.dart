import 'package:flutter/material.dart';
import 'tela_inicial.dart';
import 'tela_investimentos.dart';

class TelaBase extends StatefulWidget {
  const TelaBase({super.key});

  @override
  State<TelaBase> createState() => _TelaBaseState();
}

class _TelaBaseState extends State<TelaBase> {
  int _indiceAtual = 0;

  final List<Widget> _telas = [
    const TelaInicial(),
    const TelaInvestimentos(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _indiceAtual,
        children: _telas,
      ),
      
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF111111),
          border: Border(
            top: BorderSide(color: Colors.white.withOpacity(0.05), width: 1),
          ),
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          currentIndex: _indiceAtual,
          selectedItemColor: Colors.greenAccent[400],
          unselectedItemColor: Colors.white38,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          onTap: (index) {
            setState(() {
              _indiceAtual = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4.0),
                child: Icon(Icons.account_balance_wallet_rounded, size: 26),
              ),
              label: 'Conta',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4.0),
                child: Icon(Icons.trending_up_rounded, size: 26),
              ),
              label: 'Investimentos',
            ),
          ],
        ),
      ),
    );
  }
}
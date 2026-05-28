import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'tela_inicial.dart';

class TelaBloqueio extends StatefulWidget {
  const TelaBloqueio({super.key});

  @override
  State<TelaBloqueio> createState() => _TelaBloqueioState();
}

class _TelaBloqueioState extends State<TelaBloqueio> {
  final LocalAuthentication _auth = LocalAuthentication();
  bool _isAutenticando = false;

  @override
  void initState() {
    super.initState();
    _autenticar(); 
  }

  Future<void> _autenticar() async {
    setState(() {
      _isAutenticando = true;
    });

    try {
      final bool autenticado = await _auth.authenticate(
        localizedReason: 'Posicione o dedo no sensor para liberar o acesso',
        authMessages: const [
          AndroidAuthMessages(
            signInTitle: 'Cofre Financeiro',
            cancelButton: 'Cancelar',
          ),
        ],
      );

      if (autenticado && mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const TelaInicial()),
        );
      }
    } on PlatformException catch (e) {
      debugPrint("Erro na biometria: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isAutenticando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.green[800]!,
              Colors.green[900]!,
              const Color(0xFF111111),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.2), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.2),
                      blurRadius: 30,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: const Icon(Icons.fingerprint, size: 80, color: Colors.white),
              ),
              const SizedBox(height: 32),
              
              const Text(
                'Allan Finanças',
                style: TextStyle(
                  fontSize: 28, 
                  color: Colors.white, 
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              
              Text(
                'Acesso Restrito',
                style: TextStyle(fontSize: 16, color: Colors.green[200], letterSpacing: 2.0),
              ),
              const SizedBox(height: 60),
              
              if (_isAutenticando)
                const CircularProgressIndicator(color: Colors.greenAccent)
              else
                ElevatedButton.icon(
                  onPressed: _autenticar,
                  icon: const Icon(Icons.lock_open, color: Colors.white),
                  label: const Text('Tentar Novamente', style: TextStyle(fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    elevation: 8,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}
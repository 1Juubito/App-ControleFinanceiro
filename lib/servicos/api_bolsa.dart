import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiBolsa {
  static final String _token = dotenv.env['BRAPI_TOKEN'] ?? '';

  static Future<Map<String, double>> buscarPrecosAtuais(List<String> tickers) async {
    if (tickers.isEmpty) return {};

    final tickersString = tickers.join(',');
    
    final url = Uri.parse('https://brapi.dev/api/quote/$tickersString?token=$_token');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final dadosDecode = jsonDecode(response.body);
        final Map<String, double> precosAtualizados = {};
        
        for (var resultado in dadosDecode['results']) {
          final String ticker = resultado['symbol'];
          final double precoAtual = (resultado['regularMarketPrice'] as num).toDouble();
          precosAtualizados[ticker] = precoAtual;
        }
        
        return precosAtualizados;
      } else {
        debugPrint('Erro da API: Resposta ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Erro ao buscar dados na Bolsa: $e');
    }
    
    return {}; 
  }
}
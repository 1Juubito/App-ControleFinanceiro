import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificacaoService {
  static final NotificacaoService _instancia = NotificacaoService._internal();
  factory NotificacaoService() => _instancia;
  NotificacaoService._internal();

  final FlutterLocalNotificationsPlugin plugin = FlutterLocalNotificationsPlugin();

  Future<void> inicializar() async {
    const AndroidInitializationSettings configAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const InitializationSettings configGeral = InitializationSettings(android: configAndroid);
    
    await plugin.initialize(settings: configGeral);
  }

  // Future<void> mostrarNotificacaoTeste() async {
  //   const AndroidNotificationDetails detalhesAndroid = AndroidNotificationDetails(
  //     'canal_financas_02',
  //     'Lembretes Financeiros',
  //     channelDescription: 'Avisa sobre contas a pagar e vencimentos',
  //     importance: Importance.max,
  //     priority: Priority.high,
  //     ticker: 'ticker',
  //   );
    
  //   const NotificationDetails detalhesGerais = NotificationDetails(android: detalhesAndroid);
    
  //   await plugin.show(
  //     id: 0,
  //     title: 'App de Finanças 💸', // Título
  //     body: 'O seu motor de notificações está a funcionar perfeitamente!', // Corpo
  //     notificationDetails: detalhesGerais,
  //   );
  // }
}
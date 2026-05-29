import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import '../modelos/transacao.dart'; 

class NotificacaoService {
  static final NotificacaoService _instancia = NotificacaoService._internal();
  factory NotificacaoService() => _instancia;
  NotificacaoService._internal();

  final FlutterLocalNotificationsPlugin plugin = FlutterLocalNotificationsPlugin();

  Future<void> inicializar() async {
    const AndroidInitializationSettings configAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings configGeral = InitializationSettings(android: configAndroid);
    await plugin.initialize(settings: configGeral);

    tz.initializeTimeZones();
    final tzInfo = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(tzInfo.identifier));
  }

  Future<void> agendarNotificacao(Transacao transacao) async {
    if (transacao.statusPago || transacao.isReceita) return;

    final dataAgendada = tz.TZDateTime(
      tz.local,
      transacao.data.year,
      transacao.data.month,
      transacao.data.day,
      8,  
      0,  
    );

    if (dataAgendada.isBefore(tz.TZDateTime.now(tz.local))) return;

    const AndroidNotificationDetails detalhesAndroid = AndroidNotificationDetails(
      'canal_lembretes_vencimento',
      'Vencimento de Contas',
      channelDescription: 'Avisa no dia do vencimento dos boletos',
      importance: Importance.max,
      priority: Priority.high,
    );

    await plugin.zonedSchedule(
      id: transacao.id.hashCode,
      title: 'Conta vencendo hoje! ⚠️',
      body: 'Não esqueça de pagar: ${transacao.titulo} no valor de R\$ ${transacao.valor.toStringAsFixed(2)}',
      scheduledDate: dataAgendada,
      notificationDetails: const NotificationDetails(android: detalhesAndroid),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> cancelarNotificacao(String id) async {
    await plugin.cancel(id: id.hashCode);
  }
}
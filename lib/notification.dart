// lib/notification.dart
// ------------------------------------------------------------
// Módulo responsável por gerenciar TODA a lógica de notificações
// locais do aplicativo (Android/iOS/desktop onde aplicável).
// Aqui centralizamos:
// - inicialização do plugin de notificações
// - pedido de permissões
// - agendamento de lembretes (1 dia antes, no dia, fértil, ovulação, atraso)
// - envio de notificações imediatas para feedback
// - cancelamento de todas as notificações
// ------------------------------------------------------------
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class PeriodNotification {
  // singleton simples
  static final PeriodNotification _instance = PeriodNotification._internal();
  factory PeriodNotification() => _instance;
  PeriodNotification._internal();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  /// Inicializa o plugin (idempotente) e pede permissões (Android 13+ / iOS).
  Future<void> initNotifications() async {
    if (_initialized) return;

        try {
      // Inicializar timezone
      tz.initializeTimeZones();

      // Mantive uma inicialização simples (usa o ícone @mipmap/ic_launcher como você tinha).
      const AndroidInitializationSettings androidInitializationSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // se quiser suportar iOS com mais detalhes, podemos adicionar DarwinInitializationSettings.
      const InitializationSettings initializationSettings =
          InitializationSettings(android: androidInitializationSettings);

      try {
        await _plugin.initialize(initializationSettings);
      } catch (e) {
        debugPrint('Erro ao inicializar flutter_local_notifications: $e');
      }

      // Pedir permissão (Android 13+) e iOS (se disponível)
      try {
        if (Platform.isAndroid) {
          final androidImpl =
              _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
          await androidImpl?.requestNotificationsPermission();
        } else if (Platform.isIOS) {
          final iosImpl =
              _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
          await iosImpl?.requestPermissions(alert: true, badge: true, sound: true);
        }
      } catch (e) {
        debugPrint('Erro ao pedir permissão para notificações: $e');
      }

      _initialized = true;
    } catch (e) {
      debugPrint('❌ Erro crítico na inicialização: $e');
      _initialized = false;
    }
  }

  /// Mostra uma notificação imediata (para demonstração).
  Future<void> showNotification(int daysLeft) async {
    await initNotifications(); // garante inicialização e permissões

    final title = 'Lembrete do ciclo';
    final body = daysLeft > 0
        ? 'Faltam $daysLeft dias para sua menstruação'
        : 'Sua menstruação pode ter começado';

    // No Windows, apenas mostrar no console
    if (Platform.isWindows) {
      debugPrint('🔔 NOTIFICAÇÃO: $title - $body');
      return;
    }

    final androidDetails = AndroidNotificationDetails(
      'period_channel', // id do canal
      'Período', // nome visível
      channelDescription: 'Notificações de ciclo menstrual',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );

    final platformDetails = NotificationDetails(android: androidDetails);

    try {
      await _plugin.show(0, title, body, platformDetails);
    } catch (e) {
      debugPrint('Erro ao exibir notificação: $e');
    }
  }

  /// Calcula dias restantes considerando ciclo fixo (padrão 28 dias).
  int calcularDiasParaProximaMenstruacao(DateTime dataUltimaMenstruacao,
      {int cicloDias = 28}) {
    final ultima = DateTime(
        dataUltimaMenstruacao.year, dataUltimaMenstruacao.month, dataUltimaMenstruacao.day);
    final proximaMenstruacao = ultima.add(Duration(days: cicloDias));
    final hoje = DateTime.now();
    final hojeNormalizado = DateTime(hoje.year, hoje.month, hoje.day);
    final diasRestantes = proximaMenstruacao.difference(hojeNormalizado).inDays;
    return diasRestantes > 0 ? diasRestantes : 0;
  }

  /// Cancela todas as notificações programadas
  Future<void> cancelAllNotifications() async {
    await initNotifications(); // Garante inicialização
    try {
      await _plugin.cancelAll();
      debugPrint('✅ Todas as notificações canceladas');
    } catch (e) {
      debugPrint('❌ Erro ao cancelar notificações: $e');
    }
  }

  /// Programa notificações para o próximo período
  Future<void> scheduleNotifications(DateTime dataUltimaMenstruacao, {int cicloDias = 28}) async {
    await initNotifications();
    
    try {
      await cancelAllNotifications();
    } catch (e) {
      debugPrint('⚠️ Erro ao cancelar notificações anteriores: $e');
    }

    final proximaMenstruacao = dataUltimaMenstruacao.add(Duration(days: cicloDias));
    final hoje = DateTime.now();

    // Notificação 3 dias antes (mantida)
    final tresDiasAntes = proximaMenstruacao.subtract(const Duration(days: 3));
    if (tresDiasAntes.isAfter(hoje)) {
      await _scheduleNotification(
        1,
        'Lembrete do Ciclo',
        'Sua menstruação pode começar em 3 dias. Prepare-se!',
        tresDiasAntes,
      );
    }

    // Notificação 1 dia antes às 18:00 com mensagem personalizada
    final umDiaAntes = proximaMenstruacao.subtract(const Duration(days: 1));
    final umDiaAntesAs18 = DateTime(
      umDiaAntes.year,
      umDiaAntes.month,
      umDiaAntes.day,
      18,
      0,
    );
    if (umDiaAntesAs18.isAfter(hoje)) {
      await _scheduleNotification(
        2,
        'Lembrete do Ciclo',
        'oii diva, se prepara que amanhã vem',
        umDiaAntesAs18,
      );
    }

    // Período fértil e ovulação
    final ovulacao = proximaMenstruacao.subtract(const Duration(days: 14));
    final inicioFertil = ovulacao.subtract(const Duration(days: 3));

    // Início do período fértil às 09:00
    final inicioFertilAs09 = DateTime(
      inicioFertil.year,
      inicioFertil.month,
      inicioFertil.day,
      9,
      0,
    );
    if (inicioFertilAs09.isAfter(hoje)) {
      await _scheduleNotification(
        4,
        'Período fértil',
        'olha o neném',
        inicioFertilAs09,
      );
    }

    // Dia da ovulação às 09:00
    final ovulacaoAs09 = DateTime(
      ovulacao.year,
      ovulacao.month,
      ovulacao.day,
      9,
      0,
    );
    if (ovulacaoAs09.isAfter(hoje)) {
      await _scheduleNotification(
        5,
        'Ovulação',
        'Hoje é o dia da ovulação.',
        ovulacaoAs09,
      );
    }

    // Notificação no dia às 09:00
    final noDiaAs09 = DateTime(
      proximaMenstruacao.year,
      proximaMenstruacao.month,
      proximaMenstruacao.day,
      9,
      0,
    );
    if (noDiaAs09.isAfter(hoje)) {
      await _scheduleNotification(
        3,
        'Lembrete do Ciclo',
        ' ela veio?',
        noDiaAs09,
      );
    }

    // Atraso de 3 dias às 09:00
    final atraso3Dias = proximaMenstruacao.add(const Duration(days: 3));
    final atraso3DiasAs09 = DateTime(
      atraso3Dias.year,
      atraso3Dias.month,
      atraso3Dias.day,
      9,
      0,
    );
    if (atraso3DiasAs09.isAfter(hoje)) {
      await _scheduleNotification(
        6,
        'Atraso menstrual',
        'oii, diva, sua menstruação está atrasada 3 dias — é normal; se tiver dúvidas, procure orientação.',
        atraso3DiasAs09,
      );
    }
  }

  /// Programa uma notificação específica
  Future<void> _scheduleNotification(int id, String title, String body, DateTime scheduledDate) async {
    // No Windows, apenas mostrar no console
    if (Platform.isWindows) {
      debugPrint('🔔 NOTIFICAÇÃO PROGRAMADA: $title - $body (para: $scheduledDate)');
      return;
    }

    final androidDetails = AndroidNotificationDetails(
      'period_channel',
      'Período',
      channelDescription: 'Notificações de ciclo menstrual',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );

    final platformDetails = NotificationDetails(android: androidDetails);

    try {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        _convertToTZDateTime(scheduledDate),
        platformDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
      debugPrint('Notificação programada para: $scheduledDate');
    } catch (e) {
      debugPrint('Erro ao programar notificação: $e');
    }
  }

  /// Converte DateTime para TZDateTime
  tz.TZDateTime _convertToTZDateTime(DateTime dateTime) {
    final location = tz.getLocation('America/Sao_Paulo');
    return tz.TZDateTime.from(dateTime, location);
  }

  /// Método de conveniência: inicializa + calcula + programa notificações.
  Future<void> atualizarUltimaMenstruacao(DateTime dataUltimaMenstruacao,
      {int cicloDias = 28}) async {
    await initNotifications();
    
    // Mostrar notificação imediata quando adicionar menstruação
    final daysLeft =
        calcularDiasParaProximaMenstruacao(dataUltimaMenstruacao, cicloDias: cicloDias);
    
    // Notificação imediata personalizada
    if (daysLeft > 0) {
      await showImmediateNotification(
        '✅ Menstruação Registrada!',
        'Próximo ciclo em $daysLeft dias. Te lembro 1 dia antes às 18:00.',
      );
    } else {
      await showImmediateNotification(
        '✅ Menstruação Registrada!',
        'Hoje é o dia. Ela veio?',
      );
    }
    
    // Programar notificações futuras
    await scheduleNotifications(dataUltimaMenstruacao, cicloDias: cicloDias);
  }

  /// Testa notificação manualmente (para desenvolvimento)
  Future<void> testNotification() async {
    await initNotifications();
    await showImmediateNotification(
      '🧪 Teste de Notificação',
      'Sistema de notificações funcionando perfeitamente!',
    );
  }

  /// Mostra notificação imediata personalizada para registro de menstruação
  Future<void> showImmediateNotification(String title, String body) async {
    // No Windows, mostrar no console
    if (Platform.isWindows) {
      debugPrint('🔔 NOTIFICAÇÃO IMEDIATA: $title - $body');
      return;
    }

    final androidDetails = AndroidNotificationDetails(
      'period_channel',
      'Período',
      channelDescription: 'Notificações de ciclo menstrual',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      enableLights: true,
      color: const Color.fromARGB(255, 255, 64, 129), // Rosa
    );

    final platformDetails = NotificationDetails(android: androidDetails);

    try {
      await _plugin.show(
        DateTime.now().millisecondsSinceEpoch.remainder(100000), // ID único
        title,
        body,
        platformDetails,
      );
      debugPrint('✅ Notificação imediata enviada: $title - $body');
    } catch (e) {
      debugPrint('❌ Erro ao enviar notificação imediata: $e');
    }
  }
}

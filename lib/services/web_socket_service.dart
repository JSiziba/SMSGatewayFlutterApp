import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smsgateway/models/sms_message.dart';
import 'package:smsgateway/services/config_service.dart';
import 'package:smsgateway/services/sms_service.dart';

import '../state/app_state_controller.dart';

class WebSocketService {
  static WebSocketService get to => Get.find<WebSocketService>();

  static ConfigService get configService => ConfigService.to;
  final smsService = SMSService.to;
  final appState = AppStateController.to;

  WebSocket? _webSocket;

  WebSocketService() {
    connectAndSubscribe();
  }

  void connectAndSubscribe() async {
    disconnect();
    final apiBase = configService.apiBaseUrl!;
    final apiKey = configService.apiKey!;
    debugPrint('Connecting to WebSocket at: $apiBase, API Key: $apiKey');
    final headers = {
      'X-Require-Whisk-Auth': apiKey,
    };
    var connectionString = 'wss://$apiBase/messages/ws';
    await connect(
      connectionString,
      headers: headers,
    );
    subscribe();
  }

  Future<void> connect(String url, {Map<String, String>? headers}) async {
    if (_webSocket != null) {
      debugPrint('WebSocket already connected');
      return;
    }
    appState.isConnecting = true;
    try {
      _webSocket = await WebSocket.connect(
        url,
        headers: headers ?? {},
      );
      appState.isConnected = true;
      debugPrint('Connected to WebSocket: $url');
    } catch (e) {
      debugPrint('Connection failed: $e');
      appState.serverError = 'Connection failed: $e';
      appState.isConnected = false;
    } finally {
      appState.isConnecting = false;
    }
  }

  void subscribe() {
    _webSocket?.listen(
      (message) {
        debugPrint('Received: $message');
        var sms = SMSMessage.fromJson(message);
        smsService.smsReceived(sms);
      },
      onError: (error) {
        debugPrint('WebSocket error: $error');
        disconnect();
      },
      onDone: () {
        debugPrint('WebSocket connection closed');
        disconnect();
      },
    );
  }

  void sendMessage(String message) {
    _webSocket?.add(message);
  }

  void disconnect() {
    _webSocket?.close();
    _webSocket = null;
    appState.isConnected = false;
    debugPrint('WebSocket disconnected');
  }
}

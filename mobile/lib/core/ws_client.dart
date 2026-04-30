import 'dart:convert';
import 'dart:io';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

class WsClient {
  final WebSocketChannel _channel;
  void Function(String type, Map<String, dynamic> payload)? onEvent;

  WsClient._(this._channel);

  factory WsClient.connect(String authToken) {
    final host = Platform.isAndroid ? '10.0.2.2' : 'localhost';
    final uri = Uri.parse('ws://$host:3000/ws?token=$authToken');
    return WsClient._(WebSocketChannel.connect(uri));
  }

  void listen() {
    _channel.stream.listen((message) {
      try {
        final decoded = jsonDecode(message.toString()) as Map<String, dynamic>;
        final type = decoded['type'] as String? ?? 'unknown';
        final payload = decoded['payload'] as Map<String, dynamic>? ?? {};
        onEvent?.call(type, payload);
      } catch (_) {
        // ignore malformed payloads
      }
    }, onError: (_) {
      // realtime connection issues are handled by provider
    });
  }

  void send(String type, Map<String, dynamic> payload) {
    _channel.sink.add(jsonEncode({'type': type, 'payload': payload}));
  }

  void dispose() {
    _channel.sink.close(status.goingAway);
  }
}

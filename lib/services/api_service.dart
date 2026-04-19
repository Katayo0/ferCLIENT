import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/io.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  IOWebSocketChannel? _channel;
  bool isConnected = false;
  bool _isMockMode = false;
  
  final List<Function(Map<String, dynamic>)> _listeners = [];
  Completer<bool>? _loginCompleter;

  void addListener(Function(Map<String, dynamic>) callback) => _listeners.add(callback);
  void setMockMode(bool enabled) => _isMockMode = enabled;

  Future<void> connect(String url) async {
    if (_isMockMode) return;
    try {
      _channel = IOWebSocketChannel.connect(url);
      isConnected = true;
      print("✅ Connected to $url");

      _channel!.stream.listen(
        (data) {
          try {
            final json = jsonDecode(data);
            final type = json['type'] ?? '';
            if (type == 'auth_ok' && _loginCompleter != null && !_loginCompleter!.isCompleted) {
              _loginCompleter!.complete(true); return;
            }
            if (type == 'auth_fail' && _loginCompleter != null && !_loginCompleter!.isCompleted) {
              _loginCompleter!.complete(false); return;
            }
            for (var l in _listeners) {
              try { l(json); } catch (_) {}
            }
          } catch (_) { /* игнор битой jsonки */ }
        },
        onDone: () {
          isConnected = false;
          print("🔌 WS Closed");
          if (_loginCompleter != null && !_loginCompleter!.isCompleted) {
            _loginCompleter!.complete(false);
          }
        },
        onError: (err) {
          isConnected = false;
          print("⚠️ WS Error: $err");
          if (_loginCompleter != null && !_loginCompleter!.isCompleted) {
            _loginCompleter!.complete(false);
          }
        },
        cancelOnError: true, 
      );
    } catch (e) {
      print("❌ Connect failed: $e");
      isConnected = false;
    }
  }

  Future<bool> login(String login, String password) async {
    if (_isMockMode) return true;
    if (!isConnected) return false;
    
    if (_loginCompleter != null && !_loginCompleter!.isCompleted) {
      _loginCompleter!.complete(false);
    }
    _loginCompleter = Completer<bool>();
    
    send({"type": "auth", "login": login, "password": password});
    
    try { 
      return await _loginCompleter!.future.timeout(const Duration(seconds: 5)); 
    } catch (_) { 
      return false; 
    }
  }

  void requestContacts() {
    if (_isMockMode || isConnected) send({"type": "get_contacts"});
  }

  void send(Map<String, dynamic> data) {
    if (_isMockMode) { _simulateMockResponse(data); return; }
    if (_channel != null && isConnected) {
      try { _channel!.sink.add(jsonEncode(data)); } catch (_) {}
    }
  }

  void disconnect() { 
    try { _channel?.sink.close(); } catch (_) {}
    isConnected = false; 
  }

  void _simulateMockResponse(Map<String, dynamic> request) {
    Future.delayed(const Duration(seconds: 1), () {
      final mock = {"type": "message", "sender_id": "bot", "text": "🤖 Эхо: ${request['text']}", "timestamp": DateTime.now().toIso8601String()};
      for (var l in _listeners) {
        try { l(mock); } catch (_) {}
      }
    });
  }
}
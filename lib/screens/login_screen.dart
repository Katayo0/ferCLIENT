import 'package:flutter/material.dart';
import 'package:fer_client/screens/chat_screen.dart';
import 'package:fer_client/services/api_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _loginCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _isLoading = false;
  final _api = ApiService();

  //настройки режима мока
  static const _mockLogin = 'gf23f23hef32k2334';
  static const _mockPass = 'v2569iv2xz436j6';
  //айпишник сервака
  static const _serverUrl = 'ws://192.168.1.100:8080/ws';

    Future<void> _doLogin() async {
    final login = _loginCtrl.text.trim();
    final pass = _passCtrl.text.trim();
    if (login.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      //режим мока
      if (login == _mockLogin && pass == _mockPass) {
        _api.setMockMode(true);
        await Future.delayed(const Duration(milliseconds: 600));
        if (!mounted) return;
        
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ChatScreen(myLogin: login, isMockMode: true)),
        );
        return;
      }
      if (!mounted) return;

      //обычная логика
      await _api.connect(_serverUrl);
      if (!mounted || _api.isMockMode) return;
      
      if (!_api.isConnected) {
        throw Exception('Нет связи с сервером');
      }

      final success = await _api.login(login, pass);
      if (!mounted) return;

      if (success) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ChatScreen(myLogin: login, isMockMode: false)),
        );
      } else {
        _showError('Ошибка авторизации');
      }
    } catch (e) {
      if (mounted && !_api.isMockMode) _showError('Ошибка: ${e.toString().replaceAll('Exception: ', '')}');
    } finally {
      if (mounted && !_api.isMockMode) setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: Colors.red.shade800),
      );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Center(
        child: Container(
          width: 300,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade800),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Вход в FER',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _loginCtrl,
                decoration: const InputDecoration(
                  labelText: 'Логин',
                  filled: true,
                  fillColor: Color(0xFF2C2C2C),
                ),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _passCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Пароль',
                  filled: true,
                  fillColor: Color(0xFF2C2C2C),
                ),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _doLogin,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Войти',
                          style: TextStyle(color: Colors.white),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

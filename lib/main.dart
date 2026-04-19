import 'package:flutter/material.dart';
import 'package:fer_client/screens/login_screen.dart';

void main() {
  runApp(const AgentApp());
}

class AgentApp extends StatelessWidget {
  const AgentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'fer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(), 
      home: const LoginScreen(), 
    );
    
  }
}
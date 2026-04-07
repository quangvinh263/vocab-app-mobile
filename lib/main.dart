import 'package:flutter/material.dart';
import 'screens/login_screen.dart'; // Import màn hình Login vừa tạo

void main() {
  runApp(const VocabApp());
}

class VocabApp extends StatelessWidget {
  const VocabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'App Học Từ Vựng',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // Gọi giao diện LoginScreen ra đây
      home: const LoginScreen(), 
    );
  }
}
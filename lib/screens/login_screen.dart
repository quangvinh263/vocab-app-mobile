import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'main_dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Bộ điều khiển để lấy dữ liệu từ ô nhập chữ
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  bool _isLoading = false; // Biến tạo hiệu ứng xoay xoay khi chờ Backend

  void _handleLogin() async {
    setState(() {
      _isLoading = true;
    });

    final apiService = ApiService();
    String username = _usernameController.text.trim();
    String password = _passwordController.text.trim();

    bool success = await apiService.login(username, password);

    setState(() {
      _isLoading = false;
    });

    if (!mounted) return; // Kiểm tra an toàn của Flutter

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainDashboard()),
      );
      // Chút nữa chúng ta sẽ viết code chuyển sang màn hình Trang chủ ở đây
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Sai tài khoản hoặc mật khẩu!'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Đăng Nhập', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.school, size: 100, color: Colors.blueAccent),
            const SizedBox(height: 30),
            
            // Ô nhập Tài khoản
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Tài khoản',
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 20),
            
            // Ô nhập Mật khẩu
            TextField(
              controller: _passwordController,
              obscureText: true, // Che mật khẩu thành dấu sao
              decoration: InputDecoration(
                labelText: 'Mật khẩu',
                prefixIcon: const Icon(Icons.lock),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 30),

            // Nút Đăng nhập
            SizedBox(
              width: double.infinity, // Nút rộng tràn màn hình
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: _isLoading ? null : _handleLogin,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('ĐĂNG NHẬP', style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
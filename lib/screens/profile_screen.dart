import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _handleLogout(BuildContext context) async {
    final apiService = ApiService();
    await apiService.logout();

    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cá Nhân'),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      // Sử dụng LayoutBuilder để tính toán chiều cao nếu cần
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              // Đảm bảo chiều cao tối thiểu bằng chiều cao màn hình để Spacer vẫn hoạt động nếu màn hình đủ lớn
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    const SizedBox(height: 30),
                    const Center(
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.blueAccent,
                        child: Icon(Icons.person, size: 50, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Nguyen Quang Vinh', // Tên lấy từ User Summary của bạn
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    const Text('nquangvinh263@gmail.com', style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 30),
                    const Divider(),
                    
                    ListTile(
                      leading: const Icon(Icons.settings, color: Colors.blueAccent),
                      title: const Text('Cài đặt ứng dụng'),
                      onTap: () {},
                    ),
                    ListTile(
                      leading: const Icon(Icons.history, color: Colors.blueAccent),
                      title: const Text('Lịch sử học tập'),
                      onTap: () {},
                    ),
                    
                    // Spacer giúp đẩy nút xuống dưới nếu còn chỗ, 
                    // nhưng trong SingleChildScrollView + IntrinsicHeight nó sẽ không gây lỗi
                    const Spacer(), 
                    
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.red),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () => _handleLogout(context),
                          icon: const Icon(Icons.logout, color: Colors.red),
                          label: const Text('ĐĂNG XUẤT', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
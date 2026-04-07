import 'package:flutter/material.dart';
import 'study_screen.dart';       // Import màn hình Học tập
import 'vocab_list_screen.dart';  // Import màn hình Kho từ vựng
import 'home_screen.dart';            // Import màn hình Trang chủ
import 'profile_screen.dart';         // Import màn hình Tài khoản
import 'add_vocab_screen.dart';         // Import màn hình Thêm từ vựng

class MainDashboard extends StatefulWidget {
  const MainDashboard({super.key});

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  // Mặc định khi mới vào sẽ ở Tab 0 (Trang chủ)
  int _selectedIndex = 0;

  // Hàm chuyển Tab khi bấm nút dưới đáy
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    
    final List<Widget> _screens = [
      const HomeScreen(),
      const VocabListScreen(),
      StudyScreen(onFinished: () => _onItemTapped(0)), 
      const ProfileScreen(),
    ];

    return Scaffold(
      // Phần thân hiển thị màn hình tương ứng
      body: _screens[_selectedIndex],
      
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          // Mở màn hình thêm từ vựng từ bất cứ đâu
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddVocabScreen()),
          ).then((_) {
            // Sau khi thêm xong và quay lại, có thể làm mới dữ liệu nếu cần
            setState(() {}); 
          });
        },
      ),
      // Thanh điều hướng dưới đáy (Bottom Navigation Bar)
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Trang chủ'),
          BottomNavigationBarItem(icon: Icon(Icons.library_books), label: 'Từ vựng'),
          BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Học tập'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Cá nhân'),
        ],
      ),
    );
  }
}
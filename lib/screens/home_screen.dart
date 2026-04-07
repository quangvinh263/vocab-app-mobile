import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  Map<String, dynamic> _stats = {'total': 0, 'learned': 0, 'newWords': 0};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);

    final stats = await _apiService.getStudyStats();
    await Future.delayed(const Duration(seconds: 1)); // Giả lập chờ 1s
    if (stats.isNotEmpty) {
      setState(() {
        _stats = stats;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Không thể tải thống kê')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tiến Độ Học Tập'), backgroundColor: Colors.blueAccent),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
          child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text('Thống kê từ vựng', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 30),
                  // BIỂU ĐỒ TRÒN
                  SizedBox(
                    height: 250,
                    child: PieChart(
                      PieChartData(
                        sections: [
                          PieChartSectionData(value: _stats['learned'].toDouble(), color: Colors.blue, title: 'Đã học', radius: 50),
                          PieChartSectionData(value: _stats['mastered'].toDouble(), color: Colors.green, title: 'Thuộc', radius: 50),
                          PieChartSectionData(value: _stats['newWords'].toDouble(), color: Colors.orange, title: 'Mới', radius: 50),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  // CÁC THẺ THÔNG TIN NHANH
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Expanded(child: _buildStatCard('Tổng số', _stats['total'].toString(), Colors.grey)),
                      Expanded(child: _buildStatCard('Cần học', _stats['newWords'].toString(), Colors.orange)),
                    ],
                  ),
                ],
              ),
            ),
        ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
            Text(label),
          ],
        ),
      ),
    );
  }
}
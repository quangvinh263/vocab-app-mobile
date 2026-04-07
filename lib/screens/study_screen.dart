import 'package:flutter/material.dart';
import '../services/api_service.dart';

class StudyScreen extends StatefulWidget {

  final VoidCallback? onFinished;

  const StudyScreen({super.key, this.onFinished});

  @override
  State<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends State<StudyScreen> {
  final ApiService _apiService = ApiService();
  List<dynamic> _tasks = [];
  int _currentIndex = 0;
  bool _isLoading = true;
  bool _showMeaning = false; // Biến kiểm soát việc lật thẻ

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  // Tải danh sách bài học
  Future<void> _loadTasks() async {
    final tasks = await _apiService.getTodayTasks();
    setState(() {
      _tasks = tasks;
      _isLoading = false;
    });
  }

  // Xử lý khi user chọn mức độ khó
  Future<void> _handleReview(int quality) async {
    final currentTask = _tasks[_currentIndex];
    final progressId = currentTask['id'];

    // Hiển thị vòng xoay loading mờ
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    // Gửi điểm xuống Backend
    bool success = await _apiService.submitReview(progressId, quality);
    
    // Đóng vòng xoay
    if (mounted) Navigator.pop(context);

    if (success) {
      setState(() {
        _currentIndex++;
        _showMeaning = false; // Úp thẻ lại cho từ tiếp theo
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lỗi khi lưu kết quả!'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Nếu đã học hết từ vựng
    if (_currentIndex >= _tasks.length) {
      return Scaffold(
        appBar: AppBar(title: const Text('Hoàn thành'), backgroundColor: Colors.green),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle, size: 100, color: Colors.green),
              const SizedBox(height: 20),
              const Text('Tuyệt vời! Bạn đã hoàn thành nhiệm vụ hôm nay.', 
                  style: TextStyle(fontSize: 18), textAlign: TextAlign.center),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (widget.onFinished != null) {
                    widget.onFinished!(); 
                  }
                },
                child: const Text('Trở về'),
              )
            ],
          ),
        ),
      );
    }

    // Giao diện Thẻ Flashcard
    final currentVocab = _tasks[_currentIndex]['vocabulary'];

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Học từ (${_currentIndex + 1}/${_tasks.length})'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Expanded(
              child: Card(
                elevation: 5,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Hiển thị Từ vựng
                      Text(
                        currentVocab['word'],
                        style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '(${currentVocab['partOfSpeech']})',
                        style: const TextStyle(fontSize: 18, fontStyle: FontStyle.italic, color: Colors.grey),
                      ),
                      const SizedBox(height: 30),
                      
                      // Hiển thị Nghĩa (nếu đã lật thẻ)
                      if (_showMeaning) ...[
                        const Divider(thickness: 2),
                        const SizedBox(height: 20),
                        Text(
                          currentVocab['meaning'],
                          style: const TextStyle(fontSize: 24, color: Colors.black87),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '"${currentVocab['exampleSentence']}"',
                          style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.blueGrey),
                          textAlign: TextAlign.center,
                        ),
                      ]
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Các nút điều khiển
            if (!_showMeaning)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                  onPressed: () => setState(() => _showMeaning = true),
                  child: const Text('XEM ĐÁP ÁN', style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildRateButton('Quên\n(Khó)', Colors.red, 1),
                  _buildRateButton('Khó\n(Nhớ chậm)', Colors.orange, 3),
                  _buildRateButton('Dễ\n(Nhớ ngay)', Colors.green, 5),
                ],
              ),
          ],
        ),
      ),
    );
  }

  // Hàm tạo nút đánh giá
  Widget _buildRateButton(String text, Color color, int quality) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onPressed: () => _handleReview(quality),
      child: Text(text, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white)),
    );
  }
}
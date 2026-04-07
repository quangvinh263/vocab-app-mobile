import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AddVocabScreen extends StatefulWidget {
  const AddVocabScreen({super.key});

  @override
  State<AddVocabScreen> createState() => _AddVocabScreenState();
}

class _AddVocabScreenState extends State<AddVocabScreen> {
  final ApiService _apiService = ApiService();
  
  // Các bộ điều khiển để lấy chữ từ bàn phím
  final TextEditingController _wordController = TextEditingController();
  final TextEditingController _meaningController = TextEditingController();
  final TextEditingController _exampleController = TextEditingController();
  
  // Loại từ mặc định
  String _partOfSpeech = 'Noun'; 
  final List<String> _posOptions = ['Noun', 'Verb', 'Adjective', 'Adverb', 'Pronoun', 'Preposition'];

  bool _isLoading = false;

  void _submitData() async {
    // Kiểm tra xem người dùng đã nhập đủ chưa
    if (_wordController.text.trim().isEmpty || _meaningController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập Từ vựng và Nghĩa!'), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _isLoading = true);

    bool success = await _apiService.addVocabulary(
      _wordController.text.trim(),
      _meaningController.text.trim(),
      _partOfSpeech,
      _exampleController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Đã thêm từ vựng thành công!'), backgroundColor: Colors.green),
      );
      // Xóa chữ trong ô để nhập từ khác
      _wordController.clear();
      _meaningController.clear();
      _exampleController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Lỗi! Có thể từ này đã tồn tại.'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thêm Từ Mới'),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _wordController,
              decoration: const InputDecoration(
                labelText: 'Từ vựng (Tiếng Anh)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.language),
              ),
            ),
            const SizedBox(height: 20),
            
            TextField(
              controller: _meaningController,
              decoration: const InputDecoration(
                labelText: 'Nghĩa (Tiếng Việt)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.translate),
              ),
            ),
            const SizedBox(height: 20),

            // Dropdown chọn loại từ
            DropdownButtonFormField<String>(
              value: _partOfSpeech,
              decoration: const InputDecoration(
                labelText: 'Từ loại',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
              items: _posOptions.map((String value) {
                return DropdownMenuItem<String>(value: value, child: Text(value));
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _partOfSpeech = newValue!;
                });
              },
            ),
            const SizedBox(height: 20),

            TextField(
              controller: _exampleController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Câu ví dụ',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.format_quote),
              ),
            ),
            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                onPressed: _isLoading ? null : _submitData,
                child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('LƯU TỪ VỰNG', style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
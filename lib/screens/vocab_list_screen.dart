import 'package:flutter/material.dart';
import '../services/api_service.dart';

class VocabListScreen extends StatefulWidget {
  const VocabListScreen({super.key});

  @override
  State<VocabListScreen> createState() => _VocabListScreenState();
}

class _VocabListScreenState extends State<VocabListScreen> {
  final ApiService _apiService = ApiService();
  List<dynamic> _vocabs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadVocabs();
  }

  Future<void> _loadVocabs() async {
    final vocabs = await _apiService.getAllVocabs();
    setState(() {
      // Đảo ngược danh sách để từ mới thêm hiện lên đầu
      _vocabs = vocabs.reversed.toList(); 
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Kho Từ Vựng (${_vocabs.length} từ)'),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _vocabs.isEmpty
              ? const Center(
                  child: Text(
                    'Kho từ vựng đang trống!\nHãy học thêm từ mới nhé.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: _vocabs.length,
                  itemBuilder: (context, index) {
                    final vocab = _vocabs[index];
                    return Dismissible(
                      // Key là bắt buộc để Flutter biết bạn đang vuốt cái thẻ nào
                      key: Key(vocab['id'].toString()), 
                      
                      // Chỉ cho phép vuốt từ Phải sang Trái
                      direction: DismissDirection.endToStart, 
                      
                      // Nền màu đỏ hiện ra khi vuốt
                      background: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: const Icon(Icons.delete, color: Colors.white, size: 30),
                      ),
                      
                      // Hỏi xác nhận trước khi xóa thật
                      confirmDismiss: (direction) async {
                        return await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text("Xác nhận xóa"),
                              content: Text('Bạn có chắc muốn xóa từ "${vocab['word']}" không?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(false), 
                                  child: const Text("Hủy")
                                ),
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(true), 
                                  child: const Text("Xóa", style: TextStyle(color: Colors.red))
                                ),
                              ],
                            );
                          },
                        );
                      },
                      
                      // Hành động xảy ra SAU KHI người dùng bấm "Xóa"
                      onDismissed: (direction) async {
                        // 1. Lưu lại từ đang bị xóa để phòng hờ gọi API lỗi
                        final deletedVocab = vocab;
                        
                        // 2. Xóa ngay lập tức trên giao diện cho mượt
                        setState(() {
                          _vocabs.removeAt(index);
                        });

                        // 3. Gọi API xóa dưới Database
                        bool success = await _apiService.deleteVocabulary(vocab['id']);

                        if (success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Đã xóa "${deletedVocab['word']}"'), backgroundColor: Colors.green),
                          );
                        } else {
                          // 4. Nếu API lỗi, hoàn tác (hiện lại thẻ vừa xóa)
                          setState(() {
                            _vocabs.insert(index, deletedVocab);
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Lỗi! Không thể xóa từ này.'), backgroundColor: Colors.red),
                          );
                        }
                      },
                      
                      // Đứa con bên trong (Chính là cái Card cũ của bạn)
                      child: Card(
                        elevation: 2,
                        margin: const EdgeInsets.only(bottom: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        child: ExpansionTile(
                          title: Text(
                            vocab['word'],
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                          ),
                          subtitle: Text(
                            vocab['partOfSpeech'],
                            style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
                          ),
                          children: [
                            Container(
                              padding: const EdgeInsets.all(15),
                              width: double.infinity,
                              color: Colors.blue[50],
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Nghĩa: ${vocab['meaning']}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                                  const SizedBox(height: 5),
                                  Text('Ví dụ: "${vocab['exampleSentence']}"', style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: Colors.blueGrey)),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
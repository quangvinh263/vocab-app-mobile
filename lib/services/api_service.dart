import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class ApiService {
  
  // HÀM ĐĂNG NHẬP
  Future<bool> login(String username, String password) async {
    final url = Uri.parse('${Constants.baseUrl}/auth/login');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        // 1. Lấy Token từ Spring Boot trả về
        final data = jsonDecode(response.body);
        final token = data['token'];

        // 2. Cất Token vào bộ nhớ của trình duyệt/điện thoại
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', token);

        print('🎉 THÀNH CÔNG: Đã lấy được Token: $token');
        return true;
      } else {
        print('❌ THẤT BẠI: Sai tài khoản hoặc mật khẩu! (${response.body})');
        return false;
      }
    } catch (e) {
      print('⚠️ LỖI KẾT NỐI: Spring Boot có đang chạy không? Chi tiết: $e');
      return false;
    }
  }
  
  // HÀM LẤY TOKEN TỪ BỘ NHỚ
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  // HÀM ĐĂNG XUẤT (Tặng kèm luôn cho bạn)
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
  }
    // 1. HÀM LẤY NHIỆM VỤ HÔM NAY
  Future<List<dynamic>> getTodayTasks() async {
    final token = await getToken(); // Lấy thẻ VIP từ bộ nhớ
    if (token == null) return [];

    final url = Uri.parse('${Constants.baseUrl}/study/today');
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Đưa thẻ VIP cho bảo vệ Spring Boot
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes)); // Xử lý lỗi font tiếng Việt
      }
    } catch (e) {
      print('Lỗi lấy bài học: $e');
    }
    return [];
  }

  // 2. HÀM NỘP ĐIỂM ĐÁNH GIÁ (SM-2)
  Future<bool> submitReview(int progressId, int quality) async {
    final token = await getToken();
    if (token == null) return false;

    final url = Uri.parse('${Constants.baseUrl}/study/review');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'progressId': progressId,
          'quality': quality,
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Lỗi nộp điểm: $e');
      return false;
    }
  }

  // HÀM THÊM TỪ VỰNG MỚI
  Future<bool> addVocabulary(String word, String meaning, String partOfSpeech, String example) async {
    final token = await getToken();
    if (token == null) return false;

    final url = Uri.parse('${Constants.baseUrl}/vocabularies');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'word': word,
          'meaning': meaning,
          'partOfSpeech': partOfSpeech,
          'exampleSentence': example,
        }),
      );
      
      // Thành công là mã 200 (hoặc 201 tùy Spring Boot)
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Lỗi thêm từ vựng: $e');
      return false;
    }
  }

  // HÀM LẤY TOÀN BỘ KHO TỪ VỰNG
  Future<List<dynamic>> getAllVocabs() async {
    final token = await getToken();
    if (token == null) return [];

    final url = Uri.parse('${Constants.baseUrl}/vocabularies');
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        // Dùng utf8.decode để không bị lỗi font tiếng Việt nhé
        return jsonDecode(utf8.decode(response.bodyBytes)); 
      }
    } catch (e) {
      print('Lỗi lấy kho từ vựng: $e');
    }
    return [];
  }

  // HÀM XÓA TỪ VỰNG
  Future<bool> deleteVocabulary(int id) async {
    final token = await getToken();
    if (token == null) return false;

    // Gọi API xóa theo ID của từ vựng
    final url = Uri.parse('${Constants.baseUrl}/vocabularies/$id');
    try {
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      
      // Xóa thành công thường trả về mã 200 hoặc 204
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print('Lỗi xóa từ vựng: $e');
      return false;
    }
  }

  // HÀM LẤY THỐNG KÊ HỌC TẬP
  Future<Map<String, dynamic>> getStudyStats() async {
    final token = await getToken();
    if (token == null) return {};

    final url = Uri.parse('${Constants.baseUrl}/study/stats'); 
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print('Lỗi lấy thống kê: $e');
    }
    return {};
  }
}
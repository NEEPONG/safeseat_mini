import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:safeseat_mini/core/constants/api_constants.dart';
import 'package:safeseat_mini/core/models/user_model.dart';
import 'package:safeseat_mini/core/controllers/user_controller.dart';

class AuthController extends StateNotifier<bool> {
  final Ref ref;

  AuthController(this.ref) : super(false); // state represents 'isLoading'

  Future<String?> login(String phone, String password) async {
    if (phone.isEmpty || password.isEmpty) {
      return 'กรุณากรอกข้อมูลให้ครบถ้วน';
    }

    state = true;
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}/api/user/auth/login');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': phone, 'password': password}),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final userModel = UserModel.fromJson(responseData['user']);
        ref.read(userProvider.notifier).setUser(userModel);
        state = false;
        return null; // Null means success
      } else {
        state = false;
        return responseData['error'] ?? 'เข้าสู่ระบบไม่สำเร็จ';
      }
    } catch (error) {
      state = false;
      return 'เกิดข้อผิดพลาดในการเชื่อมต่อกับเซิร์ฟเวอร์';
    }
  }

  Future<String?> register(
    String phone,
    String name,
    int gender,
    String email,
    String password,
  ) async {
    state = true;
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}/api/user/auth/register');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phone': phone,
          'name': name,
          'gender': gender,
          'email': email,
          'password': password,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 201) {
        state = false;
        return null; // Null means success
      } else {
        state = false;
        return responseData['error'] ?? 'สร้างบัญชีไม่สำเร็จ';
      }
    } catch (error) {
      state = false;
      return 'เกิดข้อผิดพลาดในการเชื่อมต่อกับเซิร์ฟเวอร์';
    }
  }
}

final authControllerProvider = StateNotifierProvider<AuthController, bool>((
  ref,
) {
  return AuthController(ref);
});

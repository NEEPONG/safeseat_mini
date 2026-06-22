import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:safeseat_mini/core/constants/api_constants.dart';
import 'package:safeseat_mini/data/models/user_model.dart';

class AuthRepository {
  Future<UserModel> login(String phone, String password) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/api/user/auth/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phone': phone, 'password': password}),
    );

    final responseData = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return UserModel.fromJson(responseData['user']);
    } else {
      throw Exception(responseData['error'] ?? 'เข้าสู่ระบบไม่สำเร็จ');
    }
  }

  Future<void> register(
    String phone,
    String name,
    int gender,
    String email,
    String password,
  ) async {
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

    if (response.statusCode != 201) {
      final responseData = jsonDecode(response.body);
      throw Exception(responseData['error'] ?? 'สร้างบัญชีไม่สำเร็จ');
    }
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

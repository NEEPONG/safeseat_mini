import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:safeseat_mini/core/models/user_model.dart';
import 'package:safeseat_mini/core/controllers/user_controller.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:safeseat_mini/core/constants/api_constants.dart';

class ProfileController extends Notifier<bool> {
  @override
  bool build() {
    return false; // represents isLoading state
  }

  /// ดึงข้อมูลโปรไฟล์ผู้ใช้ล่าสุดจากเซิร์ฟเวอร์
  Future<UserModel?> getUserProfile(String phoneNo) async {
    state = true;
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}/api/user/profile/$phoneNo');
      final response = await http.get(url, headers: {'Content-Type': 'application/json'});
      
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final userModel = UserModel.fromJson(responseData['user']);
        
        // Update global user state
        ref.read(userProvider.notifier).setUser(userModel);
        state = false;
        return userModel;
      }
    } catch (e) {
      // Handle error implicitly
    }
    state = false;
    // Return current state if fetch fails or as fallback
    return ref.read(userProvider);
  }

  /// ส่งข้อมูลอัปเดตโปรไฟล์ไปยังเซิร์ฟเวอร์
  Future<bool> editProfile(UserModel updatedUser) async {
    state = true;
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}/api/user/profile/update');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(updatedUser.toJson()),
      );

      if (response.statusCode == 200) {
        ref.read(userProvider.notifier).setUser(updatedUser);
        state = false;
        return true;
      } else {
        state = false;
        return false;
      }
    } catch (e) {
      state = false;
      return false;
    }
  }
}

final profileControllerProvider = NotifierProvider<ProfileController, bool>(() {
  return ProfileController();
});

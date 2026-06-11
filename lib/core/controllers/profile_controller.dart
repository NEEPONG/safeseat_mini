import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:safeseat_mini/core/models/user_model.dart';
import 'package:safeseat_mini/core/controllers/user_controller.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:safeseat_mini/core/constants/api_constants.dart';

import 'package:safeseat_mini/core/models/car_model.dart';
import 'package:safeseat_mini/core/models/cartype_model.dart';

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

  Future<bool> addUserCar(CarModel car) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}/api/user/profile/car');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(car.toJson()),
      );
      if (response.statusCode == 201) {
        // Refresh cars
        ref.invalidate(userCarListProvider(car.userId));
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteUserCar(int carId, String phoneNo) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}/api/user/profile/car/$carId');
      final response = await http.delete(url);
      if (response.statusCode == 200) {
        // Refresh cars
        ref.invalidate(userCarListProvider(phoneNo));
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}

final profileControllerProvider = NotifierProvider<ProfileController, bool>(() {
  return ProfileController();
});

final userCarListProvider = FutureProvider.family<List<CarModel>, String>((ref, phoneNo) async {
  final url = Uri.parse('${ApiConstants.baseUrl}/api/user/profile/car/$phoneNo');
  final response = await http.get(url, headers: {'Content-Type': 'application/json'});
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final List carsJson = data['cars'];
    return carsJson.map((json) => CarModel.fromJson(json)).toList();
  }
  return [];
});

final carTypeProvider = FutureProvider<List<CarTypeModel>>((ref) async {
  final url = Uri.parse('${ApiConstants.baseUrl}/api/user/profile/cartype/all');
  final response = await http.get(url, headers: {'Content-Type': 'application/json'});
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final List typesJson = data['carTypes'];
    return typesJson.map((json) => CarTypeModel.fromJson(json)).toList();
  }
  return [];
});

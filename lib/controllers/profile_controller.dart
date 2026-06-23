import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:safeseat_mini/data/models/user_model.dart';
import 'package:safeseat_mini/controllers/user_controller.dart';
import 'package:safeseat_mini/data/models/car_model.dart';
import 'package:safeseat_mini/data/models/cartype_model.dart';
import 'package:safeseat_mini/data/repositories/profile_repository.dart';

class ProfileController extends Notifier<bool> {
  @override
  bool build() {
    return false; // represents isLoading state
  }

  /// ดึงข้อมูลโปรไฟล์ผู้ใช้ล่าสุดจากเซิร์ฟเวอร์
  Future<UserModel?> getUserProfile(String phoneNo) async {
    state = true;
    try {
      final repository = ref.read(profileRepositoryProvider);
      final userModel = await repository.getUserProfile(phoneNo);
      
      // Update global user state
      ref.read(userProvider.notifier).setUser(userModel);
      state = false;
      return userModel;
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
      final repository = ref.read(profileRepositoryProvider);
      await repository.editProfile(updatedUser);
      
      ref.read(userProvider.notifier).setUser(updatedUser);
      state = false;
      return true;
    } catch (e) {
      state = false;
      return false;
    }
  }

  Future<bool> addUserCar(CarModel car) async {
    try {
      final repository = ref.read(profileRepositoryProvider);
      await repository.addUserCar(car);
      
      // Refresh cars
      ref.invalidate(userCarListProvider(car.userId));
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteUserCar(int carId, String phoneNo) async {
    try {
      final repository = ref.read(profileRepositoryProvider);
      await repository.deleteUserCar(carId, phoneNo);
      
      // Refresh cars
      ref.invalidate(userCarListProvider(phoneNo));
      return true;
    } catch (e) {
      return false;
    }
  }
}

final profileControllerProvider = NotifierProvider<ProfileController, bool>(() {
  return ProfileController();
});

final userCarListProvider = FutureProvider.family<List<CarModel>, String>((ref, phoneNo) async {
  final repository = ref.read(profileRepositoryProvider);
  return repository.fetchUserCars(phoneNo);
});

final carTypeProvider = FutureProvider<List<CarTypeModel>>((ref) async {
  final repository = ref.read(profileRepositoryProvider);
  return repository.fetchCarTypes();
});


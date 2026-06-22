import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:safeseat_mini/data/repositories/auth_repository.dart';
import 'package:safeseat_mini/controllers/user_controller.dart';

class AuthController extends Notifier<bool> {
  @override
  bool build() {
    return false; // state represents 'isLoading'
  }

  Future<String?> login(String phone, String password) async {
    if (phone.isEmpty || password.isEmpty) {
      return 'กรุณากรอกข้อมูลให้ครบถ้วน';
    }

    state = true;
    try {
      final repository = ref.read(authRepositoryProvider);
      final userModel = await repository.login(phone, password);
      
      ref.read(userProvider.notifier).setUser(userModel);
      state = false;
      return null; // Null means success
    } catch (error) {
      state = false;
      return error.toString().replaceAll('Exception: ', '');
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
      final repository = ref.read(authRepositoryProvider);
      await repository.register(phone, name, gender, email, password);
      
      state = false;
      return null; // Null means success
    } catch (error) {
      state = false;
      return error.toString().replaceAll('Exception: ', '');
    }
  }
}

final authControllerProvider = NotifierProvider<AuthController, bool>(() {
  return AuthController();
});

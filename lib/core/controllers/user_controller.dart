import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:safeseat_mini/core/models/user_model.dart';

class UserController extends Notifier<UserModel?> {
  @override
  UserModel? build() {
    return null;
  }

  void setUser(UserModel user) {
    state = user;
  }

  void clearUser() {
    state = null;
  }

  void updateUserField({
    String? phoneNo,
    String? email,
    int? gender,
    String? mainAddress,
    String? name,
    String? profileImagePath,
    num? walletBalance,
  }) {
    if (state != null) {
      state = state!.copyWith(
        phoneNo: phoneNo,
        email: email,
        gender: gender,
        mainAddress: mainAddress,
        name: name,
        profileImagePath: profileImagePath,
        walletBalance: walletBalance,
      );
    }
  }
}

final userProvider = NotifierProvider<UserController, UserModel?>(() {
  return UserController();
});

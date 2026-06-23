class UserModel {
  final String phoneNo;
  final String email;
  final int gender;
  final String? mainAddress;
  final String name;
  final String? profileImagePath;
  final num walletBalance;

  UserModel({
    required this.phoneNo,
    required this.email,
    required this.gender,
    this.mainAddress,
    required this.name,
    this.profileImagePath,
    this.walletBalance = 0.0,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      phoneNo: json['phoneno'] ?? '',
      email: json['email'] ?? '',
      gender: json['gender'] ?? 0,
      mainAddress: json['mainaddress'],
      name: json['name'] ?? '',
      profileImagePath: json['profileimagepath'],
      walletBalance: json['walletbalance'] ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'phoneno': phoneNo,
      'email': email,
      'gender': gender,
      'mainaddress': mainAddress,
      'name': name,
      'profileimagepath': profileImagePath,
      'walletbalance': walletBalance,
    };
  }

  UserModel copyWith({
    String? phoneNo,
    String? email,
    int? gender,
    String? mainAddress,
    String? name,
    String? profileImagePath,
    num? walletBalance,
  }) {
    return UserModel(
      phoneNo: phoneNo ?? this.phoneNo,
      email: email ?? this.email,
      gender: gender ?? this.gender,
      mainAddress: mainAddress ?? this.mainAddress,
      name: name ?? this.name,
      profileImagePath: profileImagePath ?? this.profileImagePath,
      walletBalance: walletBalance ?? this.walletBalance,
    );
  }
}

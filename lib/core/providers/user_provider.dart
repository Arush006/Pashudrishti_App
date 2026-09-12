import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserModel {
  final String fullName;
  final String email;
  final String phone;
  final String role;
  final String token;

  const UserModel({
    this.fullName = 'Guest User',
    this.email = 'guest@example.com',
    this.phone = '',
    this.role = 'Livestock Owner',
    this.token = '',
  });

  UserModel copyWith({
    String? fullName,
    String? email,
    String? phone,
    String? role,
    String? token,
  }) {
    return UserModel(
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      token: token ?? this.token,
    );
  }
}

class UserNotifier extends StateNotifier<UserModel> {
  UserNotifier() : super(const UserModel());

  void updateUser({String? fullName, String? email, String? phone, String? role, String? token}) {
    state = state.copyWith(
      fullName: fullName,
      email: email,
      phone: phone,
      role: role,
      token: token,
    );
  }
}

final userProvider = StateNotifierProvider<UserNotifier, UserModel>((ref) {
  return UserNotifier();
});

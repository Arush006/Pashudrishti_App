import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserModel {
  final String fullName;
  final String email;
  final String phone;
  final String role;

  const UserModel({
    this.fullName = 'Guest User',
    this.email = 'guest@example.com',
    this.phone = '',
    this.role = 'Livestock Owner',
  });

  UserModel copyWith({
    String? fullName,
    String? email,
    String? phone,
    String? role,
  }) {
    return UserModel(
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
    );
  }
}

class UserNotifier extends StateNotifier<UserModel> {
  UserNotifier() : super(const UserModel());

  void updateUser({String? fullName, String? email, String? phone, String? role}) {
    state = state.copyWith(
      fullName: fullName,
      email: email,
      phone: phone,
      role: role,
    );
  }
}

final userProvider = StateNotifierProvider<UserNotifier, UserModel>((ref) {
  return UserNotifier();
});

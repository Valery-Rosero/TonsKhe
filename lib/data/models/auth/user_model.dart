import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../domain/entities/auth/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.username,
    super.email,
    super.phone,
    super.avatarUrl,
    required super.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      username: json['username'] as String,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Combines a Supabase Auth [User] with its matching row from the
  /// `profiles` table (created automatically by the `handle_new_user` trigger).
  factory UserModel.fromSupabase(User authUser, Map<String, dynamic> profile) {
    return UserModel(
      id: authUser.id,
      username: profile['username'] as String,
      email: authUser.email,
      phone: authUser.phone?.isEmpty ?? true ? null : authUser.phone,
      avatarUrl: profile['avatar_url'] as String?,
      createdAt: DateTime.parse(profile['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'phone': phone,
      'avatar_url': avatarUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

// ignore_for_file: public_member_api_docs, sort_constructors_first
import '../../domain/entities/user.dart';

class UserModel {
  final String email;
  final String fullName;

  UserModel({required this.email, required this.fullName});

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      email: map['email'] as String? ?? '',
      fullName: map['fullName'] as String? ?? '',
    );
  }
}

extension UserXModel on UserModel {
  UserEntity toEntity() {
    return UserEntity(email: email, fullName: fullName);
  }
}

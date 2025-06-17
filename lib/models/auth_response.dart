
// lib/models/auth_response.dart
import '../models/user.dart';
import '../models/hospital.dart';

class AuthResponse {
  final String token;
  final User user;
  final Hospital hospital;

  AuthResponse({
    required this.token,
    required this.user,
    required this.hospital,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] ?? '',
      user: User.fromJson(json['user'] ?? {}),
      hospital: Hospital.fromJson(json['hospital'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'user': user.toJson(),
      'hospital': hospital.toJson(),
    };
  }
}

// lib/models/block.dart
class Block {
  final int id;
  final String name;
  final String? description;
  final int hospitalId;

  Block({
    required this.id,
    required this.name,
    this.description,
    required this.hospitalId,
  });

  factory Block.fromJson(Map<String, dynamic> json) {
    return Block(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'],
      hospitalId: json['hospital_id'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'hospital_id': hospitalId,
    };
  }
}
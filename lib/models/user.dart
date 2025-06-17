// lib/models/user.dart
class User {
  final int id;
  final String institutionId;
  final String role;
  final String phoneNumber;
  final String? fcmToken;
  final DateTime? fcmTokenUpdatedAt;
  final String? currentBlockName;
  final int? currentBlockId;
  final int hospitalId;
  final bool isApprover;
  final bool isSuperuser;
  final bool isResponder;
  final bool isCreator;

  User({
    required this.id,
    required this.institutionId,
    required this.role,
    required this.phoneNumber,
    this.fcmToken,
    this.fcmTokenUpdatedAt,
    this.currentBlockName,
    this.currentBlockId,
    required this.hospitalId,
    required this.isApprover,
    required this.isSuperuser,
    required this.isResponder,
    required this.isCreator,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      institutionId: json['institution_id'] ?? '',
      role: json['role'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      fcmToken: json['fcm_token'],
      fcmTokenUpdatedAt: json['fcm_token_updated_at'] != null 
          ? DateTime.parse(json['fcm_token_updated_at'])
          : null,
      currentBlockName: json['current_block_name'],
      currentBlockId: json['current_block_id'],
      hospitalId: json['hospital_id'] ?? 0,
      isApprover: json['is_approver'] ?? false,
      isSuperuser: json['is_superuser'] ?? false,
      isResponder: json['is_responder'] ?? false,
      isCreator: json['is_creator'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'institution_id': institutionId,
      'role': role,
      'phone_number': phoneNumber,
      'fcm_token': fcmToken,
      'fcm_token_updated_at': fcmTokenUpdatedAt?.toIso8601String(),
      'current_block_name': currentBlockName,
      'current_block_id': currentBlockId,
      'hospital_id': hospitalId,
      'is_approver': isApprover,
      'is_superuser': isSuperuser,
      'is_responder': isResponder,
      'is_creator': isCreator,
    };
  }

  User copyWith({
    int? id,
    String? institutionId,
    String? role,
    String? phoneNumber,
    String? fcmToken,
    DateTime? fcmTokenUpdatedAt,
    String? currentBlockName,
    int? currentBlockId,
    int? hospitalId,
    bool? isApprover,
    bool? isSuperuser,
    bool? isResponder,
    bool? isCreator,
  }) {
    return User(
      id: id ?? this.id,
      institutionId: institutionId ?? this.institutionId,
      role: role ?? this.role,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      fcmToken: fcmToken ?? this.fcmToken,
      fcmTokenUpdatedAt: fcmTokenUpdatedAt ?? this.fcmTokenUpdatedAt,
      currentBlockName: currentBlockName ?? this.currentBlockName,
      currentBlockId: currentBlockId ?? this.currentBlockId,
      hospitalId: hospitalId ?? this.hospitalId,
      isApprover: isApprover ?? this.isApprover,
      isSuperuser: isSuperuser ?? this.isSuperuser,
      isResponder: isResponder ?? this.isResponder,
      isCreator: isCreator ?? this.isCreator,
    );
  }
}
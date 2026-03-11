class UserModel {
  final String uid;
  final String name;
  final String email;
  final String role; // 'Admin', 'Driver', 'Student'
  final String? fcmToken;
  final DateTime? createdAt;
  final String? phoneNumber;
  final String? assignedBusId; // For drivers
  final String? assignedRouteId; // For students - KEPT BUT RENAMED
  final String? selectedRouteId; // NEW - For students to select their route

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    this.fcmToken,
    this.createdAt,
    this.phoneNumber,
    this.assignedBusId,
    this.assignedRouteId,
    this.selectedRouteId, // NEW
  });

  // Convert from JSON (Firebase)
  factory UserModel.fromJson(Map<dynamic, dynamic> json, String uid) {
    return UserModel(
      uid: uid,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? 'Student',
      fcmToken: json['fcmToken'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      phoneNumber: json['phoneNumber'] as String?,
      assignedBusId: json['assignedBusId'] as String?,
      assignedRouteId: json['assignedRouteId'] as String?,
      selectedRouteId: json['selectedRouteId'] as String?, // NEW
    );
  }

  // Convert to JSON (Firebase)
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'role': role,
      'fcmToken': fcmToken,
      'createdAt': createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
      'phoneNumber': phoneNumber,
      'assignedBusId': assignedBusId,
      'assignedRouteId': assignedRouteId,
      'selectedRouteId': selectedRouteId, // NEW
    };
  }

  // Copy with method for updates
  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? role,
    String? fcmToken,
    DateTime? createdAt,
    String? phoneNumber,
    String? assignedBusId,
    String? assignedRouteId,
    String? selectedRouteId, // NEW
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      fcmToken: fcmToken ?? this.fcmToken,
      createdAt: createdAt ?? this.createdAt,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      assignedBusId: assignedBusId ?? this.assignedBusId,
      assignedRouteId: assignedRouteId ?? this.assignedRouteId,
      selectedRouteId: selectedRouteId ?? this.selectedRouteId, // NEW
    );
  }

  // Check if user is admin
  bool get isAdmin => role.toLowerCase() == 'admin';

  // Check if user is driver
  bool get isDriver => role.toLowerCase() == 'driver';

  // Check if user is student
  bool get isStudent => role.toLowerCase() == 'student';
}
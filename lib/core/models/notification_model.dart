class NotificationModel {
  final String notificationId;
  final String title;
  final String body;
  final DateTime timestamp;
  final bool isRead;
  final String? imageUrl;
  final String? type; // 'info', 'alert', 'update', 'emergency'
  final Map<String, dynamic>? data;

  NotificationModel({
    required this.notificationId,
    required this.title,
    required this.body,
    required this.timestamp,
    this.isRead = false,
    this.imageUrl,
    this.type = 'info',
    this.data,
  });

  factory NotificationModel.fromJson(Map<dynamic, dynamic> json, String notificationId) {
    return NotificationModel(
      notificationId: notificationId,
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
      isRead: json['isRead'] as bool? ?? false,
      imageUrl: json['imageUrl'] as String?,
      type: json['type'] as String? ?? 'info',
      data: json['data'] != null
          ? Map<String, dynamic>.from(json['data'] as Map)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'body': body,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'imageUrl': imageUrl,
      'type': type,
      'data': data,
    };
  }

  // Get formatted time
  String get formattedTime {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  // Copy with method
  NotificationModel copyWith({
    String? notificationId,
    String? title,
    String? body,
    DateTime? timestamp,
    bool? isRead,
    String? imageUrl,
    String? type,
    Map<String, dynamic>? data,
  }) {
    return NotificationModel(
      notificationId: notificationId ?? this.notificationId,
      title: title ?? this.title,
      body: body ?? this.body,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      imageUrl: imageUrl ?? this.imageUrl,
      type: type ?? this.type,
      data: data ?? this.data,
    );
  }
}
class LiveLocationModel {
  final String busId;
  final double latitude;
  final double longitude;
  final double? speed;
  final bool? ignition;
  final DateTime lastUpdated;
  final String? deviceId;

  LiveLocationModel({
    required this.busId,
    required this.latitude,
    required this.longitude,
    this.speed,
    this.ignition,
    required this.lastUpdated,
    this.deviceId,
  });

  factory LiveLocationModel.fromJson(Map<dynamic, dynamic> json, String busId) {
    return LiveLocationModel(
      busId: busId,
      latitude: json['lat'] != null
          ? (json['lat'] is int ? (json['lat'] as int).toDouble() : json['lat'] as double)
          : 0.0,
      longitude: json['lng'] != null
          ? (json['lng'] is int ? (json['lng'] as int).toDouble() : json['lng'] as double)
          : 0.0,
      speed: json['speed'] != null
          ? (json['speed'] is int ? (json['speed'] as int).toDouble() : json['speed'] as double)
          : null,
      ignition: json['ignition'] as bool?,
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'] as String)
          : DateTime.now(),
      deviceId: json['deviceId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lat': latitude,
      'lng': longitude,
      'speed': speed,
      'ignition': ignition,
      'lastUpdated': lastUpdated.toIso8601String(),
      'deviceId': deviceId,
    };
  }

  bool get isStale {
    return DateTime.now().difference(lastUpdated).inSeconds > 60;
  }

  String get formattedSpeed {
    if (speed == null) return 'N/A';
    return '${speed!.toStringAsFixed(0)} km/h';
  }

  LiveLocationModel copyWith({
    String? busId,
    double? latitude,
    double? longitude,
    double? speed,
    bool? ignition,
    DateTime? lastUpdated,
    String? deviceId,
  }) {
    return LiveLocationModel(
      busId: busId ?? this.busId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      speed: speed ?? this.speed,
      ignition: ignition ?? this.ignition,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      deviceId: deviceId ?? this.deviceId,
    );
  }
}
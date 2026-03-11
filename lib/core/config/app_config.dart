class AppConfig {
  // ========================================
  // DEMO MODE TOGGLE - CHANGE THIS ONE LINE
  // ========================================
  static const bool USE_DEMO_MODE = true;  // ← SET TO false FOR PRODUCTION

  // WheelsEye API Configuration (Production Mode)
  static const String wheelsEyeBaseUrl = 'https://api.wheelseye.com/v1';
  static const String wheelsEyeApiKey = 'YOUR_WHEELSEYE_API_KEY_HERE';

  // API Endpoints
  static const String trackingEndpoint = '/tracking/device';

  // Update intervals (in seconds)
  static const int locationUpdateInterval = 5;
  static const int cacheExpirySeconds = 30;

  // Map Configuration
  static const double defaultMapZoom = 14.0;
  static const double selectedBusZoom = 16.0;

  // Firebase Configuration
  static const String firebaseRealtimeDatabaseUrl = 'YOUR_FIREBASE_URL';

  // Demo Mode Configuration ← ADD THIS SECTION
  static const double minimumSpeedForMoving = 0.5; // meters per second
  static const int demoLocationUpdateInterval = 3; // seconds (faster for demo)

  // Build full API URL
  static String getTrackingUrl(String deviceId) {
    return '$wheelsEyeBaseUrl$trackingEndpoint/$deviceId';
  }

  // Validation
  static bool get isConfigured {
    if (USE_DEMO_MODE) {
      return true; // ← Demo mode always configured
    }
    return wheelsEyeApiKey != 'YOUR_WHEELSEYE_API_KEY_HERE';
  }
}
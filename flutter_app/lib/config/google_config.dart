// Google OAuth Configuration
class GoogleConfig {
  // Web Client ID (from Google Cloud Console)
  // This is a test client ID - replace with your own for production
  static const String webClientId = '1071453270740-qojgn6bfqf2dhinr2etkmd92f0has46n.apps.googleusercontent.com';
  
  // Android Client ID (optional - for Android app)
  static const String? androidClientId = null;
  
  // iOS Client ID (optional - for iOS app)
  static const String? iosClientId = null;
  
  // For development/testing, you can use null and it will work
  // For production, get your own Client ID from:
  // https://console.cloud.google.com
}

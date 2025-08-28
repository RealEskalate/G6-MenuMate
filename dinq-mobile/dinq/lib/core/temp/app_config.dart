/// Configuration for demo mode
/// This file controls whether the app uses demo data or real API calls
class AppConfig {
  /// Whether to use demo mode (mock data) instead of real API
  static bool useDemoMode = true;

  /// API base URL for production
  static const String productionBaseUrl = 'https://api.dineq.com';

  /// API base URL for development
  static const String developmentBaseUrl = 'http://localhost:8080';

  /// Current environment
  static const String environment =
      'development'; // 'development' or 'production'

  /// Get the appropriate base URL based on environment and demo mode
  static String get baseUrl {
    if (useDemoMode) {
      return ''; // Demo mode doesn't need a real base URL
    }

    return environment == 'production' ? productionBaseUrl : developmentBaseUrl;
  }

  /// Toggle demo mode
  static void toggleDemoMode() {
    useDemoMode = !useDemoMode;
    print('🔄 Demo mode: ${useDemoMode ? 'ENABLED' : 'DISABLED'}');
    print('📍 Base URL: ${useDemoMode ? 'DEMO (no URL needed)' : baseUrl}');
  }

  /// Enable demo mode
  static void enableDemoMode() {
    useDemoMode = true;
    print('✅ Demo mode enabled');
  }

  /// Disable demo mode
  static void disableDemoMode() {
    useDemoMode = false;
    print('❌ Demo mode disabled - using real API: $baseUrl');
  }

  /// Check if currently in demo mode
  static bool get isDemoMode => useDemoMode;

  /// Get current configuration info
  static Map<String, dynamic> get configInfo => {
    'demoMode': useDemoMode,
    'environment': environment,
    'baseUrl': baseUrl,
    'isProduction': environment == 'production',
  };

  /// Print current configuration
  static void printConfig() {
    print('''
📋 App Configuration:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Demo Mode: ${useDemoMode ? '✅ ENABLED' : '❌ DISABLED'}
Environment: $environment
Base URL: ${useDemoMode ? 'DEMO (intercepted)' : baseUrl}
Production: ${environment == 'production' ? '✅ YES' : '❌ NO'}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    ''');
  }
}

/// Quick configuration presets
class ConfigPresets {
  /// Development with demo data (recommended for UI development)
  static void developmentDemo() {
    AppConfig.useDemoMode = true;
    print('🎨 Development + Demo mode activated');
    AppConfig.printConfig();
  }

  /// Development with real API
  static void developmentReal() {
    AppConfig.useDemoMode = false;
    print('🔧 Development + Real API mode activated');
    AppConfig.printConfig();
  }

  /// Production mode
  static void production() {
    AppConfig.useDemoMode = false;
    print('🚀 Production mode activated');
    AppConfig.printConfig();
  }
}

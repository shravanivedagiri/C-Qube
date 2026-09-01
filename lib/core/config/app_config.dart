/// Application configuration and environment constants
class AppConfig {
  static const String appName = 'C-QUBE';
  static const String appTagline = 'Campus × Club × Connect';
  static const String appDescription =
      'Everything happening on your campus, connected in one place.';

  // Supabase Configuration (Publishable/Public keys only)
  static const String supabaseUrl = 'https://mock-cqube.supabase.co';
  static const String supabaseAnonKey = 'mock-anon-key-cqube-mobile-platform';

  // Feature Flags
  static const bool useMockBackend = true;
  static const bool enableDatabricksTelemetry = true;
  static const bool enableAiGenie = true;
}

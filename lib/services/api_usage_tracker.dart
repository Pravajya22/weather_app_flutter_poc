// services/api_usage_tracker.dart
class ApiUsageTracker {
  static final Map<String, int> _dailyUsage = {};
  static DateTime _lastReset = DateTime.now();

  static void recordCall(String endpoint) {
    _resetIfNewDay();
    _dailyUsage[endpoint] = (_dailyUsage[endpoint] ?? 0) + 1;
    _logUsage();
  }

  static void _resetIfNewDay() {
    final now = DateTime.now();
    if (now.day != _lastReset.day || now.month != _lastReset.month || now.year != _lastReset.year) {
      _dailyUsage.clear();
      _lastReset = now;
      print('🔄 Reset daily API usage counter');
    }
  }

  static void _logUsage() {
    print('📊 API Usage Today:');
    _dailyUsage.forEach((key, value) {
      print('   $key: $value calls');
    });
    print('   Total: ${getTotalCalls()} calls');
  }

  static int getTotalCalls() {
    return _dailyUsage.values.fold(0, (sum, count) => sum + count);
  }

  static Map<String, int> getUsageStats() {
    return Map.from(_dailyUsage);
  }
}
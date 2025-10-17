// services/rate_limiter.dart
class RateLimiter {
  final Duration _minInterval;
  final Map<String, DateTime> _lastCallTimes = {};

  RateLimiter(this._minInterval);

  bool canCall(String endpoint) {
    final lastCall = _lastCallTimes[endpoint];
    if (lastCall == null) return true;

    return DateTime.now().difference(lastCall) > _minInterval;
  }

  void recordCall(String endpoint) {
    _lastCallTimes[endpoint] = DateTime.now();
    
    // Clean up old entries periodically
    if (_lastCallTimes.length > 100) {
      _cleanupOldEntries();
    }
  }

  void _cleanupOldEntries() {
    final now = DateTime.now();
    _lastCallTimes.removeWhere((key, value) => now.difference(value) > const Duration(minutes: 30));
  }
}
import 'dart:async';
import '../models/smart_home_manager.dart';

// =============================================================================
// SimulationEngine — Mô phỏng thời gian bằng Dart Timer
//
// Quy ước: 1 giây thực = 0.5 giờ mô phỏng
// Mỗi giây: gọi manager.updateSimulation(0.5)
// =============================================================================
class SimulationEngine {
  static const double _tickStep = 0.5; // giờ/tick
  static const Duration _interval = Duration(seconds: 1);

  Timer? _timer;
  double _currentTime = 0;
  bool _isRunning = false;

  bool get isRunning => _isRunning;
  double get currentTime => _currentTime;

  void start(SmartHomeManager manager) {
    if (_isRunning) return;
    _isRunning = true;
    _timer = Timer.periodic(_interval, (_) {
      _currentTime += _tickStep;
      manager.updateSimulation(_tickStep);
    });
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    _isRunning = false;
  }

  void dispose() => stop();
}

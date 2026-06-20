import 'package:flutter/foundation.dart';
import '../constants.dart';
import 'device.dart';

// =============================================================================
// SmartHomeManager — Quản lý toàn bộ thiết bị và năng lượng
//
// OOP Concepts:
//   • Encapsulation: _devices, _alerts… private; truy cập qua getter
//   • Abstraction  : gọi device.updateEnergy() mà không biết loại cụ thể
//   • Polymorphism : device.updateParam() gọi đúng implementation của từng lớp
//
// Extends ChangeNotifier: tương đương Qt Signals — tự động thông báo UI
// khi dữ liệu thay đổi.
// =============================================================================
class SmartHomeManager extends ChangeNotifier {
  final List<Device>    _devices = [];
  final List<AlertInfo> _alerts  = [];
  final List<double>    _energyHistory = List.generate(24, (_) => 0.0);
  final Set<String>     _warnedDevices = {};

  double _totalEnergy = 0;
  double _totalCost   = 0;
  double _currentHourConsumption = 0;
  double _hourCounter = 0;

  // ── Getters ─────────────────────────────────────────────────────────────────

  List<Device>    get devices                => List.unmodifiable(_devices);
  List<AlertInfo> get alerts                 => List.unmodifiable(_alerts);
  List<double>    get energyHistory          => List.unmodifiable(_energyHistory);
  double          get currentHourConsumption => _currentHourConsumption;

  HomeSummary get summary {
    double totalPower = 0;
    int active = 0;
    int warnings = 0;
    for (final d in _devices) {
      totalPower += d.currentPower;
      if (d.isOn) active++;
      if (d.isOn && d.currentSessionHours > kForgottenTimeLimit) warnings++;
    }
    return HomeSummary(
      totalDevices: _devices.length,
      activeDevices: active,
      totalCurrentPower: totalPower,
      totalEnergyUsed: _totalEnergy,
      totalCost: _totalCost,
      warningDevices: warnings,
    );
  }

  Map<String, List<Device>> get devicesByRoom {
    final Map<String, List<Device>> grouped = {};
    for (final d in _devices) {
      grouped.putIfAbsent(d.roomName, () => []).add(d);
    }
    return grouped;
  }

  // ── Commands (tương đương Qt Slots) ─────────────────────────────────────────

  void addDevice(Device device) {
    _devices.add(device);
    notifyListeners();
  }

  void removeDevice(String id) {
    _devices.removeWhere((d) => d.id == id);
    _warnedDevices.remove(id);
    notifyListeners();
  }

  void turnOn(String id) {
    final device = _findById(id);
    if (device == null) return;
    device.turnOn();
    _checkOverload();
    notifyListeners();
  }

  void turnOff(String id) {
    final device = _findById(id);
    if (device == null) return;
    device.turnOff();
    _warnedDevices.remove(id);
    notifyListeners();
  }

  void updateParam(String id, int value) {
    _findById(id)?.updateParam(value);
    notifyListeners();
  }

  /// Được gọi mỗi tick từ SimulationEngine (deltaHours = 0.5h/tick)
  void updateSimulation(double deltaHours) {
    double addedEnergy = 0;

    // Polymorphism: mỗi device.updateEnergy() chạy cùng logic trong Device base
    for (final device in _devices) {
      addedEnergy += device.updateEnergy(deltaHours);
    }

    _totalEnergy += addedEnergy;
    _totalCost    = _totalEnergy * kElectricityPrice;
    _currentHourConsumption += addedEnergy;
    _hourCounter += deltaHours;

    if (_hourCounter >= 1.0) {
      _energyHistory.insert(0, _currentHourConsumption);
      if (_energyHistory.length > 24) _energyHistory.removeAt(24);
      _currentHourConsumption = 0;
      _hourCounter = 0;
    }

    _checkAlerts();
    notifyListeners();
  }

  void clearAlerts() {
    _alerts.clear();
    notifyListeners();
  }

  void addNote(String deviceId, String note) {
    _findById(deviceId)?.addNote(note);
    notifyListeners();
  }

  void removeNote(String deviceId, int index) {
    _findById(deviceId)?.removeNote(index);
    notifyListeners();
  }

  // ── Private helpers ──────────────────────────────────────────────────────────

  Device? _findById(String id) {
    try { return _devices.firstWhere((d) => d.id == id); }
    catch (_) { return null; }
  }

  void _checkOverload() {
    final power = _devices.fold(0.0, (s, d) => s + d.currentPower);
    if (power > kMaxHousePower) {
      if (_alerts.isEmpty || _alerts.first.type != 'OVERLOAD') {
        _addAlert(AlertInfo(
          type: 'OVERLOAD', level: 'CRITICAL', isCritical: true,
          title: 'Cảnh báo quá tải công suất',
          message: 'Tổng ${power.toStringAsFixed(0)} W > ngưỡng ${kMaxHousePower.toStringAsFixed(0)} W',
          timestamp: DateTime.now(),
        ));
      }
    }
  }

  void _checkAlerts() {
    _checkOverload();
    for (final device in _devices) {
      if (device.isOn && device.currentSessionHours > kForgottenTimeLimit) {
        if (!_warnedDevices.contains(device.id)) {
          _warnedDevices.add(device.id);
          _addAlert(AlertInfo(
            type: 'OVERTIME', level: 'WARNING', isCritical: false,
            title: 'Quên tắt thiết bị',
            message: '${device.name} đã chạy ${device.currentSessionHours.toStringAsFixed(1)} giờ',
            deviceId: device.id, deviceName: device.name,
            timestamp: DateTime.now(),
          ));
        }
      } else {
        _warnedDevices.remove(device.id);
      }
    }
  }

  void _addAlert(AlertInfo alert) {
    _alerts.insert(0, alert);
    if (_alerts.length > 50) _alerts.removeLast();
  }
}

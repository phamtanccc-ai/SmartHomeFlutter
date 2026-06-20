import '../constants.dart';

// =============================================================================
// Device — Abstract Base Class (Abstraction + Template Method Pattern)
//
// OOP Concepts minh họa:
//   • Abstraction  : 'Device' che giấu chi tiết, chỉ lộ interface công khai
//   • Inheritance  : Các lớp con (Light, Fan, AC…) kế thừa Device
//   • Polymorphism : ratedPower và updateParam() được override ở từng lớp con
//   • Encapsulation: _isOn, _currentPower… là private; truy cập qua getter
// =============================================================================
abstract class Device {
  final String id;
  final String name;
  final String roomName;
  final String type;

  bool _isOn = false;
  double _currentPower = 0;
  double _totalConsumption = 0; // kWh
  double _runningHours = 0;
  double _currentSessionHours = 0;
  int _extraParam;
  final List<String> _notes = [];
  DateTime? _sessionStartTime;

  Device({
    required this.id,
    required this.name,
    required this.roomName,
    required this.type,
    int initialParam = 0,
  }) : _extraParam = initialParam;

  // ── Abstract members — lớp con BẮT BUỘC phải cung cấp ─────────────────────

  /// Công suất định mức (W) — mỗi thiết bị có giá trị riêng (Polymorphism)
  double get ratedPower;

  /// Cập nhật tham số điều chỉnh (độ sáng, tốc độ, nhiệt độ…)
  void updateParam(int value);

  // ── Concrete methods — dùng chung cho mọi thiết bị ─────────────────────────

  void turnOn() {
    _isOn = true;
    _currentPower = ratedPower;
    _sessionStartTime = DateTime.now();
  }

  void turnOff() {
    _isOn = false;
    _currentPower = 0;
    _currentSessionHours = 0;
    _sessionStartTime = null;
  }

  /// Tính và cộng dồn điện năng tiêu thụ trong deltaHours giờ mô phỏng
  double updateEnergy(double deltaHours) {
    if (!_isOn) return 0;
    final added = (_currentPower * deltaHours) / 1000.0;
    _totalConsumption += added;
    _runningHours += deltaHours;
    _currentSessionHours += deltaHours;
    return added;
  }

  // ── Getters (Encapsulation) ─────────────────────────────────────────────────

  bool         get isOn                 => _isOn;
  double       get currentPower         => _currentPower;
  double       get totalConsumption     => _totalConsumption;
  double       get runningHours         => _runningHours;
  double       get currentSessionHours  => _currentSessionHours;
  int          get extraParam           => _extraParam;
  List<String> get notes                => List.unmodifiable(_notes);
  Duration     get realSessionDuration  =>
      _sessionStartTime != null
          ? DateTime.now().difference(_sessionStartTime!)
          : Duration.zero;

  // Helper cho subclass cập nhật extraParam
  void setExtraParam(int value) => _extraParam = value;

  void addNote(String note) {
    final trimmed = note.trim();
    if (trimmed.isNotEmpty) _notes.add(trimmed);
  }

  void removeNote(int index) {
    if (index >= 0 && index < _notes.length) _notes.removeAt(index);
  }

  // ── UI helper methods ──────────────────────────────────────────────────────

  String get typeName {
    const names = {
      kDeviceLight: 'Đèn', kDeviceFan: 'Quạt', kDeviceAC: 'Điều Hòa',
      kDeviceTV: 'Tivi', kDeviceFridge: 'Tủ Lạnh',
      kDeviceWashingMachine: 'Máy Giặt', kDeviceWaterHeater: 'Bình Nước Nóng',
      kDeviceMicrowave: 'Lò Vi Sóng', kDeviceRiceCooker: 'Nồi Cơm Điện',
      kDeviceCurtain: 'Rèm Cửa',
    };
    return names[type] ?? type;
  }

  String get icon {
    const icons = {
      kDeviceLight: '💡', kDeviceFan: '🌀', kDeviceAC: '❄️',
      kDeviceTV: '📺', kDeviceFridge: '🧊', kDeviceWashingMachine: '🫧',
      kDeviceWaterHeater: '🚿', kDeviceMicrowave: '📡',
      kDeviceRiceCooker: '🍚', kDeviceCurtain: '🪟',
    };
    return icons[type] ?? '🔌';
  }

  bool get hasParam =>
      type == kDeviceLight || type == kDeviceFan || type == kDeviceAC ||
      type == kDeviceTV    || type == kDeviceCurtain;

  String get paramLabel {
    const labels = {
      kDeviceLight: 'Độ sáng (%)', kDeviceFan: 'Tốc độ quạt',
      kDeviceAC: 'Nhiệt độ (°C)', kDeviceTV: 'Âm lượng',
      kDeviceCurtain: 'Độ mở (%)',
    };
    return labels[type] ?? 'Giá trị';
  }

  String get paramSuffix {
    const suffixes = {
      kDeviceLight: '%', kDeviceAC: '°C', kDeviceCurtain: '%',
    };
    return suffixes[type] ?? '';
  }

  int get paramMin => type == kDeviceAC ? kMinAcTemp : (type == kDeviceFan ? 1 : 0);
  int get paramMax => type == kDeviceAC ? kMaxAcTemp : (type == kDeviceFan ? 3 : 100);
}

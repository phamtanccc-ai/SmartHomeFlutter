// Tương đương DataStructures.h trong C++ — hằng số hệ thống và các kiểu dữ liệu dùng chung

const double kMaxHousePower      = 100000.0; // W
const double kForgottenTimeLimit = 4.0;       // giờ mô phỏng
const double kElectricityPrice   = 3000.0;   // VND/kWh

const int kMinAcTemp = 16;
const int kMaxAcTemp = 30;

// Device type constants
const String kDeviceLight          = 'LIGHT';
const String kDeviceFan            = 'FAN';
const String kDeviceAC             = 'AC';
const String kDeviceTV             = 'TV';
const String kDeviceFridge         = 'FRIDGE';
const String kDeviceWashingMachine = 'WASHING_MACHINE';
const String kDeviceWaterHeater    = 'WATER_HEATER';
const String kDeviceMicrowave      = 'MICROWAVE';
const String kDeviceRiceCooker     = 'RICE_COOKER';
const String kDeviceCurtain        = 'CURTAIN';

// ─── Data classes (tương đương struct trong C++) ──────────────────────────────

class HomeSummary {
  final int totalDevices;
  final int activeDevices;
  final double totalCurrentPower;
  final double totalEnergyUsed;
  final double totalCost;
  final int warningDevices;

  const HomeSummary({
    required this.totalDevices,
    required this.activeDevices,
    required this.totalCurrentPower,
    required this.totalEnergyUsed,
    required this.totalCost,
    required this.warningDevices,
  });
}

class AlertInfo {
  final String type;
  final String level;
  final String title;
  final String message;
  final String deviceId;
  final String deviceName;
  final DateTime timestamp;
  final bool isCritical;

  AlertInfo({
    required this.type,
    required this.level,
    required this.title,
    required this.message,
    this.deviceId = '',
    this.deviceName = '',
    required this.timestamp,
    required this.isCritical,
  });
}

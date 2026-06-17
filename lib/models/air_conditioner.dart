import '../constants.dart';
import 'device.dart';

/// Điều hòa — công suất 1200W, nhiệt độ 16–30°C
class AirConditioner extends Device {
  AirConditioner({required super.id, required super.name, required super.roomName})
      : super(type: kDeviceAC, initialParam: 24);

  @override
  double get ratedPower => 1200.0;

  @override
  void updateParam(int value) => setExtraParam(value.clamp(kMinAcTemp, kMaxAcTemp));
}

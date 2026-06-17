import '../constants.dart';
import 'device.dart';

/// Đèn — công suất 10W, điều chỉnh độ sáng 0–100%
class Light extends Device {
  Light({required super.id, required super.name, required super.roomName})
      : super(type: kDeviceLight, initialParam: 100);

  @override
  double get ratedPower => 10.0;

  @override
  void updateParam(int value) => setExtraParam(value.clamp(0, 100));
}

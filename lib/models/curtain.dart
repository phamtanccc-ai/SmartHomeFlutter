import '../constants.dart';
import 'device.dart';

/// Rèm cửa tự động — công suất 5W, độ mở 0–100%
class Curtain extends Device {
  Curtain({required super.id, required super.name, required super.roomName})
      : super(type: kDeviceCurtain, initialParam: 0);

  @override
  double get ratedPower => 5.0;

  @override
  void updateParam(int value) => setExtraParam(value.clamp(0, 100));
}

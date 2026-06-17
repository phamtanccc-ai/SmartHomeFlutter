import '../constants.dart';
import 'device.dart';

/// Tivi — công suất 120W, âm lượng 0–100
class TV extends Device {
  TV({required super.id, required super.name, required super.roomName})
      : super(type: kDeviceTV, initialParam: 30);

  @override
  double get ratedPower => 120.0;

  @override
  void updateParam(int value) => setExtraParam(value.clamp(0, 100));
}

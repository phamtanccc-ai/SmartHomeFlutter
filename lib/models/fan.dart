import '../constants.dart';
import 'device.dart';

/// Quạt — công suất 70W, tốc độ 1–3
class Fan extends Device {
  Fan({required super.id, required super.name, required super.roomName})
      : super(type: kDeviceFan, initialParam: 1);

  @override
  double get ratedPower => 70.0;

  @override
  void updateParam(int value) => setExtraParam(value.clamp(1, 3));
}

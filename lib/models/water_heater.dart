import '../constants.dart';
import 'device.dart';

/// Bình nước nóng — công suất 2000W
class WaterHeater extends Device {
  WaterHeater({required super.id, required super.name, required super.roomName})
      : super(type: kDeviceWaterHeater);

  @override
  double get ratedPower => 2000.0;

  @override
  void updateParam(int value) {}
}

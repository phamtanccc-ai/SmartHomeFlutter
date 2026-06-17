import '../constants.dart';
import 'device.dart';

/// Máy giặt — công suất 500W
class WashingMachine extends Device {
  WashingMachine({required super.id, required super.name, required super.roomName})
      : super(type: kDeviceWashingMachine);

  @override
  double get ratedPower => 500.0;

  @override
  void updateParam(int value) {}
}

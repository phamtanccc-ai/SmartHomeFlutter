import '../constants.dart';
import 'device.dart';

/// Lò vi sóng — công suất 1000W
class Microwave extends Device {
  Microwave({required super.id, required super.name, required super.roomName})
      : super(type: kDeviceMicrowave);

  @override
  double get ratedPower => 1000.0;

  @override
  void updateParam(int value) {}
}

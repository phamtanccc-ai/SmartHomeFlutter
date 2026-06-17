import '../constants.dart';
import 'device.dart';

/// Nồi cơm điện — công suất 700W
class RiceCooker extends Device {
  RiceCooker({required super.id, required super.name, required super.roomName})
      : super(type: kDeviceRiceCooker);

  @override
  double get ratedPower => 700.0;

  @override
  void updateParam(int value) {}
}

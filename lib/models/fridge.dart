import '../constants.dart';
import 'device.dart';

/// Tủ lạnh — công suất 150W, công suất cố định
class Fridge extends Device {
  Fridge({required super.id, required super.name, required super.roomName})
      : super(type: kDeviceFridge);

  @override
  double get ratedPower => 150.0;

  @override
  void updateParam(int value) {} // Không có tham số điều chỉnh
}

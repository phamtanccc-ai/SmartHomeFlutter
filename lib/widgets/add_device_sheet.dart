import 'package:flutter/material.dart';
import '../constants.dart';
import '../models/device.dart';
import '../models/light.dart';
import '../models/fan.dart';
import '../models/air_conditioner.dart';
import '../models/tv.dart';
import '../models/fridge.dart';
import '../models/washing_machine.dart';
import '../models/water_heater.dart';
import '../models/microwave.dart';
import '../models/rice_cooker.dart';
import '../models/curtain.dart';

class AddDeviceSheet extends StatefulWidget {
  final List<String> existingRooms;
  const AddDeviceSheet({super.key, required this.existingRooms});

  @override
  State<AddDeviceSheet> createState() => _AddDeviceSheetState();
}

class _AddDeviceSheetState extends State<AddDeviceSheet> {
  final _nameController    = TextEditingController();
  final _newRoomController = TextEditingController();
  final _formKey           = GlobalKey<FormState>();

  String _selectedType = kDeviceLight;
  String? _selectedRoom;      // null = "phòng mới"
  bool   _showNewRoom = false;

  static const _typeOptions = [
    (type: kDeviceLight,          label: 'Đèn',            icon: '💡'),
    (type: kDeviceFan,            label: 'Quạt',           icon: '🌀'),
    (type: kDeviceAC,             label: 'Điều Hòa',       icon: '❄️'),
    (type: kDeviceTV,             label: 'Tivi',            icon: '📺'),
    (type: kDeviceFridge,         label: 'Tủ Lạnh',        icon: '🧊'),
    (type: kDeviceWashingMachine, label: 'Máy Giặt',       icon: '🫧'),
    (type: kDeviceWaterHeater,    label: 'Bình Nước Nóng', icon: '🚿'),
    (type: kDeviceMicrowave,      label: 'Lò Vi Sóng',     icon: '📡'),
    (type: kDeviceRiceCooker,     label: 'Nồi Cơm Điện',   icon: '🍚'),
    (type: kDeviceCurtain,        label: 'Rèm Cửa',        icon: '🪟'),
  ];

  @override
  void initState() {
    super.initState();
    _selectedRoom = widget.existingRooms.isNotEmpty ? widget.existingRooms.first : null;
    if (_selectedRoom == null) _showNewRoom = true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _newRoomController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20, right: 20, top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(children: [
              const Expanded(
                child: Text('Thêm Thiết Bị Mới',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ]),
            const SizedBox(height: 16),

            // Tên thiết bị
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Tên thiết bị',
                hintText: 'VD: Đèn bàn làm việc',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                prefixIcon: const Icon(Icons.devices_other_outlined),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Vui lòng nhập tên thiết bị' : null,
            ),
            const SizedBox(height: 14),

            // Loại thiết bị
            DropdownButtonFormField<String>(
              value: _selectedType,
              decoration: InputDecoration(
                labelText: 'Loại thiết bị',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                prefixIcon: const Icon(Icons.category_outlined),
              ),
              items: _typeOptions.map((t) => DropdownMenuItem(
                value: t.type,
                child: Row(children: [
                  Text(t.icon, style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 10),
                  Text(t.label),
                ]),
              )).toList(),
              onChanged: (v) => setState(() => _selectedType = v!),
            ),
            const SizedBox(height: 14),

            // Phòng
            if (widget.existingRooms.isNotEmpty) ...[
              DropdownButtonFormField<String>(
                value: _showNewRoom ? '__new__' : _selectedRoom,
                decoration: InputDecoration(
                  labelText: 'Phòng',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  prefixIcon: const Icon(Icons.room_outlined),
                ),
                items: [
                  ...widget.existingRooms.map((r) =>
                      DropdownMenuItem(value: r, child: Text(r))),
                  const DropdownMenuItem(
                    value: '__new__',
                    child: Row(children: [
                      Icon(Icons.add, size: 16, color: Color(0xFF1565C0)),
                      SizedBox(width: 6),
                      Text('Thêm phòng mới',
                          style: TextStyle(color: Color(0xFF1565C0))),
                    ]),
                  ),
                ],
                onChanged: (v) => setState(() {
                  if (v == '__new__') {
                    _showNewRoom = true;
                    _selectedRoom = null;
                  } else {
                    _showNewRoom = false;
                    _selectedRoom = v;
                  }
                }),
              ),
              const SizedBox(height: 14),
            ],

            // Tên phòng mới
            if (_showNewRoom)
              TextFormField(
                controller: _newRoomController,
                decoration: InputDecoration(
                  labelText: 'Tên phòng mới',
                  hintText: 'VD: Phòng Làm Việc',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  prefixIcon: const Icon(Icons.add_home_outlined),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (v) => _showNewRoom && (v == null || v.trim().isEmpty)
                    ? 'Vui lòng nhập tên phòng'
                    : null,
              ),

            const SizedBox(height: 20),

            // Nút xác nhận
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.add),
                label: const Text('Thêm Thiết Bị',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final name   = _nameController.text.trim();
    final room   = _showNewRoom ? _newRoomController.text.trim() : _selectedRoom!;
    final id     = 'USR_${DateTime.now().millisecondsSinceEpoch}';
    final device = _createDevice(id, name, room);

    Navigator.pop(context, device);
  }

  Device _createDevice(String id, String name, String room) {
    return switch (_selectedType) {
      kDeviceLight          => Light(id: id, name: name, roomName: room),
      kDeviceFan            => Fan(id: id, name: name, roomName: room),
      kDeviceAC             => AirConditioner(id: id, name: name, roomName: room),
      kDeviceTV             => TV(id: id, name: name, roomName: room),
      kDeviceFridge         => Fridge(id: id, name: name, roomName: room),
      kDeviceWashingMachine => WashingMachine(id: id, name: name, roomName: room),
      kDeviceWaterHeater    => WaterHeater(id: id, name: name, roomName: room),
      kDeviceMicrowave      => Microwave(id: id, name: name, roomName: room),
      kDeviceRiceCooker     => RiceCooker(id: id, name: name, roomName: room),
      kDeviceCurtain        => Curtain(id: id, name: name, roomName: room),
      _                     => Light(id: id, name: name, roomName: room),
    };
  }
}

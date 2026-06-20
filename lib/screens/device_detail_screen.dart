import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/device.dart';
import '../models/smart_home_manager.dart';

class DeviceDetailScreen extends StatefulWidget {
  final String deviceId;
  const DeviceDetailScreen({super.key, required this.deviceId});

  @override
  State<DeviceDetailScreen> createState() => _DeviceDetailScreenState();
}

class _DeviceDetailScreenState extends State<DeviceDetailScreen> {
  final TextEditingController _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SmartHomeManager>(
      builder: (context, manager, _) {
        final device = manager.devices.firstWhere(
          (d) => d.id == widget.deviceId,
          orElse: () => manager.devices.first,
        );

        return Scaffold(
          appBar: AppBar(
            title: Text(device.name),
            backgroundColor: device.isOn ? Colors.green.shade700 : Colors.grey.shade700,
            foregroundColor: Colors.white,
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildStatusCard(context, device, manager),
              const SizedBox(height: 16),
              _buildInfoCard(device),
              const SizedBox(height: 16),
              if (device.hasParam) ...[
                _buildParamCard(context, device, manager),
                const SizedBox(height: 16),
              ],
              _buildNotesCard(context, device, manager),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusCard(BuildContext context, Device device, SmartHomeManager manager) {
    final on = device.isOn;
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: LinearGradient(
            colors: on
                ? [Colors.green.shade400, Colors.green.shade700]
                : [Colors.grey.shade300, Colors.grey.shade500],
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          Text(device.icon, style: const TextStyle(fontSize: 56)),
          const SizedBox(height: 8),
          Text(
            on ? 'ĐANG BẬT' : 'ĐÃ TẮT',
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          if (on) ...[
            const SizedBox(height: 4),
            Text(
              '${device.currentPower.toStringAsFixed(0)} W',
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
          const SizedBox(height: 20),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            _buildCtrlBtn(
              label: 'BẬT',
              icon: Icons.power_settings_new,
              color: Colors.white,
              textColor: Colors.green.shade700,
              enabled: !on,
              onTap: () => manager.turnOn(device.id),
            ),
            _buildCtrlBtn(
              label: 'TẮT',
              icon: Icons.power_off,
              color: Colors.white,
              textColor: Colors.red.shade700,
              enabled: on,
              onTap: () => manager.turnOff(device.id),
            ),
          ]),
        ]),
      ),
    );
  }

  Widget _buildCtrlBtn({
    required String label,
    required IconData icon,
    required Color color,
    required Color textColor,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return ElevatedButton.icon(
      onPressed: enabled ? onTap : null,
      icon: Icon(icon, size: 18),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      style: ElevatedButton.styleFrom(
        backgroundColor: enabled ? color : Colors.white38,
        foregroundColor: textColor,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: enabled ? 2 : 0,
      ),
    );
  }

  Widget _buildInfoCard(Device device) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('Thông Tin Thiết Bị'),
            const Divider(),
            _infoRow(Icons.category_outlined, 'Loại thiết bị', device.typeName),
            _infoRow(Icons.room_outlined, 'Phòng', device.roomName),
            _infoRow(Icons.bolt_outlined, 'Công suất định mức', '${device.ratedPower.toStringAsFixed(0)} W'),
            _infoRow(Icons.electric_meter_outlined, 'Điện năng tích lũy',
                '${device.totalConsumption.toStringAsFixed(4)} kWh'),
            _infoRow(Icons.timer_outlined, 'Thời gian chạy (session)',
                device.isOn ? '${device.currentSessionHours.toStringAsFixed(2)} giờ' : '—'),
          ],
        ),
      ),
    );
  }

  Widget _buildParamCard(BuildContext context, Device device, SmartHomeManager manager) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('Điều Chỉnh Thông Số'),
            const Divider(),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(device.paramLabel, style: const TextStyle(fontWeight: FontWeight.w500)),
              Text(
                '${device.extraParam}${device.paramSuffix}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ]),
            Slider(
              value: device.extraParam.toDouble(),
              min: device.paramMin.toDouble(),
              max: device.paramMax.toDouble(),
              divisions: device.paramMax - device.paramMin,
              label: '${device.extraParam}${device.paramSuffix}',
              onChanged: device.isOn
                  ? (v) => manager.updateParam(device.id, v.round())
                  : null,
            ),
            if (!device.isOn)
              const Center(
                child: Text('Bật thiết bị để điều chỉnh',
                    style: TextStyle(color: Colors.grey, fontSize: 12)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesCard(BuildContext context, Device device, SmartHomeManager manager) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('Ghi Chú'),
            const Divider(),

            // Input row
            Row(children: [
              Expanded(
                child: TextField(
                  controller: _noteController,
                  decoration: InputDecoration(
                    hintText: 'Thêm ghi chú mới...',
                    hintStyle: const TextStyle(fontSize: 13),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    isDense: true,
                  ),
                  maxLines: 1,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (text) => _submitNote(manager, device.id),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: () => _submitNote(manager, device.id),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Icon(Icons.add, size: 20),
              ),
            ]),

            // Notes list
            if (device.notes.isEmpty) ...[
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'Chưa có ghi chú nào',
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                ),
              ),
            ] else ...[
              const SizedBox(height: 8),
              ...device.notes.asMap().entries.map((entry) {
                final index = entry.key;
                final note = entry.value;
                return Dismissible(
                  key: ValueKey('${device.id}_note_$index'),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.delete_outline, color: Colors.red.shade700),
                  ),
                  onDismissed: (_) => manager.removeNote(device.id, index),
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.amber.shade200),
                    ),
                    child: Row(children: [
                      const Icon(Icons.sticky_note_2_outlined, size: 16, color: Colors.amber),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(note, style: const TextStyle(fontSize: 13)),
                      ),
                      GestureDetector(
                        onTap: () => manager.removeNote(device.id, index),
                        child: Icon(Icons.close, size: 16, color: Colors.grey.shade400),
                      ),
                    ]),
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }

  void _submitNote(SmartHomeManager manager, String deviceId) {
    final text = _noteController.text.trim();
    if (text.isEmpty) return;
    manager.addNote(deviceId, text);
    _noteController.clear();
  }

  Widget _sectionTitle(String text) => Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
      );

  Widget _infoRow(IconData icon, String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 10),
          Expanded(child: Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13))),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        ]),
      );
}

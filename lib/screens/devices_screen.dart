import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../models/smart_home_manager.dart';
import '../services/simulation_engine.dart';
import '../widgets/dashboard_card.dart';
import '../widgets/device_tile.dart';
import '../widgets/add_device_sheet.dart';
import 'device_detail_screen.dart';

class DevicesScreen extends StatelessWidget {
  final SimulationEngine engine;
  const DevicesScreen({super.key, required this.engine});

  @override
  Widget build(BuildContext context) {
    return Consumer<SmartHomeManager>(
      builder: (context, manager, _) {
        final summary = manager.summary;
        final grouped = manager.devicesByRoom;

        return Scaffold(
          backgroundColor: Colors.grey.shade50,
          body: CustomScrollView(
            slivers: [
              // ─ App bar ────────────────────────────────────────────────
              SliverAppBar(
                expandedHeight: 56,
                pinned: true,
                backgroundColor: const Color(0xFF1565C0),
                flexibleSpace: const FlexibleSpaceBar(
                  title: Text('Smart Home Monitor',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  titlePadding: EdgeInsets.only(left: 16, bottom: 12),
                ),
                actions: [
                  // Simulation control button
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: engine.isRunning
                        ? TextButton.icon(
                            onPressed: () => engine.stop(),
                            icon: const Icon(Icons.stop_circle, color: Colors.redAccent),
                            label: const Text('Dừng', style: TextStyle(color: Colors.white70)),
                          )
                        : TextButton.icon(
                            onPressed: () => engine.start(manager),
                            icon: const Icon(Icons.play_circle, color: Colors.greenAccent),
                            label: const Text('Chạy', style: TextStyle(color: Colors.white)),
                          ),
                  ),
                ],
              ),

              // ─ Dashboard cards ────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
                  child: Column(children: [
                    // Overload banner
                    if (summary.totalCurrentPower > kMaxHousePower)
                      Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.red.shade700,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(children: [
                          const Icon(Icons.warning_amber, color: Colors.white, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'QUÁ TẢI! ${summary.totalCurrentPower.toStringAsFixed(0)} W > ${kMaxHousePower.toStringAsFixed(0)} W',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ),
                        ]),
                      ),

                    // 4 cards
                    Row(children: [
                      Expanded(
                        child: DashboardCard(
                          title: 'Công Suất',
                          value: '${summary.totalCurrentPower.toStringAsFixed(0)} W',
                          color: Colors.redAccent.shade400,
                          icon: Icons.bolt,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DashboardCard(
                          title: 'Thiết Bị Bật',
                          value: '${summary.activeDevices}/${summary.totalDevices}',
                          color: Colors.blue.shade600,
                          icon: Icons.devices,
                        ),
                      ),
                    ]),
                    const SizedBox(height: 8),
                    Row(children: [
                      Expanded(
                        child: DashboardCard(
                          title: 'Điện Năng',
                          value: '${summary.totalEnergyUsed.toStringAsFixed(3)} kWh',
                          color: Colors.green.shade600,
                          icon: Icons.electric_meter,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DashboardCard(
                          title: 'Chi Phí',
                          value: '${_formatVnd(summary.totalCost)} đ',
                          color: Colors.orange.shade700,
                          icon: Icons.paid,
                        ),
                      ),
                    ]),
                  ]),
                ),
              ),

              // ─ Device list grouped by room ────────────────────────────
              for (final entry in grouped.entries) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                    child: Row(children: [
                      const Icon(Icons.room, size: 16, color: Color(0xFF1565C0)),
                      const SizedBox(width: 6),
                      Text(
                        entry.key,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Color(0xFF1565C0),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '(${entry.value.where((d) => d.isOn).length}/${entry.value.length} bật)',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                      ),
                    ]),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) {
                      final device = entry.value[i];
                      return DeviceTile(
                        device: device,
                        onTap: () => Navigator.push(ctx,
                            MaterialPageRoute(
                                builder: (_) => DeviceDetailScreen(deviceId: device.id))),
                        onToggle: () => device.isOn
                            ? manager.turnOff(device.id)
                            : manager.turnOn(device.id),
                        onLongPress: () => _confirmDelete(ctx, manager, device.id, device.name),
                      );
                    },
                    childCount: entry.value.length,
                  ),
                ),
              ],

              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _openAddSheet(context, manager),
            icon: const Icon(Icons.add),
            label: const Text('Thêm thiết bị'),
            backgroundColor: const Color(0xFF1565C0),
            foregroundColor: Colors.white,
          ),
        );
      },
    );
  }

  void _openAddSheet(BuildContext context, SmartHomeManager manager) async {
    final rooms = manager.devicesByRoom.keys.toList();
    final device = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => AddDeviceSheet(existingRooms: rooms),
    );
    if (device != null) manager.addDevice(device);
  }

  void _confirmDelete(BuildContext context, SmartHomeManager manager, String id, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa thiết bị'),
        content: Text('Bạn có chắc muốn xóa "$name" không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(ctx);
              manager.removeDevice(id);
            },
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  String _formatVnd(double amount) {
    if (amount >= 1000000) return '${(amount / 1000000).toStringAsFixed(2)}M';
    if (amount >= 1000) return '${(amount / 1000).toStringAsFixed(1)}K';
    return amount.toStringAsFixed(0);
  }
}

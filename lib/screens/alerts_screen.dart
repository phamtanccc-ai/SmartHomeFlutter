import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../models/device.dart';
import '../models/smart_home_manager.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SmartHomeManager>(
      builder: (context, manager, _) {
        final alerts  = manager.alerts;
        final devices = manager.devices;
        final summary = manager.summary;
        final activeDevices = devices.where((d) => d.isOn).toList();

        final isOverload = summary.totalCurrentPower > kMaxHousePower;

        return Scaffold(
          backgroundColor: Colors.grey.shade50,
          appBar: AppBar(
            title: Text('Cảnh Báo${alerts.isNotEmpty ? ' (${alerts.length})' : ''}'),
            backgroundColor: const Color(0xFF1565C0),
            foregroundColor: Colors.white,
            automaticallyImplyLeading: false,
            actions: [
              if (alerts.isNotEmpty)
                TextButton.icon(
                  onPressed: manager.clearAlerts,
                  icon: const Icon(Icons.delete_sweep, color: Colors.white70, size: 18),
                  label: const Text('Xóa', style: TextStyle(color: Colors.white70)),
                ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(12),
            children: [
              // ── LIVE MONITOR ───────────────────────────────────────────
              _buildLiveHeader(summary.totalCurrentPower, isOverload),
              const SizedBox(height: 10),

              if (activeDevices.isEmpty)
                _emptyActiveCard()
              else
                _buildDeviceMonitor(activeDevices),

              const SizedBox(height: 16),

              // ── ALERT HISTORY ──────────────────────────────────────────
              Row(children: [
                const Icon(Icons.history, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                const Text('Lịch Sử Cảnh Báo',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const Spacer(),
                if (alerts.isNotEmpty)
                  Text('${alerts.length} mục',
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ]),
              const SizedBox(height: 8),

              if (alerts.isEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  alignment: Alignment.center,
                  child: Column(children: [
                    Icon(Icons.check_circle_outline,
                        size: 40, color: Colors.green.shade300),
                    const SizedBox(height: 8),
                    const Text('Chưa có cảnh báo nào',
                        style: TextStyle(color: Colors.grey)),
                  ]),
                )
              else
                ...alerts.map((alert) => _buildAlertTile(alert)),

              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  // ── Live power header ───────────────────────────────────────────────────────

  Widget _buildLiveHeader(double power, bool isOverload) {
    final ratio = (power / kMaxHousePower).clamp(0.0, 1.0);
    final Color barColor = isOverload
        ? Colors.red.shade600
        : ratio > 0.7
            ? Colors.orange.shade600
            : Colors.green.shade600;

    return Card(
      elevation: isOverload ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isOverload
            ? BorderSide(color: Colors.red.shade400, width: 1.5)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            // LIVE dot
            _liveDot(color: isOverload ? Colors.red : Colors.green),
            const SizedBox(width: 6),
            const Text('Trạng Thái Realtime',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const Spacer(),
            if (isOverload)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.red.shade300),
                ),
                child: Text('QUÁ TẢI',
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade700)),
              ),
          ]),
          const SizedBox(height: 10),

          // Power bar
          Row(children: [
            Text('${power.toStringAsFixed(0)} W',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: barColor)),
            Text(' / ${kMaxHousePower.toStringAsFixed(0)} W',
                style: const TextStyle(fontSize: 13, color: Colors.grey)),
            const Spacer(),
            Text('${(ratio * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: barColor)),
          ]),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 8,
              backgroundColor: Colors.grey.shade100,
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
            ),
          ),
        ]),
      ),
    );
  }

  // ── Per-device live monitor ─────────────────────────────────────────────────

  Widget _emptyActiveCard() => Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Center(
            child: Text('Không có thiết bị nào đang bật',
                style: TextStyle(color: Colors.grey.shade400, fontSize: 13)),
          ),
        ),
      );

  Widget _buildDeviceMonitor(List<Device> active) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${active.length} thiết bị đang hoạt động',
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 8),
            ...active.map((d) => _buildDeviceRow(d)),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceRow(Device device) {
    final simHours  = device.currentSessionHours;
    final realDur   = device.realSessionDuration;
    final ratio     = (simHours / kForgottenTimeLimit).clamp(0.0, 1.0);
    final isCrit    = simHours >= kForgottenTimeLimit;
    final isWarn    = simHours >= kForgottenTimeLimit * 0.5;

    final Color rowColor = isCrit
        ? Colors.red.shade600
        : isWarn
            ? Colors.orange.shade600
            : Colors.green.shade600;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text(device.icon, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(device.name,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: isCrit ? FontWeight.bold : FontWeight.normal),
                  overflow: TextOverflow.ellipsis),
            ),
            // Thời gian thực (realtime)
            Text(
              _formatDuration(realDur),
              style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 12, color: rowColor),
            ),
            const SizedBox(width: 8),
            // Power (live)
            Text('${device.currentPower.toStringAsFixed(0)} W',
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
            if (isCrit) ...[
              const SizedBox(width: 6),
              Icon(Icons.warning_amber_rounded,
                  size: 16, color: Colors.red.shade600),
            ],
          ]),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 5,
              backgroundColor: Colors.grey.shade100,
              valueColor: AlwaysStoppedAnimation<Color>(rowColor),
            ),
          ),
          if (isCrit)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                'Quên tắt! ${_formatDuration(realDur)} thực / ${simHours.toStringAsFixed(1)}h mô phỏng',
                style: TextStyle(fontSize: 10, color: Colors.red.shade600),
              ),
            ),
        ],
      ),
    );
  }

  // ── Alert history tile ──────────────────────────────────────────────────────

  Widget _buildAlertTile(AlertInfo alert) {
    final isCritical = alert.isCritical;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: isCritical ? Colors.red.shade200 : Colors.orange.shade200,
          width: 0.8,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: CircleAvatar(
          backgroundColor:
              isCritical ? Colors.red.shade50 : Colors.orange.shade50,
          child: Icon(
            isCritical ? Icons.error_outline : Icons.warning_amber_outlined,
            color: isCritical ? Colors.red : Colors.orange,
            size: 22,
          ),
        ),
        title: Text(
          alert.title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: isCritical ? Colors.red.shade700 : Colors.orange.shade800,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(alert.message, style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 2),
            Text(
              _formatTime(alert.timestamp),
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isCritical ? Colors.red.shade50 : Colors.orange.shade50,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            isCritical ? 'CRITICAL' : 'WARNING',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: isCritical ? Colors.red : Colors.orange,
            ),
          ),
        ),
      ),
    );
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────

  Widget _liveDot({Color color = const Color(0xFF4CAF50)}) => Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );

  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes % 60;
    final s = d.inSeconds % 60;
    if (h > 0) return '${h}g ${m.toString().padLeft(2, '0')}p ${s.toString().padLeft(2, '0')}s';
    if (m > 0) return '${m}p ${s.toString().padLeft(2, '0')}s';
    return '${s}s';
  }

  String _formatTime(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:'
      '${dt.minute.toString().padLeft(2, '0')}:'
      '${dt.second.toString().padLeft(2, '0')}';
}

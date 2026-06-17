import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/smart_home_manager.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SmartHomeManager>(
      builder: (context, manager, _) {
        final alerts = manager.alerts;

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
          body: alerts.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_outline, size: 64, color: Colors.green),
                      SizedBox(height: 12),
                      Text('Không có cảnh báo nào', style: TextStyle(fontSize: 16, color: Colors.grey)),
                      SizedBox(height: 4),
                      Text('Hệ thống hoạt động bình thường', style: TextStyle(fontSize: 13, color: Colors.grey)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: alerts.length,
                  itemBuilder: (ctx, i) {
                    final alert = alerts[i];
                    final isCritical = alert.isCritical;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        leading: CircleAvatar(
                          backgroundColor: isCritical
                              ? Colors.red.shade50
                              : Colors.orange.shade50,
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
                  },
                ),
        );
      },
    );
  }

  String _formatTime(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:'
      '${dt.minute.toString().padLeft(2, '0')}:'
      '${dt.second.toString().padLeft(2, '0')}';
}

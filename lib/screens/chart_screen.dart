import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/smart_home_manager.dart';

class ChartScreen extends StatelessWidget {
  const ChartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SmartHomeManager>(
      builder: (context, manager, _) {
        final history = manager.energyHistory;
        final maxVal = history.fold(0.0, (m, v) => v > m ? v : m);
        final summary = manager.summary;

        return Scaffold(
          backgroundColor: Colors.grey.shade50,
          appBar: AppBar(
            title: const Text('Biểu Đồ Tiêu Thụ Điện'),
            backgroundColor: const Color(0xFF1565C0),
            foregroundColor: Colors.white,
            automaticallyImplyLeading: false,
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ─ Summary stats ───────────────────────────────────────────
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _stat('Tổng điện năng', '${summary.totalEnergyUsed.toStringAsFixed(3)} kWh', Colors.green),
                      _vDivider(),
                      _stat('Chi phí', '${(summary.totalCost / 1000).toStringAsFixed(1)}K đ', Colors.orange),
                      _vDivider(),
                      _stat('Công suất hiện tại', '${summary.totalCurrentPower.toStringAsFixed(0)} W', Colors.red),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ─ Bar chart ───────────────────────────────────────────────
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 20, 12, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Lịch Sử Tiêu Thụ (24 Giờ Mô Phỏng Gần Nhất)',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      const Text(
                        '1 giây thực = 0.5 giờ mô phỏng',
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 220,
                        child: maxVal == 0
                            ? const Center(
                                child: Text('Chưa có dữ liệu\nHãy chạy mô phỏng',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.grey)),
                              )
                            : BarChart(
                                BarChartData(
                                  maxY: maxVal * 1.3,
                                  gridData: FlGridData(
                                    show: true,
                                    drawVerticalLine: false,
                                    getDrawingHorizontalLine: (v) => FlLine(
                                      color: Colors.grey.shade200,
                                      strokeWidth: 1,
                                    ),
                                  ),
                                  borderData: FlBorderData(show: false),
                                  titlesData: FlTitlesData(
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        getTitlesWidget: (v, _) {
                                          final idx = v.toInt();
                                          if (idx % 4 != 0) return const SizedBox();
                                          return Text(
                                            '-${23 - idx}h',
                                            style: const TextStyle(fontSize: 9, color: Colors.grey),
                                          );
                                        },
                                        reservedSize: 20,
                                      ),
                                    ),
                                    leftTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        reservedSize: 42,
                                        getTitlesWidget: (v, _) => Text(
                                          v.toStringAsFixed(2),
                                          style: const TextStyle(fontSize: 9, color: Colors.grey),
                                        ),
                                      ),
                                    ),
                                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  ),
                                  barGroups: _buildBars(history),
                                ),
                              ),
                      ),
                      const SizedBox(height: 4),
                      const Center(
                        child: Text('kWh / giờ mô phỏng',
                            style: TextStyle(fontSize: 11, color: Colors.grey)),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ─ Device consumption ranking ──────────────────────────────
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Thiết Bị Tiêu Thụ Nhiều Nhất',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 12),
                      ...(() {
                        final sorted = [...manager.devices]
                          ..sort((a, b) => b.totalConsumption.compareTo(a.totalConsumption));
                        return sorted.take(5).map((d) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(children: [
                            Text(d.icon, style: const TextStyle(fontSize: 18)),
                            const SizedBox(width: 10),
                            Expanded(child: Text(d.name,
                                style: const TextStyle(fontSize: 13),
                                overflow: TextOverflow.ellipsis)),
                            Text(
                              '${d.totalConsumption.toStringAsFixed(4)} kWh',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 12, color: Colors.green),
                            ),
                          ]),
                        )).toList();
                      })(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<BarChartGroupData> _buildBars(List<double> history) {
    final maxVal = history.fold(0.0, (m, v) => v > m ? v : m);
    return List.generate(24, (i) {
      // history[0] = latest → placed at x=23
      final dataIdx = 23 - i;
      final value = dataIdx < history.length ? history[dataIdx] : 0.0;
      final ratio = maxVal > 0 ? value / maxVal : 0.0;
      return BarChartGroupData(x: i, barRods: [
        BarChartRodData(
          toY: value,
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Color.lerp(Colors.blue.shade300, Colors.blue.shade700, ratio)!,
              Colors.blue.shade600,
            ],
          ),
          width: 8,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
        ),
      ]);
    });
  }

  Widget _stat(String label, String value, Color color) => Column(
        children: [
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: color)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      );

  Widget _vDivider() => Container(width: 1, height: 40, color: Colors.grey.shade200);
}

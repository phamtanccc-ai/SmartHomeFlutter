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
        final history  = manager.energyHistory;
        final livekWh  = manager.currentHourConsumption;
        final summary  = manager.summary;

        // 24 completed hours + 1 live bar
        final allBars  = [...history, livekWh];
        final maxVal   = allBars.fold(0.0, (m, v) => v > m ? v : m);

        return Scaffold(
          backgroundColor: Colors.grey.shade50,
          appBar: AppBar(
            title: const Text('Báo Cáo Tiêu Thụ Điện'),
            backgroundColor: const Color(0xFF1565C0),
            foregroundColor: Colors.white,
            automaticallyImplyLeading: false,
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ─ Realtime power banner ───────────────────────────────────
              _buildRealtimeBanner(summary),
              const SizedBox(height: 12),

              // ─ Summary stats ───────────────────────────────────────────
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _stat('Tổng điện năng',
                          '${summary.totalEnergyUsed.toStringAsFixed(3)} kWh',
                          Colors.green.shade700),
                      _vDivider(),
                      _stat('Giờ này (live)',
                          '${livekWh.toStringAsFixed(4)} kWh',
                          Colors.orange.shade700),
                      _vDivider(),
                      _stat('Chi phí ước tính',
                          '${_formatVnd(summary.totalCost)} đ',
                          Colors.red.shade700),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ─ Bar chart: 24h history + live ──────────────────────────
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 20, 12, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Lịch Sử Tiêu Thụ 24 Giờ',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ),
                          // Live indicator
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.green.shade300),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _liveDot(),
                                const SizedBox(width: 4),
                                Text('LIVE',
                                    style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green.shade700)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        '1 giây thực = 5 phút mô phỏng  •  Cột xanh = giờ đang chạy',
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 220,
                        child: maxVal == 0
                            ? const Center(
                                child: Text('Chưa có dữ liệu\nHãy bật mô phỏng',
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
                                          if (idx == 24) {
                                            return Padding(
                                              padding: const EdgeInsets.only(top: 4),
                                              child: Text('Now',
                                                  style: TextStyle(
                                                      fontSize: 9,
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.green.shade600)),
                                            );
                                          }
                                          // show every 4th bar label
                                          if (idx % 4 != 0) return const SizedBox();
                                          final hoursAgo = 23 - idx;
                                          return Padding(
                                            padding: const EdgeInsets.only(top: 4),
                                            child: Text(
                                              hoursAgo == 0 ? '-0h' : '-${hoursAgo}h',
                                              style: const TextStyle(fontSize: 9, color: Colors.grey),
                                            ),
                                          );
                                        },
                                        reservedSize: 22,
                                      ),
                                    ),
                                    leftTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        reservedSize: 46,
                                        getTitlesWidget: (v, _) => Text(
                                          v.toStringAsFixed(3),
                                          style: const TextStyle(fontSize: 9, color: Colors.grey),
                                        ),
                                      ),
                                    ),
                                    topTitles: const AxisTitles(
                                        sideTitles: SideTitles(showTitles: false)),
                                    rightTitles: const AxisTitles(
                                        sideTitles: SideTitles(showTitles: false)),
                                  ),
                                  barGroups: _buildBars(history, livekWh, maxVal),
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

              // ─ Per-device realtime power ───────────────────────────────
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Công Suất Thiết Bị (Realtime)',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 12),
                      ...() {
                        final active = manager.devices
                            .where((d) => d.isOn)
                            .toList()
                          ..sort((a, b) => b.currentPower.compareTo(a.currentPower));
                        if (active.isEmpty) {
                          return [
                            Center(
                              child: Text('Không có thiết bị nào đang bật',
                                  style: TextStyle(color: Colors.grey.shade400, fontSize: 13)),
                            )
                          ];
                        }
                        final totalPower = summary.totalCurrentPower;
                        return active.map((d) {
                          final ratio = totalPower > 0 ? d.currentPower / totalPower : 0.0;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Column(
                              children: [
                                Row(children: [
                                  Text(d.icon, style: const TextStyle(fontSize: 16)),
                                  const SizedBox(width: 8),
                                  Expanded(
                                      child: Text(d.name,
                                          style: const TextStyle(fontSize: 12),
                                          overflow: TextOverflow.ellipsis)),
                                  Text(
                                    '${d.currentPower.toStringAsFixed(0)} W',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                        color: Colors.green.shade700),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${(ratio * 100).toStringAsFixed(0)}%',
                                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                                  ),
                                ]),
                                const SizedBox(height: 4),
                                LinearProgressIndicator(
                                  value: ratio,
                                  backgroundColor: Colors.grey.shade100,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    ratio > 0.5
                                        ? Colors.red.shade400
                                        : ratio > 0.3
                                            ? Colors.orange.shade400
                                            : Colors.green.shade400,
                                  ),
                                  minHeight: 6,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ],
                            ),
                          );
                        }).toList();
                      }(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ─ Consumption ranking (cumulative) ───────────────────────
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Thiết Bị Tiêu Thụ Nhiều Nhất (Tích Lũy)',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 12),
                      ...() {
                        final sorted = [...manager.devices]
                          ..sort((a, b) => b.totalConsumption.compareTo(a.totalConsumption));
                        return sorted.take(5).map((d) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(children: [
                            Text(d.icon, style: const TextStyle(fontSize: 18)),
                            const SizedBox(width: 10),
                            Expanded(
                                child: Text(d.name,
                                    style: const TextStyle(fontSize: 13),
                                    overflow: TextOverflow.ellipsis)),
                            Text(
                              '${d.totalConsumption.toStringAsFixed(4)} kWh',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: Colors.green.shade700),
                            ),
                          ]),
                        )).toList();
                      }(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRealtimeBanner(summary) {
    final power = (summary as dynamic).totalCurrentPower as double;
    final active = summary.activeDevices as int;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: power > 4000
              ? [Colors.red.shade600, Colors.red.shade800]
              : power > 2000
                  ? [Colors.orange.shade600, Colors.orange.shade800]
                  : [const Color(0xFF1565C0), const Color(0xFF0D47A1)],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(children: [
        _liveDot(size: 10, color: Colors.white),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Công Suất Tức Thời',
                  style: TextStyle(color: Colors.white70, fontSize: 11)),
              Text(
                '${power.toStringAsFixed(0)} W',
                style: const TextStyle(
                    color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('$active thiết bị đang bật',
                style: const TextStyle(color: Colors.white70, fontSize: 11)),
            Text(
              '≈ ${(power / 1000).toStringAsFixed(2)} kW',
              style: const TextStyle(
                  color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ]),
    );
  }

  List<BarChartGroupData> _buildBars(
      List<double> history, double livekWh, double maxVal) {
    final bars = <BarChartGroupData>[];

    // 24 historical bars: history[23]=oldest (x=0), history[0]=newest (x=23)
    for (int i = 0; i < 24; i++) {
      final dataIdx = 23 - i;
      final value = dataIdx < history.length ? history[dataIdx] : 0.0;
      final ratio = maxVal > 0 ? value / maxVal : 0.0;
      bars.add(BarChartGroupData(x: i, barRods: [
        BarChartRodData(
          toY: value,
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Color.lerp(Colors.blue.shade200, Colors.blue.shade700, ratio)!,
              Colors.blue.shade600,
            ],
          ),
          width: 7,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
        ),
      ]));
    }

    // Live bar at x=24 (current accumulating hour) — green
    bars.add(BarChartGroupData(x: 24, barRods: [
      BarChartRodData(
        toY: livekWh,
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Colors.green.shade300, Colors.green.shade600],
        ),
        width: 9,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        backDrawRodData: BackgroundBarChartRodData(
          show: true,
          toY: maxVal * 1.3,
          color: Colors.green.shade50,
        ),
      ),
    ]));

    return bars;
  }

  Widget _liveDot({double size = 7, Color color = const Color(0xFF4CAF50)}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.4, end: 1.0),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
      builder: (_, v, __) => Opacity(
        opacity: v,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
      ),
      onEnd: null,
    );
  }

  Widget _stat(String label, String value, Color color) => Column(
        children: [
          Text(value,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: color)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(fontSize: 10, color: Colors.grey),
              textAlign: TextAlign.center),
        ],
      );

  Widget _vDivider() =>
      Container(width: 1, height: 40, color: Colors.grey.shade200);

  String _formatVnd(double amount) {
    if (amount >= 1000000) return '${(amount / 1000000).toStringAsFixed(2)}M';
    if (amount >= 1000) return '${(amount / 1000).toStringAsFixed(1)}K';
    return amount.toStringAsFixed(0);
  }
}

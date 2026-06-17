import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'models/smart_home_manager.dart';
import 'models/light.dart';
import 'models/fan.dart';
import 'models/air_conditioner.dart';
import 'models/tv.dart';
import 'models/fridge.dart';
import 'models/washing_machine.dart';
import 'models/water_heater.dart';
import 'models/microwave.dart';
import 'models/rice_cooker.dart';
import 'models/curtain.dart';
import 'services/simulation_engine.dart';
import 'screens/devices_screen.dart';
import 'screens/chart_screen.dart';
import 'screens/alerts_screen.dart';

// =============================================================================
// main() — Khởi động ứng dụng
//
// Kiến trúc:
//   SmartHomeManager (ChangeNotifier) — Business Logic + State
//   SimulationEngine                  — Mô phỏng thời gian
//   Provider                          — Dependency Injection + State Management
//   [DevicesScreen, ChartScreen, AlertsScreen] — UI Layer
// =============================================================================

void main() {
  final manager = SmartHomeManager();
  _loadDevices(manager);

  runApp(
    ChangeNotifierProvider.value(
      value: manager,
      child: SmartHomeApp(manager: manager),
    ),
  );
}

/// Khởi tạo 16 thiết bị cho 5 phòng — minh họa Polymorphism:
/// mỗi lớp con có ratedPower và updateParam() riêng biệt
void _loadDevices(SmartHomeManager m) {
  // ─── Phòng Khách ───────────────────────────────────────────────────────────
  m.addDevice(Light          (id: 'R1_L1',   name: 'Đèn phòng khách',      roomName: 'Phòng Khách'));
  m.addDevice(AirConditioner (id: 'R1_AC1',  name: 'Điều hòa phòng khách', roomName: 'Phòng Khách'));
  m.addDevice(TV             (id: 'R1_TV1',  name: 'Tivi phòng khách',     roomName: 'Phòng Khách'));
  m.addDevice(Fan            (id: 'R1_FAN1', name: 'Quạt phòng khách',     roomName: 'Phòng Khách'));
  m.addDevice(Curtain        (id: 'R1_C1',   name: 'Rèm cửa phòng khách', roomName: 'Phòng Khách'));

  // ─── Phòng Ngủ ─────────────────────────────────────────────────────────────
  m.addDevice(Light          (id: 'R2_L1',   name: 'Đèn phòng ngủ',        roomName: 'Phòng Ngủ'));
  m.addDevice(AirConditioner (id: 'R2_AC1',  name: 'Điều hòa phòng ngủ',   roomName: 'Phòng Ngủ'));
  m.addDevice(Fan            (id: 'R2_FAN1', name: 'Quạt phòng ngủ',       roomName: 'Phòng Ngủ'));

  // ─── Nhà Bếp ───────────────────────────────────────────────────────────────
  m.addDevice(Fridge         (id: 'R3_FR1',  name: 'Tủ lạnh',              roomName: 'Nhà Bếp'));
  m.addDevice(Microwave      (id: 'R3_MW1',  name: 'Lò vi sóng',           roomName: 'Nhà Bếp'));
  m.addDevice(RiceCooker     (id: 'R3_RC1',  name: 'Nồi cơm điện',         roomName: 'Nhà Bếp'));

  // ─── Nhà Tắm ───────────────────────────────────────────────────────────────
  m.addDevice(WaterHeater    (id: 'R4_WH1',  name: 'Bình nước nóng',       roomName: 'Nhà Tắm'));
  m.addDevice(Light          (id: 'R4_L1',   name: 'Đèn nhà tắm',          roomName: 'Nhà Tắm'));

  // ─── Phòng Giặt ────────────────────────────────────────────────────────────
  m.addDevice(WashingMachine (id: 'R5_WM1',  name: 'Máy giặt',             roomName: 'Phòng Giặt'));

  // ─── Hành Lang ─────────────────────────────────────────────────────────────
  m.addDevice(Light          (id: 'R6_L1',   name: 'Đèn hành lang',        roomName: 'Hành Lang'));
  m.addDevice(Curtain        (id: 'R6_C1',   name: 'Rèm cửa hành lang',   roomName: 'Hành Lang'));
}

// =============================================================================
// SmartHomeApp — Root widget
// =============================================================================
class SmartHomeApp extends StatefulWidget {
  final SmartHomeManager manager;
  const SmartHomeApp({super.key, required this.manager});

  @override
  State<SmartHomeApp> createState() => _SmartHomeAppState();
}

class _SmartHomeAppState extends State<SmartHomeApp> {
  final SimulationEngine _engine = SimulationEngine();
  int _currentTab = 0;

  @override
  void dispose() {
    _engine.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Home Monitor',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1565C0),
          brightness: Brightness.light,
        ),
        textTheme: GoogleFonts.notoSansTextTheme(),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      home: _buildHome(),
    );
  }

  Widget _buildHome() {
    final screens = [
      DevicesScreen(engine: _engine),
      const ChartScreen(),
      const AlertsScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentTab, children: screens),
      bottomNavigationBar: Consumer<SmartHomeManager>(
        builder: (ctx, manager, _) {
          final alertCount = manager.alerts.length;
          return NavigationBar(
            selectedIndex: _currentTab,
            onDestinationSelected: (i) => setState(() => _currentTab = i),
            destinations: [
              const NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: 'Thiết Bị',
              ),
              const NavigationDestination(
                icon: Icon(Icons.bar_chart_outlined),
                selectedIcon: Icon(Icons.bar_chart),
                label: 'Biểu Đồ',
              ),
              NavigationDestination(
                icon: Badge(
                  isLabelVisible: alertCount > 0,
                  label: Text('$alertCount'),
                  child: const Icon(Icons.notifications_outlined),
                ),
                selectedIcon: Badge(
                  isLabelVisible: alertCount > 0,
                  label: Text('$alertCount'),
                  child: const Icon(Icons.notifications),
                ),
                label: 'Cảnh Báo',
              ),
            ],
          );
        },
      ),
    );
  }
}

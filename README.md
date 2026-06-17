# 🏠 SmartHome Flutter

> Ứng dụng quản lý & mô phỏng nhà thông minh đa nền tảng, xây dựng bằng **Flutter**.  
> Quản lý 16 thiết bị trên 5 phòng, theo dõi công suất tiêu thụ theo thời gian thực và cảnh báo bất thường.

![Flutter](https://img.shields.io/badge/Flutter-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?logo=dart&logoColor=white)
![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20Web%20%7C%20Windows-success)
![License](https://img.shields.io/badge/License-MIT-green)

---

## 📌 Giới thiệu

**SmartHome Flutter** là ứng dụng mô phỏng hệ thống nhà thông minh, cho phép người dùng:

- Bật/tắt và điều chỉnh thông số của nhiều loại thiết bị gia dụng
- Theo dõi **công suất tiêu thụ điện** theo thời gian (biểu đồ)
- Nhận **cảnh báo** khi thiết bị hoạt động bất thường

Dự án được thiết kế để minh họa các nguyên lý **Lập trình hướng đối tượng (OOP)** — đặc biệt là **tính đa hình (Polymorphism)** — kết hợp với mô hình quản lý trạng thái hiện đại của Flutter.

---

## ✨ Tính năng chính

- 🔌 **16 thiết bị / 5 phòng** — minh họa Polymorphism, mỗi loại thiết bị có công suất định mức (`ratedPower`) và logic cập nhật (`updateParam()`) riêng
- 🎛️ **Điều khiển thiết bị** — bật/tắt, chỉnh thông số theo từng loại thiết bị
- 📊 **Biểu đồ tiêu thụ** — theo dõi công suất điện theo thời gian (ChartScreen)
- 🔔 **Hệ thống cảnh báo** — phát hiện và hiển thị bất thường (AlertsScreen)
- ⏱️ **Simulation Engine** — mô phỏng thời gian chạy thực tế của hệ thống
- 🌗 Giao diện thiết kế với **Google Fonts**, hỗ trợ đa nền tảng

---

## 🧩 Các loại thiết bị

Tất cả kế thừa từ lớp trừu tượng `Device`:

| Thiết bị | Lớp | Thiết bị | Lớp |
|---|---|---|---|
| 💡 Đèn | `Light` | 🌬️ Quạt | `Fan` |
| ❄️ Điều hòa | `AirConditioner` | 📺 TV | `TV` |
| 🧊 Tủ lạnh | `Fridge` | 🧺 Máy giặt | `WashingMachine` |
| 🚿 Bình nóng lạnh | `WaterHeater` | 🍲 Lò vi sóng | `Microwave` |
| 🍚 Nồi cơm điện | `RiceCooker` | 🪟 Rèm cửa | `Curtain` |

---

## 🏗️ Kiến trúc

```
┌─────────────────────────────────────────────────────┐
│                     UI Layer                         │
│     DevicesScreen · ChartScreen · AlertsScreen       │
└───────────────────────┬─────────────────────────────┘
                        │ Provider (DI + State Management)
┌───────────────────────▼─────────────────────────────┐
│   SmartHomeManager (ChangeNotifier)                  │
│   → Business Logic + State                           │
└───────────────────────┬─────────────────────────────┘
                        │
┌───────────────────────▼─────────────────────────────┐
│   SimulationEngine  → Mô phỏng thời gian             │
│   Device (abstract) → 10 lớp con (Polymorphism)      │
└─────────────────────────────────────────────────────┘
```

| Thành phần | Vai trò |
|---|---|
| `SmartHomeManager` (ChangeNotifier) | Business Logic + State |
| `SimulationEngine` | Mô phỏng thời gian |
| `Provider` | Dependency Injection + State Management |
| `DevicesScreen`, `ChartScreen`, `AlertsScreen` | UI Layer |

### Cấu trúc thư mục

```
lib/
├── models/          # Device (abstract) + 10 lớp con thiết bị, SmartHomeManager
├── services/        # SimulationEngine
├── screens/         # DevicesScreen, ChartScreen, AlertsScreen
├── widgets/         # Các widget tái sử dụng (DeviceTile, ...)
├── constants.dart   # Hằng số dùng chung
└── main.dart        # Điểm khởi động, khởi tạo thiết bị & Provider
```

---

## 🚀 Cài đặt & Chạy

### Yêu cầu
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (kèm Dart)
- Một thiết bị chạy: Chrome / Windows / Android emulator hoặc điện thoại

### Các bước

```bash
# 1. Clone repo
git clone https://github.com/phamtanccc-ai/SmartHomeFlutter.git
cd SmartHomeFlutter

# 2. Cài dependencies
flutter pub get

# 3. Chạy app
flutter run -d chrome      # Chạy trên web
# hoặc
flutter run -d windows     # Chạy trên Windows desktop
# hoặc
flutter run                # Chạy trên thiết bị Android đang kết nối
```

### Build APK cho Android

```bash
flutter build apk --release --split-per-abi
# File APK: build/app/outputs/flutter-apk/
```

---

## 🛠️ Công nghệ sử dụng

- **Flutter** & **Dart**
- **Provider** — quản lý trạng thái
- **google_fonts** — typography
- Mô hình **OOP**: Abstraction, Inheritance, Polymorphism

---

## 📸 Screenshots

> *(Thêm ảnh chụp màn hình app vào đây)*

| Devices | Chart | Alerts |
|---|---|---|
| _ảnh_ | _ảnh_ | _ảnh_ |

---

## 👤 Tác giả

**Phạm Tấn** — Sinh viên Hệ thống nhúng & IoT, Đại học Sư phạm Kỹ thuật (SPKT)  
GitHub: [@phamtanccc-ai](https://github.com/phamtanccc-ai)

---

## 📄 License

Phát hành theo giấy phép [MIT](LICENSE).

# 📱 iOS System Monitor App

Professional iPhone 14 Pro Max monitoring application for Ubuntu server via Tailscale VPN.

## 🎯 Features

### 📊 Dashboard
- **Gradient Stats Cards**: CPU, RAM, Disk, GPU usage with beautiful gradients
- **Animated Progress Bars**: Smooth 1.5s animations for real-time data
- **Glass Morphism Effects**: Modern iOS-style UI design
- **Auto-refresh**: 2-second interval data updates

### 🖥️ SSH Terminal
- Direct SSH connection to Ubuntu server
- Full xterm terminal emulation
- Dark theme with syntax highlighting
- Connection status indicator

### 🪟 Windows Boot Switcher
- One-click GRUB boot to Windows NVME SSD
- Confirmation dialog for safety
- Direct backend integration

### 🎮 GPU Monitoring
- NVIDIA GPU metrics via pynvml
- Temperature, power draw, utilization
- VRAM usage tracking
- Multi-GPU support

### 📡 Network & Energy
- Port analysis (listening/foreign)
- Energy consumption tracking
- Training process monitoring

## 🌐 Server Configuration

**Tailscale IP**: `100.79.166.110:1571` (snnunvr-server)

### Backend Endpoints
```
GET  /                           # Welcome page
GET  /health                     # Health check
GET  /api/system                 # System info (CPU/RAM/Disk/GPU)
GET  /api/system/gpu             # GPU details
GET  /api/system/cpu             # CPU details
GET  /api/system/memory          # Memory details
GET  /api/energy                 # Energy monitoring
GET  /api/ports                  # Port analysis
GET  /api/ports/listening        # Listening ports
GET  /api/ports/foreign          # Foreign connections
GET  /api/training               # Training processes
POST /api/training/stop/{pid}    # Stop training
POST /api/training/pause/{pid}   # Pause training
POST /api/training/resume/{pid}  # Resume training
POST /api/system/reboot/windows  # Reboot to Windows
WS   /ws                         # WebSocket updates
```

## 🚀 Setup

### Prerequisites
- macOS (for development)
- Flutter SDK 3.35.6+
- Xcode (for iOS builds)
- iPhone 14 Pro Max with Developer Mode
- Tailscale VPN installed on iPhone

### Installation

1. **Clone Repository**
   ```bash
   git clone https://github.com/snnunvr/ios-system-monitor.git
   cd ios-system-monitor
   ```

2. **Install Dependencies**
   ```bash
   flutter pub get
   cd ios && pod install
   ```

3. **Run on macOS (for testing)**
   ```bash
   flutter run -d macos
   ```

4. **Deploy to iPhone**
   ```bash
   flutter run -d iphone
   # or open in Xcode:
   open ios/Runner.xcworkspace
   ```

### Backend Setup (Ubuntu Server)

1. **Install Python Dependencies**
   ```bash
   cd backend
   pip install fastapi uvicorn psutil pynvml GPUtil
   ```

2. **Run FastAPI Server**
   ```bash
   python main.py
   # Server will start on http://0.0.0.0:1571
   ```

3. **Verify Tailscale**
   - Ensure Tailscale is running on Ubuntu
   - Check IP: `tailscale ip -4` → Should show `100.79.166.110`
   - Test from iPhone: `http://100.79.166.110:1571/health`

## 📱 iPhone Configuration

### Network Settings
1. Open **Settings** tab in app
2. Server URL is pre-configured: `http://100.79.166.110:1571`
3. Tap **Test Connection** → Should show ✓

### SSH Terminal
1. Open **Terminal** tab
2. Tap **Link** icon (top right)
3. Default settings:
   - Host: `100.79.166.110`
   - Port: `22`
   - Username: `ubuntu`
4. Enter password and tap **Connect**

### Windows Boot
1. Open **Dashboard** tab
2. Scroll to bottom
3. Tap **🪟 Windows'a Geç** button
4. Confirm dialog → Ubuntu will reboot to Windows

## 🎨 UI Components

### Gradient Cards
```dart
GradientStatCard(
  title: 'CPU Kullanımı',
  value: '45%',
  icon: Icons.speed,
  gradientColors: [Color(0xFFFF6B6B), Color(0xFFEE5A6F)],
)
```

### Animated Progress
```dart
AnimatedProgressCard(
  title: '🖥️ İşlemci',
  value: 45.0,
  color: AppColors.danger,
  icon: Icons.speed,
  subtitle: '8 Cores @ 3.50 GHz · 42°C',
)
```

### Glass Morphism
```dart
GlassCard(
  padding: EdgeInsets.all(16),
  child: YourWidget(),
)
```

## 📦 Project Structure

```
ios-system-monitor/
├── lib/
│   ├── main.dart                    # App entry point
│   ├── screens/
│   │   ├── dashboard_screen.dart    # Main dashboard
│   │   ├── terminal_screen.dart     # SSH terminal
│   │   ├── settings_screen.dart     # Settings & config
│   │   ├── gpu_monitor_screen.dart  # GPU details
│   │   ├── port_analysis_screen.dart
│   │   ├── energy_monitor_screen.dart
│   │   └── training_tracker_screen.dart
│   ├── services/
│   │   └── api_client.dart          # Dio HTTP client
│   ├── theme/
│   │   └── app_theme.dart           # iOS dark theme
│   └── widgets/
│       ├── common_widgets.dart      # Shared widgets
│       └── gradient_card.dart       # Custom cards
├── backend/
│   ├── main.py                      # FastAPI server
│   └── monitors/
│       ├── gpu_monitor.py           # NVIDIA monitoring
│       ├── energy_monitor.py        # Power tracking
│       ├── port_analyzer.py         # Network analysis
│       └── training_tracker.py      # Process tracking
├── ios/                             # iOS build configs
├── macos/                           # macOS build configs
└── README.md
```

## 🔧 Troubleshooting

### Connection Issues
- **Error**: "Bağlantı hatası"
- **Solution**: 
  1. Check Tailscale on both devices: `tailscale status`
  2. Verify backend is running: `curl http://100.79.166.110:1571/health`
  3. Check firewall: `sudo ufw status`

### SSH Terminal Not Connecting
- Ensure SSH is enabled on Ubuntu: `sudo systemctl status ssh`
- Check credentials (default user: `ubuntu`)
- Verify port 22 is open

### Windows Boot Not Working
- Backend needs sudo permissions: `sudo visudo` → Add `ubuntu ALL=(ALL) NOPASSWD: /sbin/grub-reboot, /sbin/reboot`
- Verify GRUB entry: `grep -i windows /boot/grub/grub.cfg`

### iOS Build Fails
- Code signing issue: Need Apple Developer account
- Alternative: Test on macOS first
- Check Xcode: `xcode-select --install`

## 📝 Development Notes

### Dependencies
```yaml
dependencies:
  flutter:
    sdk: flutter
  dio: ^5.4.0              # HTTP client
  provider: ^6.1.1         # State management
  fl_chart: ^0.66.0        # Charts
  dartssh2: ^2.9.0         # SSH client
  xterm: ^4.0.0            # Terminal emulation
  shared_preferences: ^2.2.2
```

### Hot Reload
```bash
# macOS app supports hot reload (r key)
flutter run -d macos
# Press 'r' to reload, 'R' to restart
```

### Build Release
```bash
# iOS
flutter build ios --release
# macOS
flutter build macos --release
```

## 🌟 Features Roadmap

- [ ] Real-time WebSocket updates
- [ ] GPU training progress charts
- [ ] Energy cost calculator
- [ ] Network traffic graphs
- [ ] Process manager
- [ ] System logs viewer
- [ ] Dark/Light theme toggle
- [ ] Multiple server profiles

## 📄 License

MIT License - Free to use and modify

## 👨‍�� Author

**snnunvr** - [GitHub](https://github.com/snnunvr)

---

**Last Updated**: October 19, 2025  
**Flutter Version**: 3.35.6  
**iOS Target**: 13.0+  
**Server**: Ubuntu 6.14.0-33-generic

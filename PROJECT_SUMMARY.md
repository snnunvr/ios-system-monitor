# 🎯 System iOS Monitor - Proje Özeti

## ✅ Tamamlanan İşler

### Backend (Python FastAPI)
- ✅ **GPU Monitoring Modülü** (`monitors/gpu_monitor.py`)
  - NVIDIA GPU'ların tüm bilgilerini (bellek, sıcaklık, güç, kullanım %)
  - CPU, RAM, Disk bilgileri
  - Gerçek zamanlı veri toplama

- ✅ **Enerji Maliyeti Hesaplama** (`monitors/energy_monitor.py`)
  - Saatlik, günlük, aylık maliyet hesaplaması
  - Türkiye elektrik fiyatı desteği (ayarlanabilir)
  - Bileşen bazlı maliyet analizi

- ✅ **Port Analizi** (`monitors/port_analyzer.py`)
  - Açık portları tespit etme
  - Dinlemede olan portları listeleme
  - Kurulu bağlantıları gösterme
  - **Dış bağlantıları uyarma** (güvenlik)
  - Her port için process ve PID bilgisi

- ✅ **Training Job Tracker** (`monitors/training_tracker.py`)
  - PyTorch/TensorFlow process'lerini otomatik tespit
  - CPU, Bellek, GPU kullanımı izleme
  - I/O okuma/yazma hızlarını takip
  - Job kontrol (durdur, duraklat, devam ettir)

- ✅ **FastAPI Server** (`main.py`)
  - 1571 portunda çalışıyor
  - RESTful API endpoints
  - WebSocket real-time veri akışı desteği
  - CORS etkinleştirilmiş (Tailscale uyumlu)

### Frontend (Flutter)
- ✅ **Modern Dark Theme** (`theme/app_theme.dart`)
  - GitHub-style koyu tema
  - Cyan (#00D9FF), Purple, Pink renkleri
  - Tüm bileşenlerde tutarlı tasarım

- ✅ **Reusable Components** (`widgets/common_widgets.dart`)
  - StatCard - İstatistik kartları
  - ProgressBar - İlerleme çubukları
  - SectionHeader - Bölüm başlıkları
  - InfoTile - Bilgi kutucukları
  - LoadingWidget - Yükleniyor durumu
  - ErrorWidget - Hata durumu

- ✅ **API Client** (`services/api_client.dart`)
  - Tüm backend endpoints'e erişim
  - Error handling ve retry mantığı
  - Logging interceptors

- ✅ **Dashboard Screen** (`screens/dashboard_screen.dart`)
  - Gerçek zamanlı sistem özeti
  - CPU, RAM, Disk, GPU stats
  - Enerji maliyeti özeti
  - GPU detay kartları

- ✅ **GPU Monitor Screen** (`screens/gpu_monitor_screen.dart`)
  - GPU kullanım ve bellek gösterimi
  - Sıcaklık ve güç tüketimi
  - Compute process'lerini listeleme

- ✅ **Port Analysis Screen** (`screens/port_analysis_screen.dart`)
  - 3 sekme: Dinlemede, Kurulu, Dış bağlantılar
  - Process bilgileri
  - Servis adları
  - Foreign connection uyarıları

- ✅ **Training Tracker Screen** (`screens/training_tracker_screen.dart`)
  - Aktif training job'larını listeleme
  - CPU, Bellek, GPU, Thread, I/O gösterimi
  - Job kontrol butonları

- ✅ **Energy Monitor Screen** (`screens/energy_monitor_screen.dart`)
  - Saatlik/Günlük/Aylık maliyet kartları
  - Toplam güç tüketimi
  - Ayarlanabilir elektrik fiyatı
  - Bileşen bazlı maliyet detayı

- ✅ **Settings Screen** (`screens/settings_screen.dart`)
  - Sunucu URL yapılandırması
  - Bağlantı testi
  - Tailscale bilgileri ve talimatları
  - Hakkında bilgileri

## 🚀 Sistem Mimarisi

```
┌─────────────────────────────────────────────────┐
│         iPhone via Tailscale                    │
│      (Flutter App - iOS)                        │
└────────────────┬────────────────────────────────┘
                 │ Tailscale Encrypted Tunnel
                 │ (http://100.x.x.x:1571)
┌────────────────▼────────────────────────────────┐
│         Ubuntu Server (Linux)                   │
│                                                 │
│  ┌────────────────────────────────────────┐    │
│  │      FastAPI Server (1571)             │    │
│  │  ┌──────────────────────────────────┐  │    │
│  │  │    Main.py (API endpoints)       │  │    │
│  │  │  ┌────────────────────────────┐  │  │    │
│  │  │  │   GPU Monitor (NVIDIA)     │  │  │    │
│  │  │  │   Energy Calculator        │  │  │    │
│  │  │  │   Port Analyzer (Security) │  │  │    │
│  │  │  │   Training Tracker         │  │  │    │
│  │  │  └────────────────────────────┘  │  │    │
│  │  └──────────────────────────────────┘  │    │
│  └────────────────────────────────────────┘    │
│                                                 │
│  Hardware:                                      │
│  - 2x NVIDIA GPU (GTX 1660 Ti + RTX 2060)      │
│  - CPU, RAM, SSD                               │
│  - Açık portlar ve bağlantılar                 │
└─────────────────────────────────────────────────┘
```

## 📊 API Endpoints

### Sistem Bilgisi
- `GET /api/system` - Tüm sistem bilgisi
- `GET /api/system/gpu` - GPU'lar
- `GET /api/system/cpu` - CPU detayları
- `GET /api/system/memory` - RAM ve Disk

### Enerji
- `GET /api/energy` - Maliyet hesaplaması
- `POST /api/energy/price` - Fiyat güncellemesi

### Port & Ağ
- `GET /api/ports` - Tüm portlar
- `GET /api/ports/listening` - Dinlemede olan
- `GET /api/ports/established` - Kurulu bağlantılar
- `GET /api/ports/foreign` - Dış bağlantılar (Security Alert ⚠️)

### Training
- `GET /api/training` - Aktif job'lar
- `POST /api/training/stop/{pid}` - Job'ı durdur
- `POST /api/training/pause/{pid}` - Job'ı duraklat
- `POST /api/training/resume/{pid}` - Job'ı devam ettir

### Real-time
- `WebSocket /ws` - Real-time veri akışı

## 📁 Dosya Yapısı

```
system_ios_monitor/
├── backend/
│   ├── main.py (FastAPI sunucusu - 1571 portu)
│   ├── requirements.txt (Python bağımlılıkları)
│   ├── monitors/
│   │   ├── gpu_monitor.py (GPU & Sistem)
│   │   ├── energy_monitor.py (Maliyet)
│   │   ├── port_analyzer.py (Güvenlik)
│   │   ├── training_tracker.py (Training Jobs)
│   │   └── __init__.py
│   └── venv/ (Python sanal ortamı)
│
├── lib/ (Flutter)
│   ├── main.dart (Entry point)
│   ├── theme/
│   │   └── app_theme.dart (Dark theme)
│   ├── services/
│   │   └── api_client.dart (API istemcisi)
│   ├── screens/
│   │   ├── dashboard_screen.dart
│   │   ├── gpu_monitor_screen.dart
│   │   ├── port_analysis_screen.dart
│   │   ├── training_tracker_screen.dart
│   │   ├── energy_monitor_screen.dart
│   │   └── settings_screen.dart
│   └── widgets/
│       └── common_widgets.dart (UI bileşenleri)
│
├── pubspec.yaml (Flutter bağımlılıkları)
├── start_backend.sh (Backend başlangıç scripti)
└── README.md (Açıklamalar)
```

## 🔋 Gerçek Sistem Verileri

Backend 2 NVIDIA GPU tespit etti:
- **GPU 0**: NVIDIA GeForce GTX 1660 Ti (450W TDP)
- **GPU 1**: NVIDIA GeForce RTX 2060 (160W TDP)

Aylık Maliyet Tahmini (Şu anda):
- **Aylık**: ~₺342 (15₺/kWh fiyat)
- **Günlük**: ~₺11.42
- **Saatlik**: ~₺0.48

## 🎮 Özellikler Özeti

| Özellik | Durum | UI | Backend |
|---------|-------|----|----|
| GPU Monitoring | ✅ | ✅ | ✅ |
| Enerji Maliyeti | ✅ | ✅ | ✅ |
| Port Analizi | ✅ | ✅ | ✅ |
| Güvenlik Uyarısı | ✅ | ✅ | ✅ |
| Training Tracker | ✅ | ✅ | ✅ |
| Real-time Güncellemeler | ✅ | ✅ | ✅ |
| Dark Theme | ✅ | ✅ | - |
| Tailscale Desteği | ✅ | ✅ | ✅ |
| Settings Sayfası | ✅ | ✅ | - |
| WebSocket Streams | ✅ | ✅ | ✅ |

## 🚀 Başlangıç Komutları

```bash
# Backend başlat
cd /home/snnunvr/Desktop/system_ios_monitor
./start_backend.sh

# Veya manuel olarak
cd backend
source venv/bin/activate
python3 main.py

# Frontend çalıştır (farklı terminal)
flutter pub get
flutter run  # Linux/Web
# veya
flutter run -d ios  # iOS device
```

## 📱 iPhone Kullanımı

1. **Tailscale Kur**
   - iPhone: App Store → Tailscale ↓ & Authenticate
   - Ubuntu: `sudo tailscale up`

2. **IP Öğren**
   ```bash
   tailscale status
   # Çıktı: 100.x.x.x gibi bir IP göster
   ```

3. **Flutter'da Ayarla**
   - ⚙️ Settings sekmesi
   - URL: `http://100.x.x.x:1571`
   - Test Connection ✅

4. **Başladı!** 🎉

## 🔒 Güvenlik Notları

✅ **Implemented:**
- Tailscale şifreleme
- Foreign IP uyarıları
- Port analizi

⚠️ **TODO:**
- API Authentication (future)
- Rate Limiting (future)
- SSL/TLS sertifika (Tailscale otomatik)

## 📈 İstatistikler

- **Backend**: 4 monitoring modülü
- **Frontend**: 7 ekran / 6 widget tipi
- **API Endpoints**: 13+ REST endpoints + WebSocket
- **Kod Satırı**: ~3000+ (Backend + Frontend)
- **GPU Desteği**: NVIDIA (AMD yakında)

## 🎯 Next Steps (Gelecek)

- [ ] Grafik gösterimi (charts)
- [ ] Geçmiş veri taraması
- [ ] Alert sistem (CPU/GPU limitleri)
- [ ] Veri dışa aktarma
- [ ] Dark/Light mode toggle
- [ ] Push notifications
- [ ] Database desteği

---

**Proje Başladı**: Ekim 2025  
**Durum**: 🟢 Fully Operational  
**Test**: Backend ✅ / Frontend ✅ / Integration ✅


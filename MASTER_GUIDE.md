# 📱 System iOS Monitor - Master Rehberi

## 🎯 Proje Özeti

**System iOS Monitor**, Ubuntu'da çalışan sisteminizin tüm verilerini (özellikle GPU, enerji tüketimi, port analizi, training job'ları) iPhone'unda Tailscale üzerinden izleyebilmeniz için oluşturulmuş profesyonel bir monitoring uygulamasıdır.

```
Ubuntu PC (Backend + GPU/Monitoring)
         ↓ (FastAPI 1571)
    Tailscale Network
         ↓ (Encrypted Tunnel)
    iPhone (Flutter UI)
```

---

## 📚 Hızlı Linkler

| Belge | Amaç | Başlama Zamanı |
|-------|------|---|
| **[QUICKSTART.sh](QUICKSTART.sh)** | Adım adım kurulum talimatları | 5 dakika |
| **[iOS_DEPLOYMENT.md](iOS_DEPLOYMENT.md)** | iPhone'a deploy etme rehberi | 15 dakika |
| **[API_REFERENCE.md](API_REFERENCE.md)** | API endpoint detayları | Ref. |
| **[PROJECT_SUMMARY.md](PROJECT_SUMMARY.md)** | Proje yapısı ve özellikler | Ref. |
| **[README.md](README.md)** | Başlangıç kılavuzu | 3 dakika |

---

## 🚀 Başlamak için 3 Adım (5 Dakika)

### 1️⃣ Backend'i Başlat

```bash
cd /home/snnunvr/Desktop/system_ios_monitor
./start_backend.sh
```

**Beklenen çıktı:**
```
INFO:     Uvicorn running on http://0.0.0.0:1571
INFO:     Application startup complete
```

✅ Backend hazır!

---

### 2️⃣ Tailscale'i Etkinleştir

```bash
# Ubuntu'da (yeni terminal)
sudo tailscale up

# Link'i browser'da aç ve authenticate et
# Sonra IP'yi öğren
tailscale status
```

**Çıktı örneği:**
```
100.64.5.23     ubuntu       active
100.74.2.89     iphone       active
```

👉 **Ubuntu IP**: `100.64.5.23` (kopyala!)

---

### 3️⃣ iPhone'da Uygulamayı Yapılandır

1. **App Store** → `Tailscale` indir ve bağla
2. **Flutter uygulamayı çalıştır** (Xcode veya `flutter run -d iphone`)
3. **Ayarlar** (⚙️) → URL: `http://100.64.5.23:1571`
4. **Test Bağlantı** → ✅ Başarılı!

**Bitti!** Artık iPhone'da tüm verilerini görebilirsin 🎉

---

## 📊 Uygulamada Ne Görebilirsin?

### Dashboard 📈
- CPU, RAM, Disk kullanımı
- 2 NVIDIA GPU (GTX 1660 Ti, RTX 2060)
- Gerçek zamanlı sıcaklık ve güç tüketimi
- 2 saniye otomatik yenileme

### GPU Monitor 🎮
- GPU sockets ve bellek ayrıntıları
- Aktif süreçler listesi
- Sıcaklık ve güç çizgileri

### Port Analizi 🔌
- **Dinlemede**: Açık portlar (1571, 5432, 6379, vb.)
- **Kurulu**: İstenen bağlantılar
- **Dış**: Yabancı bağlantılar ⚠️

### Training Tracker 🚀
- PyTorch/TensorFlow job'ları
- GPU bellek tüketimi
- Durdur/Ara/Devam kontrolleri

### Enerji Monitor ⚡
- **Gerçek Zamanlı Maliyet**
  - Saatlik: ~₺0.48
  - Aylık: ~₺342.74
- Elektrik fiyatı değiştir (₺/kWh)
- Komponente göre ayrıntı

### Ayarlar ⚙️
- Sunucu URL yapılandırması
- Test Bağlantı
- Tailscale setup talimatları
- Versiyon bilgisi

---

## 🛠️ Teknoloji Stack'i

### Backend (Ubuntu)
```
Python 3.12
├── FastAPI 0.104.1 (REST API + WebSocket)
├── psutil 5.9.6 (Sistem metrikleri)
├── nvidia-ml-py3 (GPU verileri via nvidia-smi)
└── Uvicorn (ASGI server)
```

### Frontend (iPhone)
```
Flutter 3.0+
├── Provider 6.0.0 (State yönetimi)
├── Dio 5.3.0 (HTTP client)
└── Material 3 (UI theme)
```

### Network
```
Tailscale (Encrypted tunnel)
└── Port 1571 (Backend API)
```

---

## 📁 Proje Yapısı

```
system_ios_monitor/
├── backend/
│   ├── main.py                 # FastAPI sunucusu
│   ├── monitors/
│   │   ├── gpu_monitor.py      # GPU + sistem verileri
│   │   ├── energy_monitor.py   # Enerji maliyeti
│   │   ├── port_analyzer.py    # Port analizi
│   │   └── training_tracker.py # Training job'ları
│   └── venv/                   # Python virtual env
│
├── lib/
│   ├── main.dart               # App entry point
│   ├── services/
│   │   └── api_client.dart     # Backend HTTP client
│   ├── screens/
│   │   ├── dashboard_screen.dart
│   │   ├── gpu_monitor_screen.dart
│   │   ├── port_analysis_screen.dart
│   │   ├── training_tracker_screen.dart
│   │   ├── energy_monitor_screen.dart
│   │   └── settings_screen.dart
│   ├── theme/
│   │   └── app_theme.dart      # Dark theme
│   └── widgets/
│       └── common_widgets.dart # Reusable components
│
├── ios/                        # iOS project
├── android/                    # Android project
│
├── QUICKSTART.sh               # Setup talimatları (5 min)
├── iOS_DEPLOYMENT.md           # iPhone deploy (15 min)
├── API_REFERENCE.md            # API endpoints
├── PROJECT_SUMMARY.md          # Detaylı özet
└── README.md                   # Başlama kılavuzu
```

---

## 🔑 Önemli Komutlar

### Backend

```bash
# Backend'i başlat
./start_backend.sh

# API döcsüne erişim
http://localhost:1571/docs

# API test et
curl http://localhost:1571/api/system
curl http://localhost:1571/api/energy
curl http://localhost:1571/api/ports

# Backend'i durdur
pkill -f "python3 main.py"
```

### Tailscale

```bash
# Tailscale'i etkinleştir
sudo tailscale up

# Status kontrol et
tailscale status

# Ping test (iPhone'a)
tailscale ping 100.y.y.y

# IP göster
tailscale ip -4
```

### Flutter

```bash
# Bağlı cihazları göster
flutter devices

# iPhone'a deploy et
flutter run -d iphone

# Logları gör
flutter logs

# Build etiketi ile
flutter run -d iphone --tag myapp
```

---

## 🐛 Yaygın Sorunlar

### ❌ "Sunucuya bağlanamadı"

**Kontrol Et:**
```bash
# 1. Backend çalışıyor mu?
ps aux | grep "python3 main.py"

# 2. Port açık mı?
curl http://localhost:1571/api/health

# 3. Tailscale bağlı mı?
tailscale status

# 4. URL doğru mu?
# ✅ http://100.64.5.23:1571
# ❌ https://... (https değil)
```

---

### ❌ "Tailscale bağlantısı yok"

**Çözüm:**
```bash
# Ubuntu
sudo tailscale up

# iPhone
Tailscale App → Sign in → "Connect"

# Doğrula
tailscale status
```

---

### ❌ "GPU görmüyor"

**Kontrol Et:**
```bash
# NVIDIA sürücü kurulu mu?
nvidia-smi

# Çıktı yoksa
sudo apt install nvidia-driver-XXX
```

---

### ❌ "Flutter derlenmiyor"

**Çözüm:**
```bash
flutter clean
flutter pub get
flutter pub get  # 2x çalıştır
cd ios && pod install && cd ..
flutter run -d iphone
```

---

## 📱 Kullanım Örneği (Tipik Workflow)

### Sabah (Sistem Kontrolü)

1. iPhone'u aç, Flutter uygulamasını kısaca kontrol et
2. **Dashboard**'da sistem durumuna bak:
   - CPU hangi seviyede?
   - GPU sorun var mı?
   - Enerji maliyeti ne?

### Gün içinde (Training Monitoru)

1. Model eğitmeye başla (Ubuntu'da)
2. **Training Tracker** açıp monitoring yap
3. GPU belleği ve sıcaklığı izle
4. Gerekirse "Durdur" butonuyla job'u kontrol et

### Akşam (Güvenlik Kontrolü)

1. **Port Analizi** açıp şüpheli bağlantıları kontrol et
2. Yabancı IP'ler varsa markası kontrol et
3. **Enerji Monitor**'da günlük maliyet gözden geçir

---

## 🔐 Güvenlik

✅ **Şifreli**: Tailscale tüm trafiği TLS ile şifreler
✅ **Özel**: Sadece Tailscale ağında erişim
✅ **Yalıtılmış**: Public internet'e açık değil

Tailscale kurulumun güvenli olması:
```bash
# Ubuntu firewall
sudo ufw allow from 100.0.0.0/8 to any port 1571

# Diğer portlara erişim yok
sudo ufw deny from any to any port 1571
```

---

## 📊 API Endpoints (Hızlı Referans)

| Endpoint | Metod | Amaç |
|----------|-------|------|
| `/api/system` | GET | CPU, RAM, Disk, GPU |
| `/api/gpu/{id}` | GET | GPU detayları |
| `/api/energy` | GET | Enerji maliyeti |
| `/api/ports` | GET | Port analizi |
| `/api/training-jobs` | GET | Training job'ları |
| `/api/health` | GET | Sistem sağlığı |
| `/ws` | WebSocket | Gerçek zamanlı veriler |

Detaylar için: [API_REFERENCE.md](API_REFERENCE.md)

---

## 💡 İpuçları & Tricks

### Tailscale IP'si Değişti mi?

```bash
# Yeni IP'yi öğren
tailscale status

# Flutter'da Settings'de URL'yi güncelle
```

### Backend Loglarını Görmek

```bash
# start_backend.sh çalıştırıldığında log gösterilir
./start_backend.sh 2>&1 | tee backend.log

# Dosyadan oku
tail -f backend.log
```

### WebSocket Bağlantısı Kesildiyse

Uygulama otomatik yeniden bağlanır (max 3 saniye)

### Training Job'unu Sustur

Training sırasında:
1. **Training Tracker** açı
2. Job'ı bul
3. **Durdur** butonuna tıkla

---

## 🎓 Öğrenme Kaynakları

- **Flutter**: https://flutter.dev/docs
- **FastAPI**: https://fastapi.tiangolo.com/
- **Tailscale**: https://tailscale.com/kb/
- **NVIDIA SDK**: https://developer.nvidia.com/

---

## 📞 Destek

### Kod Nerede?
- Proje klasörü: `/home/snnunvr/Desktop/system_ios_monitor/`

### Logları Nasıl Görürüm?

**Backend:**
```bash
./start_backend.sh
# Terminal'de çıktı görünür
```

**Flutter:**
```bash
flutter logs
```

---

## 🎉 Başarıyla Başladığını Bilmen İçin

✅ Backend çalışıyor
✅ Tailscale bağlı (her iki tarafta)
✅ iPhone'da uygulamayı çalıştırdın
✅ Sunucu URL'sini girmişsin
✅ Test Bağlantı yeşil (✅)
✅ Dashboard veri gösteriyor

---

## 📅 Sık Yapılan İşlemler

| İş | Komut | Terminal | Zaman |
|---|---|---|---|
| Backend başlat | `./start_backend.sh` | Ubuntu | 2s |
| Status kontrol | `tailscale status` | Ubuntu | 1s |
| iPhone deploy | `flutter run -d iphone` | macOS | 30s |
| Logları gör | `flutter logs` | Terminal | Live |
| API test | `curl http://localhost:1571/api/system` | Ubuntu | 1s |

---

## 🚀 Sonraki Adımlar

1. **[QUICKSTART.sh](QUICKSTART.sh)** adımlarını takip et
2. **[iOS_DEPLOYMENT.md](iOS_DEPLOYMENT.md)** ile iPhone'a deploy et
3. Ayarlarında URL'yi `http://100.x.x.x:1571` olarak gir
4. **Test Bağlantı**'ya tıkla
5. ✅ Başarılı! Monitoring'i başla

---

## 📚 Detaylı Dökümanlar

Daha fazla bilgi için:

- **Backend Kurulumu**: [README.md](README.md)
- **iOS Deployment**: [iOS_DEPLOYMENT.md](iOS_DEPLOYMENT.md)
- **API Detayları**: [API_REFERENCE.md](API_REFERENCE.md)
- **Proje Yapısı**: [PROJECT_SUMMARY.md](PROJECT_SUMMARY.md)

---

## 🎯 Özet (1 dakika)

```
System iOS Monitor = Ubuntu PC Monitoring + iPhone UI + Tailscale Network
```

**Kurulum**: 5 dakika
**Deploy**: 15 dakika  
**Kullanım**: ∞ (lifelong!)

---

**Oluşturma**: 2024-01-15
**Versiyon**: 1.0
**Durum**: ✅ Hazır ve Çalışır

Sorular? [Dökümentasyon](.) klasörüne bak!

🚀 **Happy Monitoring!**

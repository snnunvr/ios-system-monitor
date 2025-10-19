# 🔧 Sorun Giderme Rehberi

## 🆘 Hızlı Çözümler

### ❌ Backend Başlamıyor

**Hata**: `./start_backend.sh: Permission denied`

**Çözüm**:
```bash
chmod +x ./start_backend.sh
./start_backend.sh
```

---

**Hata**: `Port 1571 is already in use`

**Çözüm**:
```bash
# Hangi proses kullanıyor?
lsof -i :1571

# Kapat
kill -9 <PID>

# Veya başka port kullan
# backend/main.py içinde 1571'i değiştir
```

---

**Hata**: `ModuleNotFoundError: No module named 'fastapi'`

**Çözüm**:
```bash
cd /home/snnunvr/Desktop/system_ios_monitor/backend
source venv/bin/activate
pip install fastapi uvicorn psutil nvidia-ml-py3
```

---

### ❌ Tailscale Sorunları

**Hata**: `tailscale: command not found`

**Çözüm**:
```bash
curl -fsSL https://tailscale.com/install.sh | sh
sudo systemctl restart tailscaled
```

---

**Hata**: iPhone Tailscale'de "Offline" gösteriyor

**Çözüm**:
```bash
# Ubuntu'da
sudo tailscale up

# iPhone'da
Tailscale App → Sign Out → Sign In

# Kontrol
tailscale status
```

---

**Hata**: "Can't reach Ubuntu from iPhone"

**Çözüm**:
```bash
# Ubuntu'da ping test
tailscale ping <iPhone-IP>

# Örnek: tailscale ping 100.74.2.89

# Firewall kontrol
sudo ufw status
sudo ufw allow from 100.0.0.0/8 to any port 1571
```

---

### ❌ Flask/API Bağlantı Hatası

**Hata**: "Connection refused" (iPhone'dan)

**Adım 1**: Backend çalışıyor mu?
```bash
ps aux | grep "python3 main.py"
```

Çıktı yoksa:
```bash
./start_backend.sh &
```

---

**Adım 2**: Port açık mı?
```bash
curl http://localhost:1571/api/health
```

JSON dönemiyorsa:
```bash
# Log'lara bak
tail -20 backend.log

# Backend'i verbose mod'da çalıştır
python3 backend/main.py --log-level debug
```

---

**Adım 3**: URL doğru mu?
```bash
# Ubuntu IP kontrol et
tailscale status

# iPhone'da Settings'de URL'yi düzenle
# ✅ Format: http://100.x.x.x:1571
# ❌ https:// (HTTPS değil)
# ❌ localhost (Tailscale IP olmalı)
```

---

**Adım 4**: Firewall sorun mu?
```bash
# Kuralları kontrol et
sudo ufw status

# Port 1571'i aç
sudo ufw allow 1571

# Veya daha spesifik
sudo ufw allow from 100.0.0.0/8 to any port 1571
```

---

### ❌ GPU Verisi Görmüyor

**Hata**: GPU Monitor boş veya "No GPU Found"

**Adım 1**: NVIDIA kurulu mu?
```bash
nvidia-smi
```

Çıktı görmüyorsan:
```bash
# Sürücü versiyonunu kontrol et
nvidia-smi --query-gpu=driver_version --format=csv,noheader

# Kurulu değilse
sudo apt update
sudo apt install nvidia-driver-XXX
sudo reboot
```

---

**Adım 2**: PYNVML kütüphanesi kurulu mu?
```bash
python3 -c "import pynvml; print(pynvml.nvmlSystemGetDriverVersion())"
```

Hata alırsan:
```bash
cd backend
source venv/bin/activate
pip install nvidia-ml-py3
```

---

**Adım 3**: Backend'de GPU algılanıyor mu?
```bash
# Test et
curl http://localhost:1571/api/system | grep -A 20 "gpus"
```

GPUs boşsa backend/main.py'de error var demektir:
```bash
# Debug mod'da çalıştır
python3 -u backend/main.py
```

---

### ❌ Training Tracker Boş

**Sebep**: Aktif training process yok

**Çözüm**: Training başlat
```bash
# Terminal'de
cd ~/your-project
python3 train.py

# Veya PyTorch
python3 -c "
import torch
for i in range(1000):
    x = torch.randn(1000, 1000).cuda()
    y = (x @ x.T).mean()
"
```

App'te otomatik gösterilecek.

---

### ❌ Flutter Derlenmiyor

**Hata**: `CocoaPods could not find...`

**Çözüm**:
```bash
cd /home/snnunvr/Desktop/system_ios_monitor

# Cache temizle
flutter clean

# Pub paketi indir
flutter pub get

# iOS pods yükle
cd ios
pod repo update
pod install
cd ..

# Tekrar dene
flutter run -d iphone
```

---

**Hata**: `Xcode build failed`

**Çözüm**:
```bash
# Project açıksan kapat
# Terminalde:
rm -rf ios/Pods
rm -rf ios/Podfile.lock
cd ios && pod install && cd ..

# Xcode tekrar aç
open ios/Runner.xcworkspace
```

---

**Hata**: Signing certificate yok

**Çözüm**:
1. Xcode → Preferences → Accounts
2. Sağ alt + butonuna tıkla
3. Apple ID gir
4. "Download Manual Profiles" veya "Download All Profiles"
5. Ok

---

### ❌ iPhone Uygulaması Çöküyor

**Hata**: App açılırken crash

**Adım 1**: Log'ları kontrol et
```bash
flutter logs
```

---

**Adım 2**: Null pointer hatası mı?
```
NoSuchMethodError: The method 'xxx' was called on null.
```

Çözüm: `lib/services/api_client.dart` kontrol et:
```dart
// Baseurl boş muydu?
if (baseUrl == null) {
  throw Exception("Server URL not set");
}
```

---

**Adım 3**: Bağlantı hatası mı?
```
SocketException: Failed to connect to...
```

Çözüm:
- Tailscale bağlı mı?
- Backend çalışıyor mu?
- URL doğru mu?

---

### ❌ Port Analizi Boş

**Sebep**: ss/netstat komutu yetersiz izinli

**Çözüm**:
```bash
# sudo izni ekle
sudo usermod -aG netadmin $USER

# Veya script'i sudo ile çalıştır
sudo python3 backend/main.py
```

---

**Sebep**: Komut çıktısı parse edilemiyor

**Test Et**:
```bash
ss -tulnp
# veya
netstat -tulnp

# Çıktı görmüyorsan cmd yok
sudo apt install net-tools
```

---

### ❌ Enerji Maliyeti 0₺

**Hata**: Enerji hesaplaması çalışmıyor

**Çözüm**:
```bash
# GPU power draw alınıyor mu?
nvidia-smi --query-gpu=power.draw --format=csv,noheader

# Çıktı görüyorsan, backend'i yeniden başlat
pkill -f "python3 main.py"
./start_backend.sh

# Test et
curl http://localhost:1571/api/energy | python3 -m json.tool
```

---

## 🔍 Detaylı Debug Prosedürü

### 1. Sistem Durumunu Kontrol Et

```bash
echo "=== BACKEND ==="
ps aux | grep "python3 main.py"

echo "=== TAILSCALE ==="
sudo tailscale status

echo "=== GPU ==="
nvidia-smi

echo "=== PORT ==="
sudo ufw status
lsof -i :1571

echo "=== NETWORK ==="
ip route show
```

---

### 2. Backend Test'ini Çalıştır

```bash
echo "=== API Health ==="
curl http://localhost:1571/api/health

echo "=== System Info ==="
curl http://localhost:1571/api/system | head -50

echo "=== GPU Info ==="
curl http://localhost:1571/api/gpu/0

echo "=== Energy ==="
curl http://localhost:1571/api/energy

echo "=== Ports ==="
curl http://localhost:1571/api/ports | head -50
```

---

### 3. Network Test'ini Çalıştır

```bash
echo "=== Local Connection ==="
curl http://localhost:1571/api/health

echo "=== Tailscale Connection ==="
TAILSCALE_IP=$(tailscale ip -4)
curl http://$TAILSCALE_IP:1571/api/health

echo "=== Ping iPhone ==="
IPHONE_IP=$(tailscale status | grep iphone | awk '{print $1}')
tailscale ping $IPHONE_IP
```

---

### 4. Flutter Debug Log'ları

```bash
# Verbose mode
flutter run -d iphone -v > flutter_debug.log 2>&1

# Real-time logs
flutter logs

# Spesifik tag ile
flutter logs --grep "api_client"
```

---

## 📋 Kontrol Listesi

Sorun yaşıyorsan şunları kontrol et (sırasıyla):

### Backend Kontrol Listesi
- [ ] `./start_backend.sh` çalışıyor
- [ ] `ps aux | grep python3` PID gösteriyor
- [ ] `curl http://localhost:1571/api/health` 200 dönüyor
- [ ] `curl http://localhost:1571/api/system` JSON dönüyor
- [ ] Port 1571 açık (`ufw status`)

### Tailscale Kontrol Listesi
- [ ] `sudo tailscale up` çalıştırıldı
- [ ] `tailscale status` her iki cihazı gösteriyor
- [ ] iPhone Tailscale App'te "Connected" yazıyor
- [ ] `tailscale ping <iPhone-IP>` yanıt veriyor
- [ ] `firewall allow from 100.0.0.0/8` kuralı var

### Flutter Kontrol Listesi
- [ ] `flutter devices` iPhone'u gösteriyor
- [ ] `flutter run -d iphone` hatasız başlıyor
- [ ] App açılırken crash vermiyorsa
- [ ] Settings'de URL girilebiliyor
- [ ] "Test Bağlantı" yeşil (✅)

### Network Kontrol Listesi
- [ ] URL format doğru (`http://100.x.x.x:1571`)
- [ ] URL'de typo yok
- [ ] Port 1571 backend'de
- [ ] HTTPS değil HTTP
- [ ] Tailscale bağlantısı aktif

---

## 🚨 Kritik Hatalar

### Error: "Permission denied" (1571 portunda)

```bash
# Port 1024 altında ise root gerekli
sudo ./start_backend.sh

# Veya port değiştir
# backend/main.py -> PORT = 8000
```

---

### Error: "CUDA out of memory"

GPU memory doldu demektir.

```bash
# GPU bellegini temizle
nvidia-smi --gpu-reset

# Veya GPU'yu kapat
sudo systemctl restart cuda
```

---

### Error: "Connection timeout"

Tailscale çıktı demektir.

```bash
# Reconnect
sudo tailscale up

# VPN restart
sudo systemctl restart tailscaled
```

---

## 📞 İletişim & Destek

Sorun çözemiyorsan:

1. **Log dosyaları topla**
   ```bash
   mkdir debug_logs
   cp backend.log debug_logs/
   flutter logs > debug_logs/flutter.log 2>&1
   ps aux | grep python3 > debug_logs/processes.log
   tail -20 /var/log/tailscale/tailscaled.log > debug_logs/tailscale.log
   ```

2. **Bug report'unu yaz**
   - Hata mesajı
   - Komut ve çıktısı
   - Sistem info (`uname -a`)
   - Tailscale status

3. **Debug klasörünü sakla**
   ```bash
   tar -czf debug_logs.tar.gz debug_logs/
   ```

---

## ✅ Başarı Kriteri

Tüm testler geçtiyse:

```bash
✅ Backend çalışıyor (PID gösteriliyor)
✅ API responsive (JSON dönüyor)
✅ GPU algılanıyor (nvidia-smi çalışıyor)
✅ Tailscale bağlı (status her iki cihaz gösteriyor)
✅ iPhone bağlanıyor (URL girilebiliyor)
✅ Dashboard veri gösteriyor (CPU %, RAM %, GPU %)
✅ Tüm ekranlar yüklenebiliyor
```

**Hepsi ✅ ise Tebrikler! 🎉**

---

**Dokümantasyon**: 2024-01-15
**Son Güncelleme**: 2024-01-15
**Kapsam**: Tüm yaygın sorunlar

# 📱 iOS Deployment Rehberi

## Genel Bakış

Bu rehber, Flutter uygulamasını iPhone'a Tailscale üzerinden deploy etmek ve kullanmak için adım adım talimatlar içerir.

---

## 📋 Ön Koşullar

- ✅ Ubuntu sunucusunda backend çalışıyor (`./start_backend.sh`)
- ✅ Tailscale kurulu ve çalışıyor (Ubuntu ve iPhone)
- ✅ Flutter SDK yüklü (v3.0+)
- ✅ Xcode yüklü (macOS'ta)
- ✅ Apple Developer Account (gerekirse)
- ✅ USB kablosu veya wireless debugging

---

## 🚀 Adım 1: Ubuntu'da Backend'i Hazırla

### 1.1 Backend'i Başlat

```bash
cd /home/snnunvr/Desktop/system_ios_monitor
./start_backend.sh
```

Terminal çıktısı:

```
INFO:     Uvicorn running on http://0.0.0.0:1571
INFO:     Application startup complete
```

✅ Backend 1571 portunda çalışıyor

---

### 1.2 Backend'in Çalıştığını Doğrula

```bash
# Başka bir terminal aç
curl http://localhost:1571/api/health
```

Beklenen yanıt:

```json
{
  "status": "healthy",
  "uptime_seconds": 42
}
```

✅ Backend sağlıklı

---

## 🌐 Adım 2: Tailscale'i Ubuntu'da Etkinleştir

### 2.1 Tailscale Kurulumu

```bash
# Tailscale'i indir ve kur (henüz kurulu değilse)
curl -fsSL https://tailscale.com/install.sh | sh

# Tailscale'i başlat
sudo tailscale up
```

### 2.2 Tailscale Kimlik Doğrulama

Çıktıda göreceğin link:

```
To authenticate, visit:
https://login.tailscale.com/a/1a2b3c4d5e6f
```

➡️ Link'i browser'da aç → Hesaba giriş yap → Cihazı onay

### 2.3 Ubuntu'nun Tailscale IP'sini Öğren

```bash
tailscale status
```

Çıktı:

```
100.x.x.x       ubuntu           snnunvr@   active; last seen 2m ago
100.y.y.y       iphone           snnunvr@   active; last seen 1m ago
```

👉 **Ubuntu IP**: `100.x.x.x` (kopyala!)

### 2.4 Firewall Ayarları (İsteğe bağlı)

```bash
# Ubuntu'da 1571 portunu lokal Tailscale ağında aç
sudo ufw allow from 100.0.0.0/8 to any port 1571
```

✅ Tailscale Ubuntu'da hazır

---

## 📱 Adım 3: iPhone'da Tailscale'i Kur

### 3.1 App Store'dan İndir

1. iPhone'u aç → **App Store**
2. Ara: `Tailscale`
3. **Tailscale by Tailscale, Inc.** (Resmi uygulama)
4. **Kur**'a tıkla

### 3.2 Tailscale'i Bağla

1. Tailscale uygulamasını aç
2. **Sign in with** → Apple ID
3. Aynı Apple Account'u kullan (Ubuntu'da kullandığın ile aynı)
4. **Allow** ve tüm izinleri ver

### 3.3 Bağlantıyı Doğrula

1. Tailscale App'te İP adresini kontrol et
2. İPhone IP: `100.y.y.y` (bu görülecek)
3. Ubuntu'daki `tailscale status` ile karşılaştır

✅ İPhone ve Ubuntu aynı Tailscale ağında

---

## 🔧 Adım 4: Flutter iOS Build'ini Hazırla

### 4.1 iOS Yapılandırması

```bash
cd /home/snnunvr/Desktop/system_ios_monitor

# Gerekli dosyaları kontrol et
flutter doctor -v
```

Kontrol ettiği şeyler:

- ✅ Flutter SDK
- ✅ iOS deployment target (>= 11.0)
- ✅ Xcode
- ✅ CocoaPods

### 4.2 iOS Bağımlılıklarını Güncelle

```bash
# iOS klasörüne git
cd ios

# CocoaPods güncellemesi
pod repo update
pod install

# Geri dön
cd ..
```

### 4.3 Xcode Projesini Aç

```bash
open ios/Runner.xcworkspace
```

**Önemli**: `.xcworkspace` dosyasını aç, `.xcodeproj` değil!

---

## 🔐 Adım 5: İOS Signing (Derleme Sertifikası)

### 5.1 Apple Developer Account

1. **Xcode** → **Preferences** → **Accounts**
2. Sağ alt **+** butonuna tıkla
3. Apple ID'ni gir
4. **Add** → Sertifikalar otomatik indirilecek

### 5.2 Xcode'da Signing Ayarla

1. **Xcode** → **Project Navigator** → **Runner** seç
2. **Targets** → **Runner**
3. **Signing & Capabilities** tab'inde:
   - **Team**: Hesabını seç
   - **Bundle Identifier**: `com.snnunvr.systemiOSMonitor`

### 5.3 iOS Derleme Ayarları

```bash
# Flutter iOS ayarlarını güncelle
flutter pub get

# iOS CocoaPods hazırla
cd ios && pod install && cd ..

# Build settings kontrol
flutter build ios --analyze-size
```

✅ Tüm ayarlar tamam

---

## 📲 Adım 6: iPhone'a Deploy Et

### 6.1 USB Bağlantı

iPhone'u USB kablosuyla Mac/Ubuntu'ya bağla

### 6.2 Flutter Run Komutu

```bash
cd /home/snnunvr/Desktop/system_ios_monitor

# iOS cihazlara ulaş
flutter devices

# Uygulamayı deploy et
flutter run -d iphone
```

Beklenen çıktı:

```
🔨 Building for iphone...
✓ Built...
Installing and launching...
...
D/Flutter (12345): First frame rendered in 2.5s
```

**Uygulama iPhone'da açılacak!**

### 6.3 Wireless Deployment (Kablolu Değilse)

```bash
# Mac/Ubuntu'yu network üzerinden cihaz olarak ekle
open -a 'Xcode' --args -xcode

# Veya doğrudan
python3 -m pip install pymobiledevice3
pymobiledevice3 remote start-tunnel
```

✅ Uygulama çalışıyor!

---

## ⚙️ Adım 7: İPhone'da Sunucu Ayarlarını Yapılandır

### 7.1 Uygulamayı Aç

iPhone'da uygulama ilk açılığında Dashboard göreceksin.

### 7.2 Ayarlar'a Git

1. Sağ alt köşede **⚙️** (Ayarlar) ikonuna tıkla

### 7.3 Sunucu IP'sini Gir

1. **Sunucu Ayarları** bölümü
2. **Sunucu URL** input'u
3. `http://100.x.x.x:1571` yazı
   - **100.x.x.x** yerine Ubuntu Tailscale IP'sini koy
   - (Adım 2.3'ten kopyladığın)

Örnek: `http://100.64.5.23:1571`

### 7.4 Test Bağlantı

1. **Test Bağlantı** butonuna tıkla
2. Beklenen sonuçlar:

| Durum | Sembol |
|-------|--------|
| Başarılı | ✅ Bağlı |
| Başarısız | ❌ Bağlanamadı |
| Yükleniyor | ⏳ Test ediliyor... |

### 7.5 Hata Giderme

❌ "Bağlanamadı" hatası alırsan:

**Kontrol listesi:**

1. Ubuntu'da `./start_backend.sh` çalışıyor mu?
   ```bash
   ps aux | grep "python3 main.py"
   ```

2. URL doğru mu?
   ```bash
   # Ubuntu'da kontrol et
   curl http://localhost:1571/api/health
   ```

3. Tailscale bağlı mı?
   - iPhone Tailscale uygulamasında "Connected" yazıyor mu?
   - `tailscale status` Ubuntu'da her iki cihazı gösteriyor mu?

4. Firewall sorun mudur?
   ```bash
   sudo ufw status
   sudo ufw allow from 100.0.0.0/8 to any port 1571
   ```

✅ Bağlantı sağlandı

---

## 📊 Adım 8: Uygulamayı Kullan

### 8.1 Dashboard

- 📊 CPU, RAM, Disk, GPU kullanımı
- 🔴 Sıcaklık göstergeleri
- 🔄 2 saniye yenileme

### 8.2 GPU Monitor

- 🎮 Her GPU için detaylı bilgi
- 💾 Bellek kullanımı
- 🌡️ Sıcaklık ve güç tüketimi
- 🔌 Aktif süreçler

### 8.3 Port Analizi

**Dinlemede**: Açık portlar
**Kurulu**: Bağlı portlar
**Dış**: Yabancı bağlantılar ⚠️

### 8.4 Training Tracker

- 🚀 Aktif training job'ları
- 📈 GPU bellek kullanımı
- ⏱️ Çalışma süresi
- 🛑 Durdur/Ara/Devam kontrolleri

### 8.5 Enerji Monitor

- ⚡ Saatlik maliyet
- 📅 Aylık maliyet (₺)
- 🔧 Elektrik fiyatını değiştir (₺/kWh)
- 📊 Komponente göre ayrıntı

---

## 🔄 Arka Planda Güncelleme

### 8.6 Otomatik Yenileme

Dashboard açıkken otomatik olarak güncellenir:

- GPU verileri: Her 2 saniye
- Port verileri: Her 3 saniye
- Enerji: Her 5 saniye

### 8.7 WebSocket Bağlantısı

Uygulama WebSocket üzerinden gerçek zamanlı veri akışı kullanır:

```
ws://100.x.x.x:1571/ws?interval=2
```

Kesilirse otomatik olarak yeniden bağlanır.

---

## 🛡️ Güvenlik İpuçları

### 9.1 Tailscale Ağı

✅ **Şifreli**: Tüm Tailscale trafiği TLS şifrelenmiş
✅ **Güvenli**: Sadece iki tarafın anahtarları vardır
✅ **Yalıtılmış**: Public internet'e açık değil

### 9.2 Port 1571

```bash
# Sadece Tailscale ağından erişime izin ver
sudo ufw allow from 100.0.0.0/8 to any port 1571

# Diğer kaynaklardan engelle
sudo ufw deny from any to any port 1571
```

### 9.3 Tailscale İzinleri

iPhone'da **Tailscale ayarları**:

- **Always-on**: Etkin (tüm trafiği koruyor)
- **Exit node**: Devre dışı (yerel ağ için)
- **Use Tailscale DNS**: Opsiyonel (domain blocking)

---

## 🐛 Sorun Giderme

### Problem 1: "Connection refused" (Bağlantı reddedildi)

```bash
# Ubuntu'da backend'i kontrol et
ps aux | grep python

# Başlatılmamışsa:
./start_backend.sh

# Log'ları gör:
tail -f backend.log
```

### Problem 2: "Unable to resolve host"

```bash
# URL biçimi yanlış mı?
# ✅ http://100.x.x.x:1571
# ❌ https://... (https değil)
# ❌ 192.168.x.x (Tailscale IP olmalı)

# Tailscale status'u kontrol et
tailscale status
```

### Problem 3: Veri Görmüyor

```bash
# Terminal'de backend'i kontrol et
curl http://100.x.x.x:1571/api/system

# JSON görmüyor musun?
# Tailscale bağlantısını kontrol et
tailscale ping 100.y.y.y
```

### Problem 4: Uygulama Çöküyor

```bash
# Debug modu ile çalıştır
flutter run -d iphone -v

# Logları gör
flutter logs
```

---

## 📚 Referanslar

- **API Dökümanı**: [API_REFERENCE.md](API_REFERENCE.md)
- **Hızlı Başlangıç**: [QUICKSTART.sh](QUICKSTART.sh)
- **Proje Özeti**: [PROJECT_SUMMARY.md](PROJECT_SUMMARY.md)

---

## ✅ Kontrol Listesi

Deploy öncesi kontrol et:

- [ ] Backend `./start_backend.sh` ile çalışıyor
- [ ] Ubuntu Tailscale çalışıyor (`sudo tailscale up`)
- [ ] iPhone Tailscale bağlı (App'te "Connected")
- [ ] Ubuntu IP not edildi (`tailscale status`)
- [ ] Flutter iOS dependencies kurulu (`flutter pub get`)
- [ ] Xcode imzalama ayarlanmış (Apple Developer Account)
- [ ] iPhone uygulamada URL girildi (`http://100.x.x.x:1571`)
- [ ] Test bağlantı başarılı (✅)
- [ ] Dashboard veri gösteriyor

✅ **Hepsi tamamlandı? Başarılı deploy!**

---

## 🎉 Sonuç

Tebrikler! Artık iPhone'da Ubuntu sistem monitoringini yapabilirsin:

- 📱 Herhangi bir yerde (Tailscale ağı içinde)
- 🔐 Güvenli bağlantı
- ⚡ Gerçek zamanlı veriler
- 🎨 Modern UI/UX

---

**Oluşturma Tarihi**: 2024-01-15
**Güncelleme**: 2024-01-15
**iOS Minimum**: iOS 11.0+
**Flutter Versiyonu**: 3.0+

---

### 📞 İhtiyacın Varsa

- Kod: `/home/snnunvr/Desktop/system_ios_monitor/`
- Backend Log: Terminal'de `./start_backend.sh` çıktısı
- Flutter Log: `flutter logs`
- API Docs: `http://localhost:1571/docs`

# 📊 System iOS Monitor

Kişisel kullanım için oluşturulmuş profesyonel bir Sistem İzleme Uygulaması. Ubuntu server'ında çalışan backend'i iPhone'dan Tailscale aracılığıyla izleyin.

## ✨ Özellikler

### 🖥️ Sistem Monitoring
- **CPU Kullanımı** - Gerçek zamanlı CPU yüzdesi, frekans, sıcaklık
- **Bellek (RAM)** - Toplam, kullanılan, yüzde bilgisi
- **Disk Alanı** - Disk kullanımı ve yüzde
- **Sistem Bilgileri** - Core sayısı, işlemci sıcaklığı

### 🎮 GPU Monitoring (NVIDIA)
- **GPU Kullanımı** - Gerçek zamanlı kullanım yüzdesi
- **Bellek Yönetimi** - VRAM toplam, kullanılan, yüzde
- **Güç Tüketimi** - Watt cinsinden güç çekişi
- **Sıcaklık İzleme** - GPU sıcaklığı takibi
- **Compute Processes** - GPU üzerinde çalışan process'ler

### ⚡ Enerji Maliyeti Hesaplaması
- **Saatlik Maliyet** - Canlı saatlik maliyet
- **Günlük Maliyet** - Günlük tahmin edilen maliyet
- **Aylık Maliyet** - Aylık maliyet projeksiyonu
- **Bileşen Analizi** - GPU, CPU, RAM'in ayrı ayrı maliyeti
- **Ayarlanabilir Fiyat** - Türkiye elektrik fiyatını güncelleyebilirsiniz (~15₺/kWh)

### 🔌 Port Analizi (Güvenlik)
- **Dinlemede Olan Portlar** - Hangi portlar dinlemede
- **Kurulu Bağlantılar** - Active connections
- **Dış Bağlantılar** - ⚠️ Yabancı IP'lerden gelen bağlantılar (güvenlik uyarısı)
- **Process Bilgisi** - Her port için process adı ve PID
- **Servis Adları** - Standart port isimlerinin otomatik çevrilmesi

### 🚀 Training Job Tracker
- **Aktif Training İşleri** - Çalışan Python/PyTorch/TensorFlow process'lerinin tespiti
- **Resource Monitoring** - CPU, Bellek, GPU kullanımı
- **I/O Izleme** - Disk okuma/yazma hızı
- **Job Kontrolü** - İşleri durdurabilme
- **Detaylı Bilgiler** - Thread sayısı, komut satırı, başlangıç zamanı

## 🚀 Başlangıç

### Backend Kurulumu

```bash
# Backend dizinine git
cd backend

# Sanal ortam oluştur
python3 -m venv venv
source venv/bin/activate

# Bağımlılıkları yükle
pip install -r requirements.txt

# Sunucuyu başlat (1571 portunda)
python3 main.py
```

### Frontend Kurulumu

```bash
# Flutter paketlerini yükle
flutter pub get

# Uygulamayı çalıştır
flutter run
```

## 📱 iPhone'da Kullanım

1. Tailscale'i both cihazlarda yükle ve aynı ağa bağlan
2. Ubuntu'nun Tailscale IP'sini öğren: `tailscale status`
3. Flutter uygulamasının ayarlarında: `http://100.x.x.x:1571` kullan

## 📝 API Endpoints

- `GET /api/system` - Tüm sistem bilgisi
- `GET /api/system/gpu` - GPU bilgisi
- `GET /api/energy` - Enerji maliyeti
- `GET /api/ports` - Port analizi
- `GET /api/training` - Training jobs

---

**Created with ❤️ for System Monitoring**

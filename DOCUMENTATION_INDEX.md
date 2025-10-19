# 📚 Dokümantasyon İndeksi

## 🎯 Başla Burada

| Belge | Amaç | Okuma Süresi |
|-------|------|-------------|
| **[MASTER_GUIDE.md](MASTER_GUIDE.md)** | Projeye genel bakış + linkler | 3 dakika |
| **[QUICKSTART.sh](QUICKSTART.sh)** | Adım-adım kurulum talimatları | 5 dakika |

---

## 📱 iPhone Kurulumu

| Belge | Amaç | Okuma Süresi |
|-------|------|-------------|
| **[iOS_DEPLOYMENT.md](iOS_DEPLOYMENT.md)** | Tailscale + Flutter deployment | 15 dakika |
| **[TROUBLESHOOTING.md](TROUBLESHOOTING.md)** | Sorun giderme rehberi | Ref. |

---

## 🔧 Teknik Referanslar

| Belge | Amaç | Okuma Süresi |
|-------|------|-------------|
| **[API_REFERENCE.md](API_REFERENCE.md)** | REST API endpoint detayları | 5 dakika |
| **[PROJECT_SUMMARY.md](PROJECT_SUMMARY.md)** | Yapı, dosyalar, moduller | 10 dakika |
| **[README.md](README.md)** | Başlangıç kılavuzu | 3 dakika |

---

## 📊 Hızlı Başlangıç (5 Dakika)

### 1. Backend Başlat
```bash
./start_backend.sh
```

### 2. Tailscale Etkinleştir
```bash
sudo tailscale up
tailscale status  # Ubuntu IP'sini kopyala (100.x.x.x)
```

### 3. iPhone'da Yapılandır
- Tailscale App → Connect
- Flutter App → Settings (⚙️)
- URL: `http://100.x.x.x:1571`
- Test Bağlantı → ✅

---

## 🗂️ Dosya Yapısı

```
Documentation/
├── MASTER_GUIDE.md          ← Buradan başla!
├── QUICKSTART.sh            ← Setup talimatları
├── iOS_DEPLOYMENT.md        ← iPhone deployment
├── API_REFERENCE.md         ← API endpoints
├── TROUBLESHOOTING.md       ← Sorun giderme
├── PROJECT_SUMMARY.md       ← Teknik detaylar
├── README.md                ← Başlangıç
└── DOCUMENTATION_INDEX.md   ← Bu dosya
```

---

## 🎓 Konu Bazında Kılavuzlar

### Backend Kurulumu
- **README.md**: Python ortamı kurulumu
- **QUICKSTART.sh**: Adım 1
- **PROJECT_SUMMARY.md**: Backend mimarisi

### Tailscale Ağı
- **iOS_DEPLOYMENT.md**: Adım 2-3
- **TROUBLESHOOTING.md**: Network sorunları
- **API_REFERENCE.md**: Port bilgisi (1571)

### Flutter iOS
- **iOS_DEPLOYMENT.md**: Adım 4-8
- **QUICKSTART.sh**: Adım 3
- **TROUBLESHOOTING.md**: Flutter hataları

### API Kullanımı
- **API_REFERENCE.md**: Tüm endpoints
- **QUICKSTART.sh**: Test komutları
- **PROJECT_SUMMARY.md**: Backend modülleri

### Sorun Giderme
- **TROUBLESHOOTING.md**: Yaygın hatalar
- **iOS_DEPLOYMENT.md**: Deployment issues
- **PROJECT_SUMMARY.md**: Sistem gereksinimleri

---

## 🚀 Kullanım Senaryoları

### Senaryo 1: İlk Kurulum
```
MASTER_GUIDE.md (genel bakış)
  ↓
QUICKSTART.sh (adım-adım)
  ↓
iOS_DEPLOYMENT.md (iPhone)
  ↓
TROUBLESHOOTING.md (sorunlar)
```

### Senaryo 2: API Entegrasyonu
```
API_REFERENCE.md (endpoints)
  ↓
PROJECT_SUMMARY.md (backend)
  ↓
TROUBLESHOOTING.md (debug)
```

### Senaryo 3: Sorun Çözme
```
TROUBLESHOOTING.md (kategori ara)
  ↓
Adım-adım çözüm takip et
  ↓
Sonuç: ✅ Çalıştı!
```

---

## 📋 Kontrol Listeleri

### Deployment Kontrol Listesi
- [ ] MASTER_GUIDE.md oku
- [ ] QUICKSTART.sh adımlarını takip et
- [ ] iOS_DEPLOYMENT.md bitir
- [ ] TROUBLESHOOTING.md'yi bookmark et
- [ ] ✅ Hazır!

### Sorun Giderme Kontrol Listesi
- [ ] TROUBLESHOOTING.md'de kategori ara
- [ ] Adımları takip et
- [ ] Hala sorun varsa DEBUG prosedürü çalıştır
- [ ] Logları topla ve kaydet
- [ ] Destek iletişim bilgisine bakın

---

## 🔍 Hızlı Arama

### "X Nasıl Yapılır?"

| Soru | Cevap |
|------|-------|
| Backend nasıl başlatılır? | QUICKSTART.sh Adım 1 |
| Tailscale nasıl kurulur? | iOS_DEPLOYMENT.md Adım 2 |
| iPhone'a nasıl deploy edilir? | iOS_DEPLOYMENT.md Adım 6 |
| GPU verisi neden görmüyor? | TROUBLESHOOTING.md → GPU |
| Bağlantı hatası alıyorum | TROUBLESHOOTING.md → Bağlantı |
| API endpoint nedir? | API_REFERENCE.md |
| Proje yapısı nasıl? | PROJECT_SUMMARY.md |

---

## 🛠️ Komut Referansı

```bash
# Backend
./start_backend.sh              # Başlat
curl http://localhost:1571/api/health  # Test
ps aux | grep python3           # PID kontrol

# Tailscale
sudo tailscale up              # Etkinleştir
tailscale status               # Status
tailscale ping <IP>            # Ping test

# Flutter
flutter devices                 # Cihaz listesi
flutter run -d iphone          # Deploy
flutter logs                   # Loglar

# Sorun Giderme
lsof -i :1571                  # Port kontrol
nvidia-smi                     # GPU kontrol
sudo ufw status                # Firewall
```

---

## 🆘 Acil Durum

### Hızlı Restart (5 Dakika)

```bash
# 1. Backend durdu
pkill -f "python3 main.py"
./start_backend.sh

# 2. Tailscale kesildi
sudo tailscale up

# 3. App bağlanmıyor
# iPhone Settings → URL kontrol → Test Bağlantı
```

### Tüm Sistem Restart

```bash
# Ubuntu
sudo reboot

# iPhone
Restart

# Tailscale bağla
sudo tailscale up
# iPhone Tailscale App açıp Connect
```

---

## 📞 Destek Kaynakları

| Kaynak | Link |
|--------|------|
| Flutter Docs | https://flutter.dev/docs |
| FastAPI Docs | https://fastapi.tiangolo.com/ |
| Tailscale KB | https://tailscale.com/kb/ |
| API Docs (Local) | http://localhost:1571/docs |

---

## ✅ Başarı İşaretleri

- ✅ Backend çalışıyor (PID gösterilir)
- ✅ Tailscale bağlı (status her iki tarafı gösterir)
- ✅ iPhone uygulamayı açabiliyor
- ✅ Settings'de URL girilebiliyor
- ✅ Test Bağlantı yeşil ✅
- ✅ Dashboard veri gösteriyor
- ✅ Tüm ekranlar yüklenebiliyor

---

## 📅 Güncelleme Geçmişi

| Tarih | Değişiklik |
|-------|-----------|
| 2024-01-15 | İlk versiyon |

---

## 🎯 İçerik Haritası

```
START HERE
    ↓
MASTER_GUIDE.md (Proje Özeti)
    ↓
    ├─→ Başlamak mı? → QUICKSTART.sh
    │
    ├─→ iPhone Kurulumu mu? → iOS_DEPLOYMENT.md
    │
    ├─→ API Entegrasyonu mu? → API_REFERENCE.md
    │
    ├─→ Sorun mu? → TROUBLESHOOTING.md
    │
    └─→ Derinlemesine Teknik mi? → PROJECT_SUMMARY.md
```

---

**Dokümantasyon Dizini**: 2024-01-15
**Toplam Sayfa**: 100+ sayfa
**Uyumluluk**: iOS 11.0+, Python 3.12+, Flutter 3.0+

📖 **Okumaya Başla: [MASTER_GUIDE.md](MASTER_GUIDE.md)**

---

*Son güncelleme: 2024-01-15*

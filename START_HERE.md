# 🚀 START HERE - System iOS Monitor

## 📱 Hoşgeldin!

**System iOS Monitor** uygulamasına hoş geldin. Bu sayfa seni başlamaya hazırlayacak.

---

## ⚡ 5 Dakikalık Hızlı Start

### Adım 1: Backend'i Başlat (Linux Terminal)
```bash
cd /home/snnunvr/Desktop/system_ios_monitor
./start_backend.sh
```

✅ Gördüğün: `Uvicorn running on http://0.0.0.0:1571`

---

### Adım 2: Tailscale'i Etkinleştir (Yeni Terminal)
```bash
sudo tailscale up
```

Tarayıcıda link açıp authenticate et.

Sonra:
```bash
tailscale status
```

✅ Bul: `100.x.x.x` başlayan Ubuntu IP'sini kopyala

---

### Adım 3: iPhone'a Uygulamayı Yükle

macOS'ta:
```bash
flutter run -d iphone
```

---

### Adım 4: Ayarları Yapılandır

1. App açıl
2. Sağ altta ⚙️ (Ayarlar)
3. URL gir: `http://100.x.x.x:1571` (100.x.x.x yerine senin IP'ni koy)
4. "Test Bağlantı"ye tıkla
5. ✅ Yeşil olursa bitti!

---

## 📚 Belgelere Göz At

| Belge | İçin | Zaman |
|-------|------|-------|
| [MASTER_GUIDE.md](MASTER_GUIDE.md) | Genel bakış | 3 min |
| [QUICKSTART.sh](QUICKSTART.sh) | Adım-adım kurulum | 5 min |
| [iOS_DEPLOYMENT.md](iOS_DEPLOYMENT.md) | iPhone setup | 15 min |
| [TROUBLESHOOTING.md](TROUBLESHOOTING.md) | Sorun çözme | İhtiyaca göre |
| [API_REFERENCE.md](API_REFERENCE.md) | API endpoints | Ref. |
| [DOCUMENTATION_INDEX.md](DOCUMENTATION_INDEX.md) | Tüm dokümanlar | Ref. |

---

## 🎯 Ne Yapabileceğini Gördü?

✅ **Dashboard**: CPU, RAM, Disk, GPU kullanımı
✅ **GPU Monitor**: Detaylı GPU bilgileri  
✅ **Port Analizi**: Açık portlar ve yabancı bağlantılar
✅ **Training Tracker**: ML model eğitimini izle
✅ **Enerji Monitor**: Aylık elektrik maliyeti hesapla (₺342/ay)
✅ **Ayarlar**: Tailscale ve URL yapılandırma

---

## 🆘 Sorun mu?

Şu sorulara cevap ara:

- Backend başlamıyor? → [TROUBLESHOOTING.md](TROUBLESHOOTING.md#backend-başlamıyor)
- Tailscale sorun? → [TROUBLESHOOTING.md](TROUBLESHOOTING.md#tailscale-sorunları)
- Bağlantı hatası? → [TROUBLESHOOTING.md](TROUBLESHOOTING.md#flexapi-bağlantı-hatası)
- GPU görmüyor? → [TROUBLESHOOTING.md](TROUBLESHOOTING.md#gpu-verisi-görmüyor)

---

## 📞 Hızlı Komutlar

```bash
# Backend kontrolü
ps aux | grep python3

# Tailscale IP
tailscale status

# API test
curl http://localhost:1571/api/health

# iPhone logları
flutter logs
```

---

## ✅ Başarı Kriteri

Hepsi ✅ ise başarılı:

- [ ] Backend çalışıyor (PID gösterilir)
- [ ] Tailscale bağlı (status her iki cihazı gösterir)
- [ ] iPhone uygulamayı açabiliyor
- [ ] Settings'de URL girilebiliyor
- [ ] "Test Bağlantı" yeşil ✅
- [ ] Dashboard veri gösteriyor

---

## 🎓 Sonraki Adımlar

1. **[MASTER_GUIDE.md](MASTER_GUIDE.md) oku** - Projeyi anla
2. **[iOS_DEPLOYMENT.md](iOS_DEPLOYMENT.md) takip et** - Detaylı iPhone setup
3. **[API_REFERENCE.md](API_REFERENCE.md) böyle** - API endpoint'ler
4. **[TROUBLESHOOTING.md](TROUBLESHOOTING.md) bookmark et** - Sorunlar için

---

## 🔗 Faydalı Linkler

- **Local API Docs**: http://localhost:1571/docs
- **Flutter Docs**: https://flutter.dev/docs
- **FastAPI Docs**: https://fastapi.tiangolo.com/
- **Tailscale**: https://tailscale.com/

---

## 💡 Pro Tips

1. **WebSocket**: App otomatik gerçek zamanlı veri alır
2. **Tailscale**: İnternet'e açık olmadan güvenli erişim
3. **GPU**: 2x NVIDIA GPU desteklenir (GTX 1660 Ti, RTX 2060)
4. **Port 1571**: Custom port (standar portlarla çakışma yok)

---

## 🎉 Tebrikler!

Başlamaya hazırsın. İlk adımını at:

```bash
./start_backend.sh
```

---

**Ready?** → Açılı [MASTER_GUIDE.md](MASTER_GUIDE.md)

---

*Last updated: 2024-01-15*
*Version: 1.0*

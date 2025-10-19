#!/bin/bash

# 🍎 MACBOOK'TA ÇALIŞTIRILACAK COMMANDS
# Kopyala + Macbook terminali'ne yapıştır

cat << 'EOF'

╔════════════════════════════════════════════════════════════════════════════╗
║                                                                            ║
║              🍎 macOS/Macbook - System iOS Monitor Deploy                  ║
║                    iPhone'a HEMEN Yükle & Çalıştır                        ║
║                                                                            ║
╚════════════════════════════════════════════════════════════════════════════╝


📋 ADIM-ADIM KURULUM
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

ADIM 1: FLU TTER GÜNCELLE (İlk kez yapıyorsan)
─────────────────────────────────────────────────

$ brew install flutter

VEYA flutter varsa:

$ flutter upgrade


ADIM 2: PROJE KLASÖRÜNE GİT
─────────────────────────────────────────────────

$ cd /home/snnunvr/Desktop/system_ios_monitor


ADIM 3: BAĞIMLILIKLARI YÜKLEYİN (PUB GET)
─────────────────────────────────────────────────

$ flutter pub get

✅ Çıktı: "packages get complete!"


ADIM 4: iOS POD'LARINI YÜKLEYİN
─────────────────────────────────────────────────

$ cd ios
$ pod repo update
$ pod install
$ cd ..

✅ Çıktı: "Pod installation complete!"


ADIM 5: iPhone BAĞLANMIŞ MI KONTROL ET
─────────────────────────────────────────────────

iPhone'u USB kablosuyla Macbook'a bağla

iPhone'da çıkan "Trust" butonuna tap et

Terminal'de kontrol et:

$ flutter devices

✅ Çıktı örneği:
   iPhone (mobile) • ios • iOS 17.5 • connected


ADIM 6: BUILD & HEMEN DEPLOY! 🚀
─────────────────────────────────────────────────

$ flutter run -d ios

⏱️  Bekleme: 2-5 dakika (İlk defs biraz uzun olur)

✅ Uygulama iPhone'da açılacak!


ADIM 7: UYGULAMADA URL YAPILANDIR
─────────────────────────────────────────────────

iPhone'da App açılırsa:

1️⃣  Sağ alt köşeyi ara → ⚙️ (Settings) icon
2️⃣  "Server Settings" / "Sunucu Ayarları" bölümü
3️⃣  "Server URL" kısmına yazı:

    http://100.x.x.x:1571

    (100.x.x.x yerine ubuntu'nun Tailscale IP'sini koy)
    
    Örnek: http://100.64.5.23:1571

4️⃣  "Test Connection" / "Bağlantı Test Et" butonuna tap
5️⃣  🟢 Yeşil mesaj gelirse = BAŞARILI!


ADIM 8: MONİTORİNG BAŞLA! 📊
─────────────────────────────────────────────────

App'te:

📊 Dashboard
   → CPU, RAM, Disk, GPU kullanımı

🎮 GPU Monitor
   → GPU detayları, sıcaklık, güç

🔌 Ports
   → Açık portlar, yabancı bağlantılar

🚀 Training
   → ML model eğitim job'ları

⚡ Energy
   → Aylık elektrik maliyeti (₺)

⚙️ Settings
   → URL, test, ayarlar


════════════════════════════════════════════════════════════════════════════

❌ SORUN? HEMEN ÇÖZELIM
════════════════════════════════════════════════════════════════════════════

SORUN 1: "flutter devices" iPhone görmüyor
──────────────────────────────────────────────

✅ Çözüm:

1. iPhone'u çıkar ve yeniden tak
2. iPhone'da Trust butonuna tap
3. Macbook'ta Xcode'u aç:
   $ open /Applications/Xcode.app
4. Xcode → Window → Devices and Simulators
5. iPhone görünüyor mu?

Görmüyorsa:
$ sudo killall -9 usbmuxd


SORUN 2: "pod install" başarısız
──────────────────────────────────────────────

$ cd ios
$ rm -rf Pods Podfile.lock .symlinks/ Flutter/Flutter.framework
$ pod repo update
$ pod install
$ cd ..


SORUN 3: "flutter run -d ios" başarısız
──────────────────────────────────────────────

Tam temizleme yapı:

$ flutter clean
$ rm -rf build/
$ cd ios
$ rm -rf Pods Podfile.lock .symlinks/ Flutter/Flutter.framework
$ pod install
$ cd ..
$ flutter pub get
$ flutter run -d ios


SORUN 4: "Xcode build cache" sorunu
──────────────────────────────────────────────

$ rm -rf ~/Library/Developer/Xcode/DerivedData/*
$ flutter clean
$ flutter run -d ios


SORUN 5: iPhone'da "App not installed"
──────────────────────────────────────────────

1. iPhone'da Settings → General → iPhone Storage
2. System iOS Monitor uygulamasını bul ve sil
3. Macbook'ta terminal'de tekrar çalıştır:
   $ flutter run -d ios


SORUN 6: "Signing certificate" hatası
──────────────────────────────────────────────

$ open ios/Runner.xcworkspace

Xcode'da:
1. Proje seç (left sidebar)
2. "Runner" target seç
3. "Signing & Capabilities" tab
4. Team seç (Apple ID)
5. Bundle ID kontrol et

Macbook terminal'de:
$ flutter run -d ios


SORUN 7: "Network request failed" (Sunucuya bağlanamıyor)
──────────────────────────────────────────────────────────────────────

1. Ubuntu'da Backend çalışıyor mu?
   $ ps aux | grep python3

2. Backend çalışmıyorsa:
   $ ./start_backend.sh

3. Tailscale bağlı mı?
   $ tailscale status

4. iPhone'da URL doğru mu?
   → Settings → Server URL kontrol

5. Tailscale IP'si:
   Ubuntu terminal'de: $ tailscale status


════════════════════════════════════════════════════════════════════════════

⚡ HIZLI KOMUTLAR
════════════════════════════════════════════════════════════════════════════

# Cihazları listele
flutter devices

# Verbose mod'da deploy (daha fazla log)
flutter run -d ios -v

# Spesifik simulator veya cihazda
flutter run -d "cihaz_id"

# Release build (prod için)
flutter run -d ios --release

# iOS Simulator'de test (Xcode varsa)
flutter run

# Log'ları izle
flutter logs

# Cleaning & rebuilding
flutter clean && flutter pub get && cd ios && pod install && cd ..


════════════════════════════════════════════════════════════════════════════

✨ PRO TIPS
════════════════════════════════════════════════════════════════════════════

1. HIZLI İTERASİON
   $ flutter run -d ios
   → Kod değiş, R tap et (hot reload)
   
2. FULL REBUILD
   $ flutter run -d ios -v

3. LOG İZLEME
   Terminal 1: $ flutter run -d ios
   Terminal 2: $ flutter logs

4. DEVICE İD KAYDEDIA
   $ flutter devices | grep ios
   → ID'yi kaydet, kısayol için

5. PROD BUILD
   $ flutter build ios --release


════════════════════════════════════════════════════════════════════════════

📚 REFERANSLAR
════════════════════════════════════════════════════════════════════════════

• Flutter iOS Setup: https://flutter.dev/docs/get-started/install/macos
• iOS Deployment: https://flutter.dev/docs/deployment/ios
• Xcode Docs: https://developer.apple.com/xcode/
• CocoaPods: https://cocoapods.org/


════════════════════════════════════════════════════════════════════════════

✅ BAŞARILI BİLDİĞİN ZAMAN
════════════════════════════════════════════════════════════════════════════

✅ Terminal'de "Launching lib/main.dart on" mesajı
✅ iPhone'da App açılıyor
✅ Dashboard ekranı görünüyor
✅ Settings'e gidebiliyorsun
✅ Server URL girebiliyorsun
✅ "Test Connection" yeşil ✅ gösteriyor
✅ Dashboard'da GPU/CPU verileri görünüyor

✨ Tebrikler! Deployment başarılı! 🎉


════════════════════════════════════════════════════════════════════════════

🚀 HEMEN BAŞLA!

Kopyala ve Macbook Terminal'ine yapıştır:

---

cd /home/snnunvr/Desktop/system_ios_monitor && \
flutter pub get && \
cd ios && \
pod install && \
cd .. && \
flutter run -d ios

---

Veya script'i çalıştır:

$ chmod +x iOS_QUICK_DEPLOY.sh
$ ./iOS_QUICK_DEPLOY.sh


════════════════════════════════════════════════════════════════════════════

⏱️  BEKLENEN SÜRELER

| Aktivite | Süre |
|-----------|------|
| flutter pub get | 30-60s |
| pod install | 2-3 min |
| flutter run -d ios (ilk) | 3-5 min |
| flutter run -d ios (sonra) | 30-60s |
| hot reload | 2-3s |


════════════════════════════════════════════════════════════════════════════

🎉 HEP HAZIR! BAŞLA!

Macbook Terminal'i aç ve yapıştır:

cd /home/snnunvr/Desktop/system_ios_monitor && flutter run -d ios

════════════════════════════════════════════════════════════════════════════

EOF

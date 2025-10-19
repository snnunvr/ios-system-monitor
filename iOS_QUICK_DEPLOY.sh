#!/bin/bash

# 🍎 macOS'ta iPhone'a Hemen Deploy Et!
# Bu script Macbook'ta çalıştırılmalıdır

echo "╔════════════════════════════════════════════════════════════╗"
echo "║        🍎 macOS - System iOS Monitor Deploy                ║"
echo "║              iPhone'a HEMEN AKTAR                          ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

# İnternet bağlantısı kontrol et
echo "1️⃣  İnternet Bağlantısı Kontrol"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if ping -c 1 google.com &>/dev/null; then
    echo "✅ İnternet OK"
else
    echo "❌ İnternet yok! WiFi'ye bağlan"
    exit 1
fi
echo ""

# Flutter kontrol
echo "2️⃣  Flutter Kontrol"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if ! command -v flutter &>/dev/null; then
    echo "❌ Flutter kurulu değil!"
    echo "Kur: brew install flutter"
    exit 1
fi
echo "✅ Flutter kurulu: $(flutter --version | head -1)"
echo ""

# Xcode kontrol
echo "3️⃣  Xcode Kontrol"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if ! command -v xcode-select &>/dev/null; then
    echo "❌ Xcode kurulu değil!"
    exit 1
fi
echo "✅ Xcode kurulu"
echo ""

# iPhone kontrol
echo "4️⃣  iPhone Bağlantısı Kontrol"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
flutter devices
echo ""
read -p "iPhone listede görünüyor mu? (y/n) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ iPhone bağlı değil!"
    echo "Yapılacaklar:"
    echo "  1. iPhone'u USB ile Macbook'a bağla"
    echo "  2. iPhone'da 'Trust' butonuna tıkla"
    echo "  3. Tekrar dene"
    exit 1
fi
echo "✅ iPhone bağlı!"
echo ""

# Proje klasöründe misin?
echo "5️⃣  Proje Klasörü"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ ! -f "pubspec.yaml" ]; then
    echo "❌ pubspec.yaml bulunamadı!"
    echo "$ cd /home/snnunvr/Desktop/system_ios_monitor"
    exit 1
fi
echo "✅ Doğru klasörde"
echo ""

# Dependencies yükle
echo "6️⃣  Dependencies Yükle"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "$ flutter pub get"
flutter pub get
if [ $? -ne 0 ]; then
    echo "❌ pub get başarısız!"
    exit 1
fi
echo "✅ Dependencies yüklendi"
echo ""

# iOS Pods yükle
echo "7️⃣  iOS Pods Yükle"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "$ cd ios && pod install && cd .."
cd ios
pod install
if [ $? -ne 0 ]; then
    echo "❌ pod install başarısız!"
    cd ..
    exit 1
fi
cd ..
echo "✅ Pods yüklendi"
echo ""

# Build et ve deploy
echo "8️⃣  BUILD & DEPLOY 🚀"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "App şimdi derlenip iPhone'a yüklenecek..."
echo "Bu 2-5 dakika alabilir..."
echo ""
echo "$ flutter run -d ios"
flutter run -d ios

if [ $? -eq 0 ]; then
    echo ""
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║               ✅ BAŞARILI!                                ║"
    echo "║         App iPhone'da açılıyor...                        ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo ""
    echo "Şimdi App'te:"
    echo "  1. Sağ alt ⚙️ (Settings) tap et"
    echo "  2. Server URL gir: http://100.x.x.x:1571"
    echo "  3. 'Test Connection' tap et"
    echo "  4. ✅ Yeşil görünürse başarılı!"
    echo ""
else
    echo ""
    echo "❌ Derleme başarısız!"
    echo ""
    echo "Sorun giderme:"
    echo "  1. flutter clean"
    echo "  2. flutter pub get"
    echo "  3. cd ios && rm -rf Pods Podfile.lock"
    echo "  4. pod install && cd .."
    echo "  5. flutter run -d ios"
    echo ""
    exit 1
fi

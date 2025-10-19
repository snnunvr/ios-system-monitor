#!/bin/bash

# ═══════════════════════════════════════════════════════════════════════
#
#   📱 iOS DEPLOY SCRIPT - MACBOOK'TA ÇALIŞTIR
#
#   Kullanım: ./DEPLOY_IOS.sh
#
# ═══════════════════════════════════════════════════════════════════════

echo ""
echo "╔═══════════════════════════════════════════════════════════════════╗"
echo "║                                                                   ║"
echo "║         🍎 iOS SYSTEM MONITOR - DEPLOY BAŞLATILIYOR              ║"
echo "║                                                                   ║"
echo "╚═══════════════════════════════════════════════════════════════════╝"
echo ""

# Renkler
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Başarı/Hata fonksiyonları
success() {
    echo -e "${GREEN}✅ $1${NC}"
}

error() {
    echo -e "${RED}❌ $1${NC}"
}

info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# Proje dizini kontrolü
if [ ! -f "pubspec.yaml" ]; then
    error "Bu bir Flutter projesi değil!"
    echo ""
    info "Önce repo'yu clone et:"
    echo "  cd ~/Desktop"
    echo "  git clone https://github.com/snnunvr/ios-system-monitor.git"
    echo "  cd ios-system-monitor"
    echo "  ./DEPLOY_IOS.sh"
    exit 1
fi

success "Flutter projesi bulundu"
echo ""

# ═══════════════════════════════════════════════════════════════════════
echo "📋 1/5 - Flutter Kontrolü"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if ! command -v flutter &> /dev/null; then
    error "Flutter bulunamadı!"
    echo ""
    info "Flutter'ı yükle:"
    echo "  https://docs.flutter.dev/get-started/install/macos"
    exit 1
fi

FLUTTER_VERSION=$(flutter --version | head -n 1)
success "Flutter bulundu: $FLUTTER_VERSION"
echo ""

# ═══════════════════════════════════════════════════════════════════════
echo "📦 2/5 - Dependencies Yükleniyor"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

info "flutter pub get çalıştırılıyor..."
flutter pub get
if [ $? -eq 0 ]; then
    success "Flutter dependencies yüklendi"
else
    error "flutter pub get başarısız!"
    exit 1
fi
echo ""

# ═══════════════════════════════════════════════════════════════════════
echo "🍎 3/5 - iOS Pods Yükleniyor"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if ! command -v pod &> /dev/null; then
    warning "CocoaPods bulunamadı, yükleniyor..."
    sudo gem install cocoapods
fi

cd ios
info "pod install çalıştırılıyor..."
pod install --repo-update
if [ $? -eq 0 ]; then
    success "iOS CocoaPods yüklendi"
else
    warning "Pod install hatası (devam ediliyor...)"
fi
cd ..
echo ""

# ═══════════════════════════════════════════════════════════════════════
echo "📱 4/5 - iPhone Kontrolü"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

info "Bağlı cihazlar kontrol ediliyor..."
flutter devices > /tmp/flutter_devices.txt
cat /tmp/flutter_devices.txt
echo ""

if grep -q "iPhone" /tmp/flutter_devices.txt || grep -q "iOS" /tmp/flutter_devices.txt; then
    success "iPhone bulundu!"
else
    error "iPhone bulunamadı!"
    echo ""
    warning "Kontrol listesi:"
    echo "  • iPhone USB'ye bağlı mı?"
    echo "  • iPhone'da 'Bu Bilgisayara Güven' tıklandı mı?"
    echo "  • iPhone kilidi açık mı?"
    echo "  • Xcode'da geliştirici hesabı tanımlı mı?"
    echo ""
    read -p "Hazır olduğunda Enter'a bas (Çıkmak için Ctrl+C)... "
fi
echo ""

# ═══════════════════════════════════════════════════════════════════════
echo "🚀 5/5 - iOS Build & Deploy Başlatılıyor"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

warning "İlk build 5-10 dakika sürebilir, lütfen bekleyin..."
echo ""
info "flutter run -d ios çalıştırılıyor..."
echo ""
echo "════════════════════════════════════════════════════════════════════"
echo ""

# Flutter run
flutter run -d ios --release

# Sonuç
EXIT_CODE=$?
echo ""
echo "════════════════════════════════════════════════════════════════════"
echo ""

if [ $EXIT_CODE -eq 0 ]; then
    echo ""
    echo "╔═══════════════════════════════════════════════════════════════════╗"
    echo "║                                                                   ║"
    echo "║              ✅ DEPLOYMENT BAŞARILI!                             ║"
    echo "║                                                                   ║"
    echo "╚═══════════════════════════════════════════════════════════════════╝"
    echo ""
    success "App iPhone'da başlatıldı!"
    echo ""
    echo "📝 Şimdi iPhone'da yapılacaklar:"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "  1. Sağ altta ⚙️ (Settings) ikonuna tap et"
    echo "  2. 'Server URL' kısmına yaz:"
    echo "     ${YELLOW}http://100.79.166.110:1571${NC}"
    echo "  3. 'Test Connection' butonuna tap et"
    echo "  4. ${GREEN}✅ Yeşil${NC} çıkarsa tamamdır!"
    echo ""
    echo "🎉 Artık Ubuntu sistemini iPhone'dan izleyebilirsin!"
    echo ""
else
    echo ""
    echo "╔═══════════════════════════════════════════════════════════════════╗"
    echo "║                                                                   ║"
    echo "║              ❌ DEPLOYMENT HATASI                                ║"
    echo "║                                                                   ║"
    echo "╚═══════════════════════════════════════════════════════════════════╝"
    echo ""
    error "Build başarısız oldu"
    echo ""
    warning "Yaygın çözümler:"
    echo ""
    echo "  1. Xcode Cache Temizle:"
    echo "     rm -rf ~/Library/Developer/Xcode/DerivedData/*"
    echo ""
    echo "  2. Flutter Temizle:"
    echo "     flutter clean"
    echo "     rm -rf ios/Pods ios/Podfile.lock"
    echo ""
    echo "  3. Tekrar Dene:"
    echo "     ./DEPLOY_IOS.sh"
    echo ""
    echo "  4. Detaylı Log İçin:"
    echo "     flutter run -d ios -v"
    echo ""
fi

echo ""

#!/bin/bash

# System Monitor Backend - Systemd Service Installer

echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║                                                               ║"
echo "║    System iOS Monitor - Backend Systemd Service Setup        ║"
echo "║                                                               ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""

# Renk kodları
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Backend dizini
BACKEND_DIR="/home/snnunvr/Desktop/system_ios_monitor/backend"

echo "1️⃣  Eski backend process'lerini durdur..."
sudo pkill -9 python3 2>/dev/null || true
sleep 2
echo -e "${GREEN}✅ Eski process'ler temizlendi${NC}"
echo ""

echo "2️⃣  Systemd service dosyasını kopyala..."
sudo cp $BACKEND_DIR/system-monitor.service /etc/systemd/system/
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Service dosyası kopyalandı${NC}"
else
    echo -e "${RED}❌ Service dosyası kopyalanamadı!${NC}"
    exit 1
fi
echo ""

echo "3️⃣  Systemd daemon'ı yeniden yükle..."
sudo systemctl daemon-reload
echo -e "${GREEN}✅ Daemon yenilendi${NC}"
echo ""

echo "4️⃣  Service'i etkinleştir (boot'ta otomatik başlat)..."
sudo systemctl enable system-monitor.service
echo -e "${GREEN}✅ Service etkinleştirildi${NC}"
echo ""

echo "5️⃣  Service'i başlat..."
sudo systemctl start system-monitor.service
sleep 3
echo -e "${GREEN}✅ Service başlatıldı${NC}"
echo ""

echo "6️⃣  Service durumunu kontrol et..."
sudo systemctl status system-monitor.service --no-pager -l
echo ""

echo "7️⃣  Backend çalışıyor mu test et..."
sleep 2
if curl -s -m 5 http://localhost:1571/api/system/cpu > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Backend ÇALIŞIYOR!${NC}"
else
    echo -e "${YELLOW}⚠️  Backend henüz hazır değil (5 saniye daha bekle)${NC}"
fi
echo ""

echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║                                                               ║"
echo "║                    ✅ KURULUM TAMAMLANDI                      ║"
echo "║                                                               ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""
echo "📋 Kullanışlı Komutlar:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  Durumu kontrol et:"
echo "  $ sudo systemctl status system-monitor"
echo ""
echo "  Başlat:"
echo "  $ sudo systemctl start system-monitor"
echo ""
echo "  Durdur:"
echo "  $ sudo systemctl stop system-monitor"
echo ""
echo "  Restart:"
echo "  $ sudo systemctl restart system-monitor"
echo ""
echo "  Log'ları gör:"
echo "  $ sudo journalctl -u system-monitor -f"
echo ""
echo "  Boot'ta otomatik başlatmayı kapat:"
echo "  $ sudo systemctl disable system-monitor"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "🎉 Backend artık otomatik restart olacak!"
echo "   Çökerse 10 saniye içinde tekrar başlayacak!"
echo ""

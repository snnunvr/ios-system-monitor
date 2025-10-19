#!/bin/bash

# System Monitor - Backend Başlangıç Scripti

echo "🚀 System Monitor Backend Başlatılıyor..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Backend dizini
BACKEND_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/backend"

# Python venv'i aktifleştir
echo "📦 Sanal ortam aktifleştiriliyor..."
source "$BACKEND_DIR/venv/bin/activate"

# Backend'i başlat
echo "🔧 FastAPI Sunucusu başlatılıyor..."
echo "📍 URL: http://localhost:1571"
echo "📊 API Docs: http://localhost:1571/docs"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

cd "$BACKEND_DIR"
python3 main.py

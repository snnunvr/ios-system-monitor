# API Referans Dökümanı

## 📋 Genel Bilgi

**Base URL**: `http://localhost:1571` (veya Tailscale IP: `http://100.x.x.x:1571`)

**Otomatik Dokümantasyon**: `http://localhost:1571/docs` (Swagger UI)

---

## 🔌 REST API Endpoints

### 1. Sistem Bilgisi
**GET** `/api/system`

```json
{
  "timestamp": "2024-01-15T10:30:45",
  "cpu": {
    "usage_percent": 45.2,
    "frequency_ghz": 3.8,
    "cores": 8,
    "temp_celsius": 52.5
  },
  "memory": {
    "total_gb": 16.0,
    "used_gb": 8.5,
    "percent": 53.1
  },
  "disk": {
    "total_gb": 500.0,
    "used_gb": 250.0,
    "percent": 50.0,
    "temp_celsius": 35.0
  },
  "gpus": [
    {
      "id": 0,
      "name": "NVIDIA GeForce GTX 1660 Ti",
      "memory_total_mb": 6144,
      "memory_used_mb": 3072,
      "temperature": 60,
      "power_draw_w": 120.5,
      "utilization_percent": 85,
      "processes": []
    }
  ]
}
```

---

### 2. GPU Detay
**GET** `/api/gpu/{gpu_id}`

```json
{
  "id": 0,
  "name": "NVIDIA GeForce GTX 1660 Ti",
  "memory_total_mb": 6144,
  "memory_used_mb": 3072,
  "memory_percent": 50,
  "temperature": 60,
  "power_draw_w": 120.5,
  "power_limit_w": 120,
  "clock_speed_mhz": 1950,
  "memory_clock_mhz": 6000,
  "utilization_percent": 85,
  "processes": [
    {
      "pid": 12345,
      "name": "python3",
      "gpu_memory_mb": 2048
    }
  ]
}
```

---

### 3. Enerji Maliyeti
**GET** `/api/energy`

```json
{
  "electricity_rate_try_per_kwh": 15.0,
  "GPU_0_NVIDIA_GeForce_GTX_1660_Ti": {
    "power_draw_w": 120.5,
    "hourly_cost_try": 1.81,
    "daily_cost_try": 43.43,
    "monthly_cost_try": 1303.0
  },
  "GPU_1_NVIDIA_GeForce_RTX_2060": {
    "power_draw_w": 85.2,
    "hourly_cost_try": 1.28,
    "daily_cost_try": 30.71,
    "monthly_cost_try": 921.3
  },
  "CPU": {
    "power_draw_w": 95.0,
    "hourly_cost_try": 1.43,
    "daily_cost_try": 34.2,
    "monthly_cost_try": 1026.0
  },
  "RAM": {
    "power_draw_w": 15.0,
    "hourly_cost_try": 0.23,
    "daily_cost_try": 5.4,
    "monthly_cost_try": 162.0
  },
  "total_power_draw_w": 315.7,
  "total_hourly_cost_try": 4.75,
  "total_daily_cost_try": 114.0,
  "total_monthly_cost_try": 3412.3
}
```

**Query Parameters:**
- `rate` (opsiyonel): Elektrik fiyatı ₺/kWh (varsayılan: 15.0)

Örnek: `/api/energy?rate=12.5`

---

### 4. Port Analizi
**GET** `/api/ports`

```json
{
  "listening_ports": [
    {
      "port": 1571,
      "protocol": "tcp",
      "service": "system-monitor",
      "process_name": "python3",
      "pid": 2673276,
      "foreign": false
    },
    {
      "port": 5432,
      "protocol": "tcp",
      "service": "postgresql",
      "process_name": "postgres",
      "pid": 1234,
      "foreign": false
    }
  ],
  "established_connections": [
    {
      "local_address": "192.168.1.100:54321",
      "remote_address": "142.251.41.14:443",
      "protocol": "tcp",
      "state": "ESTABLISHED",
      "process_name": "chrome",
      "foreign": true
    }
  ],
  "foreign_connections": [
    {
      "remote_address": "142.251.41.14:443",
      "protocol": "tcp",
      "country": "US",
      "threat_level": "low"
    }
  ],
  "threat_summary": {
    "total_foreign_connections": 3,
    "suspicious_ports": 0
  }
}
```

---

### 5. Training Job'ları
**GET** `/api/training-jobs`

```json
{
  "active_jobs": [
    {
      "pid": 5678,
      "name": "train.py",
      "framework": "pytorch",
      "cpu_percent": 85.5,
      "memory_percent": 70.2,
      "gpu_memory_mb": 4096,
      "elapsed_seconds": 3600,
      "status": "running"
    }
  ],
  "total_active": 1,
  "total_gpu_memory_used_mb": 4096
}
```

---

### 6. Training Job Kontrol
**POST** `/api/training-jobs/{pid}/stop`

```json
{
  "success": true,
  "message": "Training job stopped"
}
```

**POST** `/api/training-jobs/{pid}/pause`

```json
{
  "success": true,
  "message": "Training job paused"
}
```

**POST** `/api/training-jobs/{pid}/resume`

```json
{
  "success": true,
  "message": "Training job resumed"
}
```

---

### 7. Sağlık Kontrolü
**GET** `/api/health`

```json
{
  "status": "healthy",
  "timestamp": "2024-01-15T10:30:45",
  "uptime_seconds": 7200,
  "services": {
    "gpu_monitor": "ok",
    "port_analyzer": "ok",
    "energy_calculator": "ok",
    "training_tracker": "ok"
  }
}
```

---

## 🔗 WebSocket

**URL**: `ws://localhost:1571/ws`

Gerçek zamanlı veri akışı için WebSocket bağlantısı aç.

### Bağlantı Parametreleri

- `interval` (opsiyonel): Veri gönderme aralığı saniye cinsinden (varsayılan: 2)

Örnek: `ws://localhost:1571/ws?interval=3`

### Gelen Veriler

```json
{
  "type": "system_update",
  "data": {
    "cpu_usage": 45.2,
    "memory_usage": 53.1,
    "gpu_usage": 85.0,
    "timestamp": "2024-01-15T10:30:45"
  }
}
```

---

## 🔐 Güvenlik Notları

✅ **Yerel Ağ**: Tailscale üzerinde şifrelenir
✅ **Açık Portlar**: 1571'e yalnızca Tailscale ağından erişim
✅ **CORS**: Sadece Flutter uygulamasından erişim izinli

---

## 🛠️ Error Codes

| Code | Anlamı |
|------|--------|
| 200 | Başarılı |
| 400 | Hatalı parametre |
| 404 | Endpoint bulunamadı |
| 500 | Sunucu hatası |
| 503 | Hizmet kullanılamaz |

---

## 📱 Flutter Kullanım Örneği

```dart
final client = ApiClient('http://100.x.x.x:1571');

// Sistem bilgisi al
final systemData = await client.getSystemInfo();
print('CPU: ${systemData['cpu']['usage_percent']}%');

// GPU bilgisi al
final gpuData = await client.getGpuInfo();
print('GPU Bellek: ${gpuData[0]['memory_percent']}%');

// Enerji maliyeti al
final energyCost = await client.getEnergyCost(rate: 15.0);
print('Aylık Maliyet: ${energyCost['total_monthly_cost_try']}₺');

// Port analizi
final ports = await client.analyzePorts();
print('Yabancı Bağlantılar: ${ports['threat_summary']['total_foreign_connections']}');

// Training job'ları
final jobs = await client.getTrainingJobs();
print('Aktif Job: ${jobs['total_active']}');
```

---

## 📊 Veri Güncelleme Frekansı

| Endpoint | Frekans | Açıklama |
|----------|---------|----------|
| `/api/system` | 2 saniye | Dashboard güncellemeleri |
| `/api/gpu/*` | 2 saniye | GPU detayları |
| `/api/ports` | 3 saniye | Port analizi (daha yavaş) |
| `/api/training-jobs` | 2 saniye | Training durumu |
| `/api/energy` | 5 saniye | Maliyet hesabı |

---

## 🧪 cURL Test Örnekleri

```bash
# Sistem bilgisi
curl http://localhost:1571/api/system

# Enerji maliyeti (15₺/kWh ile)
curl http://localhost:1571/api/energy

# Portları analiz et
curl http://localhost:1571/api/ports

# Training job'ları
curl http://localhost:1571/api/training-jobs

# Sağlık kontrolü
curl http://localhost:1571/api/health

# GPU detayları (GPU 0)
curl http://localhost:1571/api/gpu/0

# Training job'unu durdur (PID 5678)
curl -X POST http://localhost:1571/api/training-jobs/5678/stop
```

---

**Son Güncelleme**: 2024-01-15
**API Versiyonu**: 1.0
**Uyumluluk**: FastAPI 0.104.1 +

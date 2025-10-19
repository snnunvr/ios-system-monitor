"""
FastAPI Sunucu - Sistem Monitoring API
"""

from fastapi import FastAPI, WebSocket, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
import asyncio
import json
from typing import Dict, List, Any

from monitors.gpu_monitor import SystemMonitor
from monitors.energy_monitor import EnergyCalculator
from monitors.port_analyzer import PortAnalyzer
from monitors.training_tracker import TrainingTracker


# FastAPI uygulaması
app = FastAPI(
    title="System Monitor API",
    description="PC/GPU Monitoring, Energy Cost, Port Analysis, Training Tracker",
    version="1.0.0"
)

# CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Monitor'ları başlat
system_monitor = SystemMonitor()
energy_calculator = EnergyCalculator()
port_analyzer = PortAnalyzer()
training_tracker = TrainingTracker()

# WebSocket bağlantıları
active_connections: List[WebSocket] = []


@app.on_event("startup")
async def startup_event():
    """Startup event"""
    print("✅ System Monitor API başladı")
    print("📊 Monitoring servisleri hazır")


@app.get("/")
async def root():
    """Ana sayfa"""
    return {
        "status": "running",
        "message": "System Monitor API",
        "version": "1.0.0",
        "endpoints": {
            "system": "/api/system",
            "energy": "/api/energy",
            "ports": "/api/ports",
            "training": "/api/training",
            "ws": "/ws",
            "health": "/health"
        }
    }


@app.get("/health")
async def health_check():
    """Sağlık kontrolü"""
    return {"status": "healthy"}


# ============ SISTEM MONITORING ============

@app.get("/api/system")
async def get_system_info():
    """Sistem bilgisini al"""
    try:
        system_data = system_monitor.to_dict()
        return {
            "status": "success",
            "data": system_data
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.get("/api/system/gpu")
async def get_gpu_info():
    """Sadece GPU bilgisini al"""
    try:
        system_data = system_monitor.to_dict()
        return {
            "status": "success",
            "data": system_data.get("gpus", [])
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.get("/api/system/cpu")
async def get_cpu_info():
    """Sadece CPU bilgisini al"""
    try:
        system_data = system_monitor.to_dict()
        return {
            "status": "success",
            "data": system_data.get("cpu", {})
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.get("/api/system/memory")
async def get_memory_info():
    """Sadece bellek bilgisini al"""
    try:
        system_data = system_monitor.to_dict()
        return {
            "status": "success",
            "data": {
                "ram": system_data.get("ram", {}),
                "disk": system_data.get("disk", {})
            }
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


# ============ ENERJİ VE MALİYET ============

@app.get("/api/energy")
async def get_energy_cost():
    """Enerji maliyetini hesapla"""
    try:
        system_data = system_monitor.to_dict()
        energy_cost = energy_calculator.calculate_system_cost(system_data)
        energy_dict = energy_calculator.to_dict(energy_cost)
        
        return {
            "status": "success",
            "data": energy_dict
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.post("/api/energy/price")
async def set_electricity_price(price_per_kwh: float):
    """Elektrik fiyatını ayarla (TL/kWh)"""
    try:
        energy_calculator.set_electricity_price(price_per_kwh)
        return {
            "status": "success",
            "message": f"Elektrik fiyatı {price_per_kwh} TL/kWh olarak ayarlandı"
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


# ============ PORT ANALİZİ ============

@app.get("/api/ports")
async def analyze_ports():
    """Portları analiz et"""
    try:
        ports = port_analyzer.analyze_ports()
        ports_dict = port_analyzer.to_dict(ports)
        
        return {
            "status": "success",
            "data": ports_dict
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.get("/api/ports/listening")
async def get_listening_ports():
    """Dinlemede olan portları al"""
    try:
        ports = port_analyzer.analyze_ports()
        ports_dict = port_analyzer.to_dict(ports)
        
        return {
            "status": "success",
            "data": ports_dict.get("listening_ports", [])
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.get("/api/ports/established")
async def get_established_connections():
    """Kurulu bağlantıları al"""
    try:
        ports = port_analyzer.analyze_ports()
        ports_dict = port_analyzer.to_dict(ports)
        
        return {
            "status": "success",
            "data": ports_dict.get("established_connections", [])
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.get("/api/ports/foreign")
async def get_foreign_connections():
    """Dışarıdan bağlantıları al (güvenlik uyarısı)"""
    try:
        ports = port_analyzer.analyze_ports()
        ports_dict = port_analyzer.to_dict(ports)
        
        return {
            "status": "success",
            "data": {
                "foreign_connections": ports_dict.get("foreign_connections", []),
                "alert": ports_dict.get("foreign_alert", False)
            }
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


# ============ TRAİNİNG JOB TRACKER ============

@app.get("/api/training")
async def get_training_jobs():
    """Devam eden training job'larını al"""
    try:
        jobs = training_tracker.detect_training_processes()
        jobs_dict = training_tracker.to_dict(jobs)
        
        return {
            "status": "success",
            "data": jobs_dict
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.post("/api/training/stop/{pid}")
async def stop_training_job(pid: int):
    """Training job'ı durdur"""
    try:
        success = training_tracker.stop_training_job(pid)
        if success:
            return {
                "status": "success",
                "message": f"Job {pid} durduruldu"
            }
        else:
            raise HTTPException(status_code=400, detail="Job durdurulamadı")
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.post("/api/training/pause/{pid}")
async def pause_training_job(pid: int):
    """Training job'ı duraklat"""
    try:
        success = training_tracker.pause_training_job(pid)
        if success:
            return {
                "status": "success",
                "message": f"Job {pid} duraklat"
            }
        else:
            raise HTTPException(status_code=400, detail="Job duraklatılamadı")
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.post("/api/training/resume/{pid}")
async def resume_training_job(pid: int):
    """Training job'ı devam ettir"""
    try:
        success = training_tracker.resume_training_job(pid)
        if success:
            return {
                "status": "success",
                "message": f"Job {pid} devam ettirildi"
            }
        else:
            raise HTTPException(status_code=400, detail="Job devam ettirilemedi")
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


# ============ WEBSOCKET REAL-TIME ============

@app.websocket("/ws")
async def websocket_endpoint(websocket: WebSocket):
    """WebSocket real-time monitoring"""
    await websocket.accept()
    active_connections.append(websocket)
    
    try:
        while True:
            # Client'ten mesaj al
            data = await websocket.receive_text()
            
            if data == "system":
                # Sistem verisini gönder
                system_data = system_monitor.to_dict()
                await websocket.send_json({
                    "type": "system",
                    "data": system_data
                })
            
            elif data == "energy":
                # Enerji maliyetini gönder
                system_data = system_monitor.to_dict()
                energy_cost = energy_calculator.calculate_system_cost(system_data)
                energy_dict = energy_calculator.to_dict(energy_cost)
                await websocket.send_json({
                    "type": "energy",
                    "data": energy_dict
                })
            
            elif data == "ports":
                # Port bilgisini gönder
                ports = port_analyzer.analyze_ports()
                ports_dict = port_analyzer.to_dict(ports)
                await websocket.send_json({
                    "type": "ports",
                    "data": ports_dict
                })
            
            elif data == "training":
                # Training jobs'ları gönder
                jobs = training_tracker.detect_training_processes()
                jobs_dict = training_tracker.to_dict(jobs)
                await websocket.send_json({
                    "type": "training",
                    "data": jobs_dict
                })
            
            elif data == "all":
                # Tüm verileri gönder
                system_data = system_monitor.to_dict()
                energy_cost = energy_calculator.calculate_system_cost(system_data)
                ports = port_analyzer.analyze_ports()
                jobs = training_tracker.detect_training_processes()
                
                await websocket.send_json({
                    "type": "all",
                    "data": {
                        "system": system_data,
                        "energy": energy_calculator.to_dict(energy_cost),
                        "ports": port_analyzer.to_dict(ports),
                        "training": training_tracker.to_dict(jobs)
                    }
                })
            
            elif data.startswith("interval:"):
                # Periyodik gönderim
                try:
                    interval = int(data.split(":")[1])
                    while True:
                        system_data = system_monitor.to_dict()
                        energy_cost = energy_calculator.calculate_system_cost(system_data)
                        ports = port_analyzer.analyze_ports()
                        jobs = training_tracker.detect_training_processes()
                        
                        await websocket.send_json({
                            "type": "periodic",
                            "data": {
                                "system": system_data,
                                "energy": energy_calculator.to_dict(energy_cost),
                                "ports": port_analyzer.to_dict(ports),
                                "training": training_tracker.to_dict(jobs)
                            }
                        })
                        
                        await asyncio.sleep(interval)
                except (ValueError, IndexError):
                    await websocket.send_json({
                        "type": "error",
                        "message": "Geçersiz interval format: interval:saniye"
                    })
    
    except Exception as e:
        print(f"WebSocket hatası: {e}")
    
    finally:
        active_connections.remove(websocket)


if __name__ == "__main__":
    import uvicorn
    
    # Tailscale üzerinden erişim için 0.0.0.0 dinle
    uvicorn.run(
        app,
        host="0.0.0.0",
        port=1571,
        log_level="info"
    )

@app.post("/api/system/reboot/windows")
async def reboot_to_windows():
    """GRUB üzerinden Windows'a geçip reboot et"""
    try:
        import subprocess
        # GRUB'da Windows entry'sini bul ve seçili yap
        subprocess.run([
            'sudo', 'grub-reboot', 'Windows Boot Manager (on /dev/nvme0n1p1)'
        ], check=True)
        # Sistemi reboot et
        subprocess.run(['sudo', 'reboot'], check=False)
        return {"status": "success", "message": "Windows'a geçiliyor..."}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Reboot hatası: {str(e)}")


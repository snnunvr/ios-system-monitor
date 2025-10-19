"""
GPU ve Sistem Monitoring Modülü
GPU, CPU, RAM, Sıcaklık verilerini toplar
"""

import psutil
import subprocess
import json
from typing import Dict, List, Any, Optional
from dataclasses import dataclass
from datetime import datetime


@dataclass
class GPUInfo:
    """GPU Bilgi Sınıfı"""
    index: int
    name: str
    memory_total: float  # MB
    memory_used: float  # MB
    memory_free: float  # MB
    temperature: float  # Celsius
    power_draw: float  # Watts
    power_limit: float  # Watts
    utilization: float  # %
    compute_processes: List[Dict[str, Any]]


@dataclass
class SystemInfo:
    """Sistem Bilgi Sınıfı"""
    timestamp: str
    cpu_percent: float
    cpu_freq: float  # GHz
    cpu_count: int
    cpu_temp: float  # Celsius (eğer varsa)
    ram_total: float  # GB
    ram_used: float  # GB
    ram_percent: float
    disk_total: float  # GB
    disk_used: float  # GB
    disk_percent: float
    gpus: List[GPUInfo]


class GPUMonitor:
    """NVIDIA GPU Monitoring"""
    
    def __init__(self):
        self.has_nvidia = self._check_nvidia()
    
    def _check_nvidia(self) -> bool:
        """NVIDIA GPU'su olup olmadığını kontrol et"""
        try:
            subprocess.run(['nvidia-smi'], capture_output=True, check=True)
            return True
        except (subprocess.CalledProcessError, FileNotFoundError):
            return False
    
    def get_gpu_info(self) -> List[GPUInfo]:
        """Tüm GPU'ların bilgisini al"""
        if not self.has_nvidia:
            return []
        
        gpus = []
        try:
            # nvidia-smi komutundan JSON çıktısı al
            result = subprocess.run([
                'nvidia-smi',
                '--query-gpu=index,name,memory.total,memory.used,memory.free,temperature.gpu,power.draw,power.limit,utilization.gpu',
                '--format=csv,noheader,nounits'
            ], capture_output=True, text=True, check=True)
            
            for line in result.stdout.strip().split('\n'):
                if not line:
                    continue
                
                parts = [p.strip() for p in line.split(',')]
                if len(parts) < 9:
                    continue
                
                gpu_index = int(parts[0])
                gpu_name = parts[1]
                memory_total = float(parts[2])
                memory_used = float(parts[3])
                memory_free = float(parts[4])
                temperature = float(parts[5]) if parts[5] else 0.0
                power_draw = float(parts[6]) if parts[6] else 0.0
                power_limit = float(parts[7]) if parts[7] else 0.0
                utilization = float(parts[8]) if parts[8] else 0.0
                
                # Compute processes'i al
                compute_procs = self._get_compute_processes(gpu_index)
                
                gpu = GPUInfo(
                    index=gpu_index,
                    name=gpu_name,
                    memory_total=memory_total,
                    memory_used=memory_used,
                    memory_free=memory_free,
                    temperature=temperature,
                    power_draw=power_draw,
                    power_limit=power_limit,
                    utilization=utilization,
                    compute_processes=compute_procs
                )
                gpus.append(gpu)
            
        except Exception as e:
            print(f"GPU bilgisi alınamadı: {e}")
        
        return gpus
    
    def _get_compute_processes(self, gpu_index: int) -> List[Dict[str, Any]]:
        """GPU üzerindeki compute process'lerini al"""
        processes = []
        try:
            result = subprocess.run([
                'nvidia-smi',
                f'--id={gpu_index}',
                '--query-compute-apps=pid,process_name,used_memory',
                '--format=csv,noheader,nounits'
            ], capture_output=True, text=True, check=True)
            
            for line in result.stdout.strip().split('\n'):
                if not line:
                    continue
                
                parts = [p.strip() for p in line.split(',')]
                if len(parts) >= 3:
                    try:
                        processes.append({
                            'pid': int(parts[0]),
                            'name': parts[1],
                            'memory_mb': float(parts[2])
                        })
                    except (ValueError, IndexError):
                        pass
        except Exception as e:
            print(f"Compute processes alınamadı: {e}")
        
        return processes


class SystemMonitor:
    """Sistem Monitoring"""
    
    def __init__(self):
        self.gpu_monitor = GPUMonitor()
    
    def get_system_info(self) -> SystemInfo:
        """Tüm sistem bilgisini al"""
        # CPU bilgisi
        cpu_percent = psutil.cpu_percent(interval=1)
        cpu_freq = psutil.cpu_freq().current / 1000  # GHz
        cpu_count = psutil.cpu_count()
        cpu_temp = self._get_cpu_temp()
        
        # RAM bilgisi
        ram = psutil.virtual_memory()
        ram_total = ram.total / (1024**3)  # GB
        ram_used = ram.used / (1024**3)  # GB
        ram_percent = ram.percent
        
        # Disk bilgisi
        disk = psutil.disk_usage('/')
        disk_total = disk.total / (1024**3)  # GB
        disk_used = disk.used / (1024**3)  # GB
        disk_percent = disk.percent
        
        # GPU bilgisi
        gpus = self.gpu_monitor.get_gpu_info()
        
        return SystemInfo(
            timestamp=datetime.now().isoformat(),
            cpu_percent=cpu_percent,
            cpu_freq=cpu_freq,
            cpu_count=cpu_count,
            cpu_temp=cpu_temp,
            ram_total=ram_total,
            ram_used=ram_used,
            ram_percent=ram_percent,
            disk_total=disk_total,
            disk_used=disk_used,
            disk_percent=disk_percent,
            gpus=gpus
        )
    
    def _get_cpu_temp(self) -> float:
        """CPU sıcaklığını al (Linux için)"""
        try:
            temps = psutil.sensors_temperatures()
            if 'coretemp' in temps:
                return temps['coretemp'][0].current
            elif 'k10temp' in temps:
                return temps['k10temp'][0].current
            else:
                # İlk bulunan sensörü kullan
                for sensor_name, readings in temps.items():
                    if readings:
                        return readings[0].current
        except Exception:
            pass
        return 0.0
    
    def to_dict(self) -> Dict[str, Any]:
        """SystemInfo nesnesini dict'e çevir"""
        info = self.get_system_info()
        return {
            'timestamp': info.timestamp,
            'cpu': {
                'percent': info.cpu_percent,
                'freq_ghz': info.cpu_freq,
                'count': info.cpu_count,
                'temp_c': info.cpu_temp
            },
            'ram': {
                'total_gb': round(info.ram_total, 2),
                'used_gb': round(info.ram_used, 2),
                'percent': info.ram_percent
            },
            'disk': {
                'total_gb': round(info.disk_total, 2),
                'used_gb': round(info.disk_used, 2),
                'percent': info.disk_percent
            },
            'gpus': [
                {
                    'index': gpu.index,
                    'name': gpu.name,
                    'memory': {
                        'total_mb': round(gpu.memory_total, 2),
                        'used_mb': round(gpu.memory_used, 2),
                        'free_mb': round(gpu.memory_free, 2),
                        'percent': round((gpu.memory_used / gpu.memory_total * 100) if gpu.memory_total > 0 else 0, 2)
                    },
                    'temperature_c': gpu.temperature,
                    'power': {
                        'draw_w': round(gpu.power_draw, 2),
                        'limit_w': round(gpu.power_limit, 2)
                    },
                    'utilization_percent': gpu.utilization,
                    'compute_processes': gpu.compute_processes
                } for gpu in info.gpus
            ]
        }

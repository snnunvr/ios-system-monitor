"""
Training Job Tracker Modülü
GPU training process'lerini takip et
"""

import psutil
import subprocess
from typing import Dict, List, Any, Optional
from dataclasses import dataclass
from datetime import datetime
import re


@dataclass
class TrainingJob:
    """Training İşi Bilgisi"""
    pid: int
    process_name: str
    command: str
    status: str  # running, stopped, paused
    start_time: str
    cpu_percent: float
    memory_mb: float
    memory_percent: float
    gpu_index: Optional[int]
    gpu_memory_mb: float
    threads: int
    io_read_mb: float  # MB
    io_write_mb: float  # MB


class TrainingTracker:
    """Training Job Tracking"""
    
    # Training framework'leri tanı
    TRAINING_FRAMEWORKS = [
        'python', 'pytorch', 'tensorflow', 'torch', 'cuda',
        'train', 'training', 'model', 'fit', 'learn'
    ]
    
    def __init__(self):
        self.training_jobs: Dict[int, TrainingJob] = {}
    
    def detect_training_processes(self) -> List[TrainingJob]:
        """Training process'lerini tespit et"""
        training_jobs = []
        
        for proc in psutil.process_iter(['pid', 'name', 'cmdline', 'status']):
            try:
                pid = proc.pid
                name = proc.name()
                cmdline = ' '.join(proc.cmdline()) if proc.cmdline() else ''
                status = proc.status()
                
                # Training process mi?
                if self._is_training_process(name, cmdline):
                    job = self._create_training_job(proc, name, cmdline, status)
                    if job:
                        training_jobs.append(job)
                        self.training_jobs[pid] = job
            
            except (psutil.NoSuchProcess, psutil.AccessDenied, psutil.ZombieProcess):
                pass
        
        # Kayıtlı işleri kontrol et (silinen işleri kaldır)
        dead_pids = [pid for pid in self.training_jobs if pid not in [j.pid for j in training_jobs]]
        for pid in dead_pids:
            del self.training_jobs[pid]
        
        return training_jobs
    
    def _is_training_process(self, name: str, cmdline: str) -> bool:
        """Process'in training işi olup olmadığını kontrol et"""
        combined = (name + ' ' + cmdline).lower()
        
        # Python script'leri ve training framework'lerini ara
        if 'python' in combined:
            for keyword in self.TRAINING_FRAMEWORKS:
                if keyword in combined:
                    return True
        
        # Doğrudan training framework komutları
        for keyword in ['pytorch', 'tensorflow', 'torch']:
            if keyword in combined:
                return True
        
        return False
    
    def _create_training_job(self, proc: psutil.Process, name: str, 
                           cmdline: str, status: str) -> Optional[TrainingJob]:
        """Training Job nesnesi oluştur"""
        try:
            # Temel bilgiler
            pid = proc.pid
            
            # CPU ve Memory
            try:
                cpu_percent = proc.cpu_percent(interval=0.1)
                memory_info = proc.memory_info()
                memory_mb = memory_info.rss / (1024 * 1024)
                memory_percent = proc.memory_percent()
            except:
                cpu_percent = 0
                memory_mb = 0
                memory_percent = 0
            
            # GPU Memory (nvidia-smi'dan)
            gpu_index, gpu_memory_mb = self._get_gpu_memory_for_process(pid)
            
            # Thread sayısı
            try:
                threads = proc.num_threads()
            except:
                threads = 0
            
            # I/O istatistikleri
            try:
                io_counters = proc.io_counters()
                io_read_mb = io_counters.read_bytes / (1024 * 1024)
                io_write_mb = io_counters.write_bytes / (1024 * 1024)
            except:
                io_read_mb = 0
                io_write_mb = 0
            
            # Status map
            status_map = {
                psutil.STATUS_RUNNING: 'running',
                psutil.STATUS_SLEEPING: 'sleeping',
                psutil.STATUS_ZOMBIE: 'zombie',
                psutil.STATUS_STOPPED: 'stopped',
                psutil.STATUS_TRACING_STOP: 'tracing',
            }
            
            return TrainingJob(
                pid=pid,
                process_name=name,
                command=cmdline,
                status=status_map.get(status, status),
                start_time=datetime.fromtimestamp(proc.create_time()).isoformat(),
                cpu_percent=cpu_percent,
                memory_mb=memory_mb,
                memory_percent=memory_percent,
                gpu_index=gpu_index,
                gpu_memory_mb=gpu_memory_mb,
                threads=threads,
                io_read_mb=io_read_mb,
                io_write_mb=io_write_mb,
            )
        
        except Exception as e:
            print(f"Training job oluşturulamadı: {e}")
            return None
    
    def _get_gpu_memory_for_process(self, pid: int) -> tuple[Optional[int], float]:
        """Process'in GPU memory kullanımını al"""
        try:
            result = subprocess.run([
                'nvidia-smi',
                '--query-compute-apps=pid,gpu_uuid,used_memory',
                '--format=csv,noheader,nounits'
            ], capture_output=True, text=True, check=True)
            
            for line in result.stdout.strip().split('\n'):
                if not line:
                    continue
                
                parts = [p.strip() for p in line.split(',')]
                if len(parts) >= 3:
                    try:
                        proc_pid = int(parts[0])
                        gpu_uuid = parts[1]
                        memory_mb = float(parts[2])
                        
                        if proc_pid == pid:
                            # GPU UUID'den index'i bul
                            gpu_index = self._get_gpu_index_from_uuid(gpu_uuid)
                            return gpu_index, memory_mb
                    except ValueError:
                        pass
        
        except Exception as e:
            print(f"GPU memory alınamadı: {e}")
        
        return None, 0.0
    
    def _get_gpu_index_from_uuid(self, gpu_uuid: str) -> Optional[int]:
        """GPU UUID'den index'i bul"""
        try:
            result = subprocess.run([
                'nvidia-smi',
                '--query-gpu=index,gpu_uuid',
                '--format=csv,noheader'
            ], capture_output=True, text=True, check=True)
            
            for line in result.stdout.strip().split('\n'):
                if not line:
                    continue
                
                parts = [p.strip() for p in line.split(',')]
                if len(parts) >= 2:
                    try:
                        index = int(parts[0])
                        uuid = parts[1]
                        
                        if uuid == gpu_uuid:
                            return index
                    except ValueError:
                        pass
        
        except Exception:
            pass
        
        return None
    
    def get_job_by_pid(self, pid: int) -> Optional[TrainingJob]:
        """PID'den training job'ı al"""
        return self.training_jobs.get(pid)
    
    def stop_training_job(self, pid: int) -> bool:
        """Training job'ı durdur"""
        try:
            proc = psutil.Process(pid)
            proc.terminate()
            return True
        except Exception as e:
            print(f"Job durdurulamadı: {e}")
            return False
    
    def pause_training_job(self, pid: int) -> bool:
        """Training job'ı duraklat"""
        try:
            proc = psutil.Process(pid)
            proc.suspend()
            return True
        except Exception as e:
            print(f"Job duraklatılamadı: {e}")
            return False
    
    def resume_training_job(self, pid: int) -> bool:
        """Training job'ı devam ettir"""
        try:
            proc = psutil.Process(pid)
            proc.resume()
            return True
        except Exception as e:
            print(f"Job devam ettirilemedi: {e}")
            return False
    
    def to_dict(self, jobs: List[TrainingJob]) -> Dict[str, Any]:
        """Training jobs'ları dict'e çevir"""
        return {
            'timestamp': datetime.now().isoformat(),
            'total_jobs': len(jobs),
            'jobs': [
                {
                    'pid': job.pid,
                    'process_name': job.process_name,
                    'command': job.command,
                    'status': job.status,
                    'start_time': job.start_time,
                    'cpu': {
                        'percent': round(job.cpu_percent, 2)
                    },
                    'memory': {
                        'used_mb': round(job.memory_mb, 2),
                        'percent': round(job.memory_percent, 2)
                    },
                    'gpu': {
                        'index': job.gpu_index,
                        'memory_mb': round(job.gpu_memory_mb, 2)
                    } if job.gpu_index is not None else None,
                    'threads': job.threads,
                    'io': {
                        'read_mb': round(job.io_read_mb, 2),
                        'write_mb': round(job.io_write_mb, 2)
                    }
                } for job in jobs
            ]
        }

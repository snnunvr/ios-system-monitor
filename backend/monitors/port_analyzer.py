"""
Port Analizi Modülü
Açık portların, işlemlerin, ağ kullanımının detaylı analizi
"""

import subprocess
import json
from typing import Dict, List, Any, Optional
from dataclasses import dataclass
from datetime import datetime
import socket
import re


@dataclass
class PortInfo:
    """Port Bilgisi"""
    port: int
    protocol: str  # tcp/udp
    state: str  # LISTEN, ESTABLISHED, TIME_WAIT, etc
    pid: Optional[int]
    process_name: Optional[str]
    local_address: str
    remote_address: Optional[str]
    received_bytes: int
    sent_bytes: int
    is_foreign: bool  # Dışarıdan bir IP mi?


class PortAnalyzer:
    """Port Analizi ve Ağ Monitoring"""
    
    # Yerli subnet'ler (foreign olmayan)
    LOCAL_SUBNETS = [
        '127.0.0.1',
        '127.0.0.0/8',
        '192.168.0.0/16',
        '10.0.0.0/8',
        '172.16.0.0/12',
        '169.254.0.0/16',  # Link-local
        '::1',  # IPv6 loopback
        'fe80::/10',  # IPv6 link-local
        '::ffff:127.0.0.1',  # IPv6 mapped IPv4 loopback
    ]
    
    def __init__(self):
        self.open_ports: Dict[int, PortInfo] = {}
    
    def analyze_ports(self) -> List[PortInfo]:
        """Açık portları analiz et"""
        ports = []
        
        # netstat veya ss komutunu kullan
        try:
            ports.extend(self._analyze_with_ss())
        except Exception as e:
            print(f"ss komutu başarısız: {e}, netstat'a geçiliyor...")
            try:
                ports.extend(self._analyze_with_netstat())
            except Exception as e2:
                print(f"netstat de başarısız: {e2}")
        
        # Network istatistikleri ekle
        self._add_network_stats(ports)
        
        return ports
    
    def _analyze_with_ss(self) -> List[PortInfo]:
        """ss komutuyla port analizi"""
        ports = []
        
        try:
            # IPv4 TCP
            result = subprocess.run(
                ['ss', '-tlnp'],
                capture_output=True,
                text=True,
                check=True
            )
            ports.extend(self._parse_ss_output(result.stdout, 'tcp'))
            
            # IPv4 UDP
            result = subprocess.run(
                ['ss', '-ulnp'],
                capture_output=True,
                text=True,
                check=True
            )
            ports.extend(self._parse_ss_output(result.stdout, 'udp'))
            
        except Exception as e:
            print(f"ss analizi hatası: {e}")
        
        return ports
    
    def _parse_ss_output(self, output: str, protocol: str) -> List[PortInfo]:
        """ss komutunun çıktısını parse et"""
        ports = []
        lines = output.strip().split('\n')[1:]  # Header'ı atla
        
        for line in lines:
            if not line.strip():
                continue
            
            parts = line.split()
            if len(parts) < 4:
                continue
            
            # State, recv-q, send-q, local_address:port
            state = parts[0]
            local_addr_port = parts[3]
            remote_addr_port = parts[4] if len(parts) > 4 else '*:*'
            process_info = parts[5] if len(parts) > 5 else None
            
            # Port ve IP'yi çıkart
            try:
                if ':' in local_addr_port:
                    local_addr, port_str = local_addr_port.rsplit(':', 1)
                    port = int(port_str)
                else:
                    continue
            except (ValueError, IndexError):
                continue
            
            # Process bilgisini çıkart
            pid = None
            process_name = None
            if process_info and '(' in process_info:
                try:
                    pid_part = process_info.split('pid=')
                    if len(pid_part) > 1:
                        pid = int(pid_part[1].split(',')[0])
                        process_name = process_info.split('(')[1].split(')')[0]
                except (ValueError, IndexError):
                    pass
            
            # Dışarıdan bir IP mi?
            remote_addr = remote_addr_port.split(':')[0] if ':' in remote_addr_port else remote_addr_port
            is_foreign = not self._is_local_address(remote_addr) and remote_addr != '*'
            
            port_info = PortInfo(
                port=port,
                protocol=protocol,
                state=state,
                pid=pid,
                process_name=process_name,
                local_address=local_addr,
                remote_address=remote_addr if remote_addr != '*' else None,
                received_bytes=0,
                sent_bytes=0,
                is_foreign=is_foreign
            )
            ports.append(port_info)
        
        return ports
    
    def _analyze_with_netstat(self) -> List[PortInfo]:
        """netstat komutuyla port analizi"""
        ports = []
        
        try:
            result = subprocess.run(
                ['netstat', '-tlnp'],
                capture_output=True,
                text=True,
                check=True
            )
            ports.extend(self._parse_netstat_output(result.stdout, 'tcp'))
            
            result = subprocess.run(
                ['netstat', '-ulnp'],
                capture_output=True,
                text=True,
                check=True
            )
            ports.extend(self._parse_netstat_output(result.stdout, 'udp'))
            
        except Exception as e:
            print(f"netstat analizi hatası: {e}")
        
        return ports
    
    def _parse_netstat_output(self, output: str, protocol: str) -> List[PortInfo]:
        """netstat komutunun çıktısını parse et"""
        ports = []
        lines = output.strip().split('\n')[2:]  # Header'ları atla
        
        for line in lines:
            if not line.strip():
                continue
            
            parts = line.split()
            if len(parts) < 6:
                continue
            
            # Proto, recv-q, send-q, Local Address, Foreign Address, State [PID/Program name]
            local_addr_port = parts[3]
            foreign_addr_port = parts[4]
            state = parts[5]
            pid_prog = parts[6] if len(parts) > 6 else None
            
            try:
                if ':' in local_addr_port:
                    local_addr, port_str = local_addr_port.rsplit(':', 1)
                    port = int(port_str)
                else:
                    continue
            except (ValueError, IndexError):
                continue
            
            # PID ve process name'i çıkart
            pid = None
            process_name = None
            if pid_prog and '/' in pid_prog:
                try:
                    pid = int(pid_prog.split('/')[0])
                    process_name = pid_prog.split('/')[1]
                except (ValueError, IndexError):
                    pass
            
            # Dışarıdan bir IP mi?
            remote_addr = foreign_addr_port.split(':')[0] if ':' in foreign_addr_port else foreign_addr_port
            is_foreign = not self._is_local_address(remote_addr) and remote_addr != '*'
            
            port_info = PortInfo(
                port=port,
                protocol=protocol,
                state=state,
                pid=pid,
                process_name=process_name,
                local_address=local_addr,
                remote_address=remote_addr if remote_addr != '*' else None,
                received_bytes=0,
                sent_bytes=0,
                is_foreign=is_foreign
            )
            ports.append(port_info)
        
        return ports
    
    def _is_local_address(self, ip: str) -> bool:
        """IP adresinin lokal olup olmadığını kontrol et"""
        local_patterns = [
            r'^127\.',
            r'^192\.168\.',
            r'^10\.',
            r'^172\.(1[6-9]|2[0-9]|3[01])\.',
            r'^169\.254\.',
            r'^::1$',
            r'^fe80:',
            r'^::ffff:127\.',
        ]
        
        for pattern in local_patterns:
            if re.match(pattern, ip):
                return True
        
        return False
    
    def _add_network_stats(self, ports: List[PortInfo]):
        """Ağ istatistiklerini ekle"""
        try:
            # proc/net/dev'den ağ istatistiklerini al
            with open('/proc/net/dev', 'r') as f:
                for line in f:
                    if 'bytes' in line:
                        continue
                    parts = line.split()
                    if len(parts) >= 10:
                        interface = parts[0].rstrip(':')
                        recv_bytes = int(parts[1])
                        sent_bytes = int(parts[9])
                        
                        # Port'lara ekle (basit tahmin)
                        for port_info in ports:
                            if port_info.port == 0:
                                port_info.received_bytes = recv_bytes
                                port_info.sent_bytes = sent_bytes
        except Exception as e:
            print(f"Ağ stats alınamadı: {e}")
    
    def get_port_service_name(self, port: int, protocol: str = 'tcp') -> str:
        """Port numarasından servis adını al"""
        try:
            return socket.getservbyport(port, protocol)
        except OSError:
            return f"Unknown_{port}"
    
    def to_dict(self, ports: List[PortInfo]) -> Dict[str, Any]:
        """Port listesini dict'e çevir"""
        listening = []
        established = []
        foreign_ports = []
        
        for port in ports:
            port_dict = {
                'port': port.port,
                'protocol': port.protocol,
                'state': port.state,
                'pid': port.pid,
                'process_name': port.process_name,
                'local_address': port.local_address,
                'remote_address': port.remote_address,
                'service': self.get_port_service_name(port.port, port.protocol),
                'is_foreign': port.is_foreign,
                'received_bytes': port.received_bytes,
                'sent_bytes': port.sent_bytes,
            }
            
            if port.is_foreign:
                foreign_ports.append(port_dict)
            
            if port.state == 'LISTEN':
                listening.append(port_dict)
            elif port.state == 'ESTABLISHED':
                established.append(port_dict)
        
        return {
            'timestamp': datetime.now().isoformat(),
            'listening_ports': listening,
            'established_connections': established,
            'foreign_connections': foreign_ports,
            'total_ports': len(ports),
            'total_listening': len(listening),
            'total_established': len(established),
            'foreign_alert': len(foreign_ports) > 0,
            'all_ports': [
                {
                    'port': p.port,
                    'protocol': p.protocol,
                    'state': p.state,
                    'pid': p.pid,
                    'process_name': p.process_name,
                    'local_address': p.local_address,
                    'remote_address': p.remote_address,
                    'service': self.get_port_service_name(p.port, p.protocol),
                    'is_foreign': p.is_foreign,
                } for p in ports
            ]
        }

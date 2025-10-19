"""
Enerji Tüketimi ve Fiyatlandırma Modülü
GPU/CPU TDP değerlerinden aylık maliyeti hesapla
"""

from dataclasses import dataclass
from typing import Dict, Any, Optional
from datetime import datetime


@dataclass
class PowerConsumption:
    """Güç Tüketimi"""
    component: str  # "GPU", "CPU", etc
    power_w: float
    tdp_w: float
    utilization_percent: float


@dataclass
class EnergyCost:
    """Enerji Maliyeti"""
    timestamp: str
    total_power_w: float
    hourly_cost_try: float
    daily_cost_try: float
    monthly_cost_try: float
    components: Dict[str, Dict[str, float]]


class EnergyCalculator:
    """Enerji Tüketimi ve Maliyet Hesaplama"""
    
    # Türkiye elektrik fiyatı (kWh başına TL) - güncellenebilir
    TURKEY_ELECTRICITY_PRICE_PER_KWH = 15.0  # 2024 tahmini
    
    # Tipik TDP değerleri (Watt)
    TYPICAL_TDP = {
        'rtx_4090': 450,
        'rtx_4080': 320,
        'rtx_4070': 200,
        'rtx_3090': 420,
        'rtx_3080': 320,
        'rtx_3070': 220,
        'cpu_high': 150,
        'cpu_medium': 100,
        'cpu_low': 65,
    }
    
    def __init__(self, electricity_price_per_kwh: Optional[float] = None):
        """
        Args:
            electricity_price_per_kwh: kWh başına TL fiyatı
        """
        if electricity_price_per_kwh:
            self.electricity_price = electricity_price_per_kwh
        else:
            self.electricity_price = self.TURKEY_ELECTRICITY_PRICE_PER_KWH
    
    def calculate_gpu_cost(self, gpu_power_draw_w: float, gpu_utilization: float) -> Dict[str, float]:
        """
        GPU maliyetini hesapla
        
        Args:
            gpu_power_draw_w: GPU'nun şu an çektiği güç (Watt)
            gpu_utilization: GPU kullanım yüzdesi (0-100)
        
        Returns:
            Saatlik, günlük, aylık maliyetler
        """
        # Gerçek çekilen güç
        actual_power_w = gpu_power_draw_w
        
        # Saatlik tüketim (kWh)
        hourly_consumption_kwh = actual_power_w / 1000
        
        # Günlük tüketim (kWh) - 24 saat
        daily_consumption_kwh = hourly_consumption_kwh * 24
        
        # Aylık tüketim (kWh) - 30 gün
        monthly_consumption_kwh = daily_consumption_kwh * 30
        
        return {
            'hourly_consumption_kwh': round(hourly_consumption_kwh, 4),
            'hourly_cost_try': round(hourly_consumption_kwh * self.electricity_price, 2),
            'daily_consumption_kwh': round(daily_consumption_kwh, 4),
            'daily_cost_try': round(daily_consumption_kwh * self.electricity_price, 2),
            'monthly_consumption_kwh': round(monthly_consumption_kwh, 4),
            'monthly_cost_try': round(monthly_consumption_kwh * self.electricity_price, 2),
        }
    
    def calculate_system_cost(self, system_data: Dict[str, Any]) -> EnergyCost:
        """
        Tüm sistem maliyetini hesapla
        
        Args:
            system_data: GPU Monitor'dan gelen sistem verisi
        
        Returns:
            EnergyCost nesnesi
        """
        total_power_w = 0
        components = {}
        
        # GPU maliyetleri
        for gpu in system_data.get('gpus', []):
            gpu_power_w = gpu['power']['draw_w']
            gpu_name = gpu['name']
            
            gpu_cost = self.calculate_gpu_cost(
                gpu_power_w,
                gpu['utilization_percent']
            )
            
            total_power_w += gpu_power_w
            components[f"GPU_{gpu['index']}_{gpu_name}"] = gpu_cost
        
        # CPU maliyeti (tahmini)
        cpu_percent = system_data['cpu']['percent']
        # CPU'nun ortalama TDP'sini tahmin et
        cpu_tdp_w = 95  # Ortalama CPU TDP
        cpu_power_w = cpu_tdp_w * (cpu_percent / 100)
        
        cpu_cost = self.calculate_gpu_cost(cpu_power_w, cpu_percent)
        total_power_w += cpu_power_w
        components['CPU'] = cpu_cost
        
        # RAM maliyeti (tahmini - çok düşük)
        ram_power_w = system_data['ram']['used_gb'] * 0.5  # GB başına ~0.5W
        ram_cost = self.calculate_gpu_cost(ram_power_w, 100)
        total_power_w += ram_power_w
        components['RAM'] = ram_cost
        
        # Toplam maliyetler
        total_hourly_cost = total_power_w / 1000 * self.electricity_price
        total_daily_cost = total_hourly_cost * 24
        total_monthly_cost = total_daily_cost * 30
        
        return EnergyCost(
            timestamp=datetime.now().isoformat(),
            total_power_w=round(total_power_w, 2),
            hourly_cost_try=round(total_hourly_cost, 2),
            daily_cost_try=round(total_daily_cost, 2),
            monthly_cost_try=round(total_monthly_cost, 2),
            components=components
        )
    
    def to_dict(self, energy_cost: EnergyCost) -> Dict[str, Any]:
        """EnergyCost nesnesini dict'e çevir"""
        return {
            'timestamp': energy_cost.timestamp,
            'total_power_w': energy_cost.total_power_w,
            'costs': {
                'hourly_try': energy_cost.hourly_cost_try,
                'daily_try': energy_cost.daily_cost_try,
                'monthly_try': energy_cost.monthly_cost_try,
            },
            'electricity_price_per_kwh': self.electricity_price,
            'components': energy_cost.components
        }
    
    def set_electricity_price(self, price_per_kwh: float):
        """Elektrik fiyatını güncelle"""
        self.electricity_price = price_per_kwh

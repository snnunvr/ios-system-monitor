import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_client.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import '../widgets/gradient_card.dart';
import 'terminal_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late ApiClient apiClient;
  Map<String, dynamic>? systemData;
  bool isLoading = true;
  String? error;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    apiClient = context.read<ApiClient>();
    _loadData();
    _startAutoRefresh();
  }

  void _startAutoRefresh() {
    Future.delayed(Duration(seconds: 10), () {  // 2 → 10 saniye
      if (mounted && _selectedIndex == 0) {
        _loadData();
        _startAutoRefresh();
      } else if (mounted) {
        _startAutoRefresh();
      }
    });
  }

  Future<void> _loadData() async {
    try {
      final data = await apiClient.getSystemInfo();
      setState(() {
        systemData = data['data'];
        isLoading = false;
        error = null;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('📊 System Monitor'),
        centerTitle: true,
        backgroundColor: AppColors.bgCard,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildDashboard(),
          _buildGpuPage(),
          _buildPortsPage(),
          TerminalScreen(),
          _buildEnergyPage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.bgCard,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.memory),
            label: 'GPU',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.router),
            label: 'Portlar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.terminal),
            label: 'Terminal',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bolt),
            label: 'Enerji',
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard() {
    if (isLoading) return LoadingWidget(message: 'Sistem verisi yükleniyor...');
    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, color: AppColors.danger, size: 48),
            SizedBox(height: 16),
            Text('Bağlantı hatası', style: TextStyle(color: AppColors.textPrimary)),
            SizedBox(height: 8),
            Text(error!, style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            SizedBox(height: 16),
            ElevatedButton(onPressed: _loadData, child: Text('Tekrar Dene')),
          ],
        ),
      );
    }
    if (systemData == null) return LoadingWidget();

    final cpu = systemData!['cpu'] as Map<String, dynamic>? ?? {};
    final ram = systemData!['ram'] as Map<String, dynamic>? ?? {};
    final disk = systemData!['disk'] as Map<String, dynamic>? ?? {};
    final gpus = (systemData!['gpus'] as List<dynamic>?) ?? [];

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            childAspectRatio: 1.2,
            children: [
              GradientStatCard(
                title: 'CPU Kullanımı',
                value: '${(cpu?['percent'] as num? ?? 0).toStringAsFixed(0)}%',
                icon: Icons.speed,
                gradientColors: [Color(0xFFFF6B6B), Color(0xFFEE5A6F)],
              ),
              GradientStatCard(
                title: 'RAM Kullanımı',
                value: '${(ram?['percent'] as num? ?? 0).toStringAsFixed(0)}%',
                icon: Icons.memory,
                gradientColors: [Color(0xFF4ECDC4), Color(0xFF44A08D)],
              ),
              GradientStatCard(
                title: 'Disk Kullanımı',
                value: '${(disk?['percent'] as num? ?? 0).toStringAsFixed(0)}%',
                icon: Icons.storage,
                gradientColors: [Color(0xFF667EEA), Color(0xFF764BA2)],
              ),
              GradientStatCard(
                title: 'GPU Count',
                value: '${gpus.length}',
                icon: Icons.videogame_asset,
                gradientColors: [Color(0xFFF093FB), Color(0xFFF5576C)],
              ),
            ],
          ),
          SizedBox(height: 20),
          AnimatedProgressCard(
            title: '🖥️ İşlemci',
            value: (cpu?['percent'] as num? ?? 0).toDouble(),
            color: AppColors.danger,
            icon: Icons.speed,
            subtitle: '${cpu?['count']} Cores @ ${(cpu?['freq_ghz'] ?? 0).toStringAsFixed(2)} GHz · ${(cpu?['temp_c'] ?? 0).toStringAsFixed(1)}°C',
          ),
          SizedBox(height: 12),
          AnimatedProgressCard(
            title: '💾 Bellek (RAM)',
            value: (ram?['percent'] as num? ?? 0).toDouble(),
            color: AppColors.primary,
            icon: Icons.memory,
            subtitle: '${(ram?['used_gb'] ?? 0).toStringAsFixed(1)}/${(ram?['total_gb'] ?? 0).toStringAsFixed(1)} GB kullanılıyor',
          ),
          SizedBox(height: 12),
          AnimatedProgressCard(
            title: '💿 Disk',
            value: (disk?['percent'] as num? ?? 0).toDouble(),
            color: AppColors.success,
            icon: Icons.storage,
            subtitle: '${(disk?['used_gb'] ?? 0).toStringAsFixed(1)}/${(disk?['total_gb'] ?? 0).toStringAsFixed(1)} GB kullanılıyor',
          ),
          SizedBox(height: 12),
          if (gpus.isNotEmpty) _buildGpuList(gpus),
          SizedBox(height: 12),
          Container(
            width: double.infinity,
            margin: EdgeInsets.symmetric(horizontal: 4),
            child: ElevatedButton.icon(
              onPressed: () => _rebootToWindows(context),
              icon: Icon(Icons.computer, size: 20),
              label: Text('🪟 Windows\'a Geç', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF0078D4),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGpuList(List<dynamic> gpus) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('🎮 GPU\'lar (${gpus.length})', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16)),
        SizedBox(height: 8),
        ...gpus.map((gpu) {
          final memory = gpu['memory'];
          return GlassCard(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(gpu['name'], style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 14)),
                SizedBox(height: 12),
                AnimatedProgressCard(
                  title: 'Kullanım',
                  value: (gpu['utilization_percent'] as num? ?? 0).toDouble(),
                  color: AppColors.warning,
                  icon: Icons.show_chart,
                  subtitle: '',
                ),
                SizedBox(height: 8),
                AnimatedProgressCard(
                  title: 'VRAM',
                  value: (memory['percent'] as num? ?? 0).toDouble(),
                  color: AppColors.info,
                  icon: Icons.memory,
                  subtitle: '${(memory['used_mb'] ?? 0) ~/ 1024}/${(memory['total_mb'] ?? 0) ~/ 1024} GB',
                ),
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.thermostat, color: AppColors.info, size: 16),
                        SizedBox(width: 4),
                        Text('${(gpu['temperature_c'] ?? 0).toStringAsFixed(0)}°C', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.bolt, color: AppColors.danger, size: 16),
                        SizedBox(width: 4),
                        Text('${(gpu['power']['draw_w'] ?? 0).toStringAsFixed(0)}W', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildGpuPage() {
    return Center(child: Text('GPU Detayı - Yapılacak', style: TextStyle(color: AppColors.textPrimary)));
  }

  Widget _buildPortsPage() {
    return Center(child: Text('Port Analizi - Yapılacak', style: TextStyle(color: AppColors.textPrimary)));
  }

  Widget _buildEnergyPage() {
    return Center(child: Text('Enerji Maliyeti - Yapılacak', style: TextStyle(color: AppColors.textPrimary)));
  }

  Future<void> _rebootToWindows(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        title: Text('⚠️ Windows\'a Geç', style: TextStyle(color: AppColors.textPrimary)),
        content: Text(
          'Ubuntu kapatılıp Windows başlatılacak. Onaylıyor musunuz?',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('İptal', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            child: Text('Windows\'a Geç'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await apiClient.dio.post('/api/system/reboot/windows');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✓ Windows\'a geçiş başlatılıyor...'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Hata: $e'),
              backgroundColor: AppColors.danger,
            ),
          );
        }
      }
    }
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_client.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class GpuMonitorScreen extends StatefulWidget {
  const GpuMonitorScreen({super.key});

  @override
  State<GpuMonitorScreen> createState() => _GpuMonitorScreenState();
}

class _GpuMonitorScreenState extends State<GpuMonitorScreen> {
  late ApiClient apiClient;
  List<dynamic>? gpus;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    apiClient = context.read<ApiClient>();
    _loadGpuData();
    _startRefreshTimer();
  }

  void _startRefreshTimer() {
    Future.delayed(Duration(seconds: 2), () {
      if (mounted) {
        _loadGpuData();
        _startRefreshTimer();
      }
    });
  }

  Future<void> _loadGpuData() async {
    try {
      final data = await apiClient.getGpuInfo();
      setState(() {
        gpus = data['data'] as List<dynamic>;
        isLoading = false;
        errorMessage = null;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return LoadingWidget(message: 'GPU verileri yükleniyor...');
    }

    if (errorMessage != null) {
      return ErrorWidget(
        message: errorMessage!,
        onRetry: _loadGpuData,
      );
    }

    if (gpus == null || gpus!.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.memory,
              color: AppColors.textSecondary,
              size: 48,
            ),
            SizedBox(height: 16),
            Text(
              'NVIDIA GPU bulunamadı',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'GPU Detayları',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          SizedBox(height: 16),
          ...gpus!.map((gpu) => _buildGpuDetailCard(gpu)),
        ],
      ),
    );
  }

  Widget _buildGpuDetailCard(dynamic gpu) {
    final memory = gpu['memory'] as Map<String, dynamic>;
    final power = gpu['power'] as Map<String, dynamic>;
    final processes = gpu['compute_processes'] as List<dynamic>;

    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Container(
        decoration: BoxDecoration(
          gradient: AppColors.gradientCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.bgCardLight,
            width: 1,
          ),
        ),
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // GPU Adı
            Text(
              '${gpu['name']}',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),

            // Kullanım
            ProgressBar(
              label: 'GPU Kullanımı',
              value: gpu['utilization_percent'],
              color: AppColors.primary,
            ),
            SizedBox(height: 16),

            // Bellek
            ProgressBar(
              label: 'Bellek Kullanımı',
              value: memory['used_mb'],
              max: memory['total_mb'],
              color: AppColors.secondary,
            ),
            SizedBox(height: 16),

            // İnfolar
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.bgDarker,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  InfoTile(
                    label: 'Sıcaklık',
                    value: '${gpu['temperature_c'].toStringAsFixed(1)}°C',
                    icon: Icons.thermostat,
                    valueColor: gpu['temperature_c'] > 80
                        ? AppColors.danger
                        : gpu['temperature_c'] > 60
                            ? AppColors.warning
                            : AppColors.success,
                  ),
                  InfoTile(
                    label: 'Güç Tüketimi',
                    value: '${power['draw_w'].toStringAsFixed(1)}W / ${power['limit_w'].toStringAsFixed(1)}W',
                    icon: Icons.bolt,
                    valueColor: power['draw_w'] > power['limit_w'] * 0.9
                        ? AppColors.danger
                        : AppColors.warning,
                  ),
                  InfoTile(
                    label: 'Bellek',
                    value:
                        '${memory['used_mb'].toStringAsFixed(0)}MB / ${memory['total_mb'].toStringAsFixed(0)}MB',
                    icon: Icons.storage,
                  ),
                ],
              ),
            ),

            // Process'ler
            if (processes.isNotEmpty) ...[
              SizedBox(height: 16),
              Text(
                'Aktif Process\'ler (${processes.length})',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8),
              ...processes.map((proc) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '${proc['name']} (PID: ${proc['pid']})',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '${proc['memory_mb'].toStringAsFixed(0)}MB',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}

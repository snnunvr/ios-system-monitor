import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_client.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class TrainingTrackerScreen extends StatefulWidget {
  const TrainingTrackerScreen({super.key});

  @override
  State<TrainingTrackerScreen> createState() => _TrainingTrackerScreenState();
}

class _TrainingTrackerScreenState extends State<TrainingTrackerScreen> {
  late ApiClient apiClient;
  Map<String, dynamic>? trainingData;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    apiClient = context.read<ApiClient>();
    _loadTrainingData();
    _startRefreshTimer();
  }

  void _startRefreshTimer() {
    Future.delayed(Duration(seconds: 2), () {
      if (mounted) {
        _loadTrainingData();
        _startRefreshTimer();
      }
    });
  }

  Future<void> _loadTrainingData() async {
    try {
      final data = await apiClient.getTrainingJobs();
      setState(() {
        trainingData = data['data'] as Map<String, dynamic>;
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

  Future<void> _stopJob(int pid) async {
    try {
      await apiClient.stopTrainingJob(pid);
      _loadTrainingData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Job $pid durduruldu'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return LoadingWidget(message: 'Training jobs yükleniyor...');
    }

    if (errorMessage != null) {
      return ErrorWidget(
        message: errorMessage!,
        onRetry: _loadTrainingData,
      );
    }

    if (trainingData == null) {
      return ErrorWidget(message: 'Training verileri alınamadı');
    }

    final jobs = trainingData!['jobs'] as List<dynamic>;
    final totalJobs = trainingData!['total_jobs'] as int;

    if (totalJobs == 0) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.school,
              color: AppColors.textSecondary,
              size: 48,
            ),
            SizedBox(height: 16),
            Text(
              'Training işi çalışmıyor',
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
            'Aktif Training İşleri',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          SizedBox(height: 8),
          Text(
            'Toplam: $totalJobs',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          SizedBox(height: 16),
          ...jobs.map((job) => _buildJobCard(job)),
        ],
      ),
    );
  }

  Widget _buildJobCard(dynamic job) {
    final cpu = job['cpu'] as Map<String, dynamic>;
    final memory = job['memory'] as Map<String, dynamic>;
    final gpu = job['gpu'];
    final io = job['io'] as Map<String, dynamic>;

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
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job['process_name'],
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'PID: ${job['pid']}',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(job['status']).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    job['status'].toString().toUpperCase(),
                    style: TextStyle(
                      color: _getStatusColor(job['status']),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),

            // Command
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.bgDarker,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                job['command'],
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                  fontFamily: 'monospace',
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(height: 12),

            // Resources
            ProgressBar(
              label: 'CPU',
              value: cpu['percent'],
              color: AppColors.gpuOrange,
            ),
            SizedBox(height: 12),

            ProgressBar(
              label: 'Bellek',
              value: memory['percent'],
              color: AppColors.secondary,
            ),
            SizedBox(height: 12),

            // İnfo
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.bgDarker,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Column(
                children: [
                  InfoTile(
                    label: 'Bellek Kullanımı',
                    value: '${memory['used_mb'].toStringAsFixed(0)}MB',
                    icon: Icons.memory,
                  ),
                  InfoTile(
                    label: 'Thread\'ler',
                    value: '${job['threads']}',
                    icon: Icons.grain,
                  ),
                  InfoTile(
                    label: 'Okuma I/O',
                    value: '${io['read_mb'].toStringAsFixed(2)}MB',
                    icon: Icons.download,
                  ),
                  InfoTile(
                    label: 'Yazma I/O',
                    value: '${io['write_mb'].toStringAsFixed(2)}MB',
                    icon: Icons.upload,
                  ),
                  if (gpu != null && gpu['index'] != null) ...[
                    SizedBox(height: 8),
                    InfoTile(
                      label: 'GPU ${gpu['index']}',
                      value: '${gpu['memory_mb'].toStringAsFixed(0)}MB',
                      icon: Icons.memory,
                      valueColor: AppColors.primary,
                    ),
                  ],
                ],
              ),
            ),

            // Butonlar
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: Icon(Icons.stop),
                    label: Text('Durdur'),
                    onPressed: () => _stopJob(job['pid']),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.danger,
                      side: BorderSide(color: AppColors.danger),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'running':
        return AppColors.success;
      case 'sleeping':
        return AppColors.info;
      case 'stopped':
        return AppColors.danger;
      case 'zombie':
        return AppColors.danger;
      default:
        return AppColors.warning;
    }
  }
}

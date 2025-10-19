import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_client.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class PortAnalysisScreen extends StatefulWidget {
  const PortAnalysisScreen({super.key});

  @override
  State<PortAnalysisScreen> createState() => _PortAnalysisScreenState();
}

class _PortAnalysisScreenState extends State<PortAnalysisScreen> {
  late ApiClient apiClient;
  Map<String, dynamic>? portData;
  bool isLoading = true;
  String? errorMessage;
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    apiClient = context.read<ApiClient>();
    _loadPortData();
    _startRefreshTimer();
  }

  void _startRefreshTimer() {
    Future.delayed(Duration(seconds: 3), () {
      if (mounted) {
        _loadPortData();
        _startRefreshTimer();
      }
    });
  }

  Future<void> _loadPortData() async {
    try {
      final data = await apiClient.analyzePorts();
      setState(() {
        portData = data['data'] as Map<String, dynamic>;
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
      return LoadingWidget(message: 'Port verileri yükleniyor...');
    }

    if (errorMessage != null) {
      return ErrorWidget(
        message: errorMessage!,
        onRetry: _loadPortData,
      );
    }

    if (portData == null) {
      return ErrorWidget(message: 'Port verileri alınamadı');
    }

    final listeningPorts = portData!['listening_ports'] as List<dynamic>;
    final establishedConnections = portData!['established_connections'] as List<dynamic>;
    final foreignConnections = portData!['foreign_connections'] as List<dynamic>;
    final alert = portData!['foreign_alert'] as bool;

    return Column(
      children: [
        // Sekmeler
        Container(
          color: AppColors.bgCard,
          child: Row(
            children: [
              _buildTabButton('Dinlemede (${listeningPorts.length})', 0),
              _buildTabButton('Kurulu (${establishedConnections.length})', 1),
              _buildTabButton(
                '⚠️ Dış (${foreignConnections.length})',
                2,
                alert: alert,
              ),
            ],
          ),
        ),
        // İçerik
        Expanded(
          child: _buildTabContent(
            _selectedTab,
            listeningPorts,
            establishedConnections,
            foreignConnections,
          ),
        ),
      ],
    );
  }

  Widget _buildTabButton(String label, int index, {bool alert = false}) {
    final isSelected = _selectedIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? AppColors.primary : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  int get _selectedIndex => _selectedTab;

  Widget _buildTabContent(
    int tabIndex,
    List<dynamic> listening,
    List<dynamic> established,
    List<dynamic> foreign,
  ) {
    List<dynamic> data;
    String emptyMessage;

    switch (tabIndex) {
      case 0:
        data = listening;
        emptyMessage = 'Dinlemede olan port yok';
        break;
      case 1:
        data = established;
        emptyMessage = 'Kurulu bağlantı yok';
        break;
      case 2:
        data = foreign;
        emptyMessage = 'Dış bağlantı yok';
        break;
      default:
        return SizedBox();
    }

    if (data.isEmpty) {
      return Center(
        child: Text(
          emptyMessage,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 16,
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: data.map((port) => _buildPortCard(port, tabIndex)).toList(),
      ),
    );
  }

  Widget _buildPortCard(dynamic port, int tabIndex) {
    final isAlert = port['is_foreign'] as bool;

    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          gradient: AppColors.gradientCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isAlert ? AppColors.danger : AppColors.bgCardLight,
            width: 1,
          ),
        ),
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${port['service'] ?? 'Unknown'} (${port['port']})',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '${port['protocol'].toString().toUpperCase()} • ${port['state']}',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isAlert)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.danger.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'DIS',
                      style: TextStyle(
                        color: AppColors.danger,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.bgDarker,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Column(
                children: [
                  if (port['process_name'] != null)
                    InfoTile(
                      label: 'Process',
                      value: '${port['process_name']} (${port['pid']})',
                      icon: Icons.process,
                    ),
                  InfoTile(
                    label: 'Lokal',
                    value: port['local_address'],
                    icon: Icons.computer,
                  ),
                  if (port['remote_address'] != null)
                    InfoTile(
                      label: 'Uzak',
                      value: port['remote_address'],
                      icon: Icons.cloud,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

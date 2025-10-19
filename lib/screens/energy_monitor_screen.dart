import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_client.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class EnergyMonitorScreen extends StatefulWidget {
  const EnergyMonitorScreen({super.key});

  @override
  State<EnergyMonitorScreen> createState() => _EnergyMonitorScreenState();
}

class _EnergyMonitorScreenState extends State<EnergyMonitorScreen> {
  late ApiClient apiClient;
  Map<String, dynamic>? energyData;
  bool isLoading = true;
  String? errorMessage;
  late TextEditingController _priceController;

  @override
  void initState() {
    super.initState();
    apiClient = context.read<ApiClient>();
    _priceController = TextEditingController(text: '15.0');
    _loadEnergyData();
    _startRefreshTimer();
  }

  void _startRefreshTimer() {
    Future.delayed(Duration(seconds: 2), () {
      if (mounted) {
        _loadEnergyData();
        _startRefreshTimer();
      }
    });
  }

  Future<void> _loadEnergyData() async {
    try {
      final data = await apiClient.getEnergyCost();
      setState(() {
        energyData = data['data'] as Map<String, dynamic>;
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

  Future<void> _updatePrice() async {
    try {
      final price = double.parse(_priceController.text);
      await apiClient.getEnergyCost();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fiyat $price TL/kWh olarak ayarlandı'),
            backgroundColor: AppColors.success,
          ),
        );
      }
      _loadEnergyData();
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
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return LoadingWidget(message: 'Enerji verileri yükleniyor...');
    }

    if (errorMessage != null) {
      return ErrorWidget(
        message: errorMessage!,
        onRetry: _loadEnergyData,
      );
    }

    if (energyData == null) {
      return ErrorWidget(message: 'Enerji verileri alınamadı');
    }

    final costs = energyData!['costs'] as Map<String, dynamic>;
    final totalPower = energyData!['total_power_w'] as double;
    final components = energyData!['components'] as Map<String, dynamic>;

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '⚡ Enerji Maliyeti',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          SizedBox(height: 16),

          // Ana kartlar
          GridView.count(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            children: [
              StatCard(
                title: 'Saatlik',
                value: '₺${costs['hourly_try'].toStringAsFixed(2)}',
                icon: Icons.schedule,
                valueColor: AppColors.info,
              ),
              StatCard(
                title: 'Günlük',
                value: '₺${costs['daily_try'].toStringAsFixed(2)}',
                icon: Icons.calendar_today,
                valueColor: AppColors.warning,
              ),
              StatCard(
                title: 'Aylık',
                value: '₺${costs['monthly_try'].toStringAsFixed(2)}',
                icon: Icons.event,
                valueColor: AppColors.danger,
              ),
            ],
          ),
          SizedBox(height: 24),

          // Toplam Güç
          Container(
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
              children: [
                Text(
                  'Toplam Güç Tüketimi',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '${totalPower.toStringAsFixed(1)}W',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '${(totalPower / 1000).toStringAsFixed(2)} kW',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24),

          // Elektrik Fiyatı
          SectionHeader(title: 'Elektrik Fiyatı'),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: '15.0',
                    label: Text('TL/kWh'),
                    suffixIcon: Icon(Icons.attach_money),
                  ),
                ),
              ),
              SizedBox(width: 12),
              ElevatedButton.icon(
                icon: Icon(Icons.check),
                label: Text('Kaydet'),
                onPressed: _updatePrice,
              ),
            ],
          ),
          SizedBox(height: 24),

          // Bileşen detayları
          SectionHeader(title: 'Bileşen Maliyetleri'),
          SizedBox(height: 12),
          ...components.entries.map((entry) {
            final name = entry.key;
            final cost = entry.value as Map<String, dynamic>;
            return _buildComponentCard(name, cost);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildComponentCard(String name, Map<String, dynamic> cost) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          gradient: AppColors.gradientCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.bgCardLight,
            width: 1,
          ),
        ),
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.bgDarker,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Column(
                children: [
                  InfoTile(
                    label: 'Saatlik',
                    value: '₺${cost['hourly_cost_try'].toStringAsFixed(2)}',
                    icon: Icons.schedule,
                  ),
                  InfoTile(
                    label: 'Günlük',
                    value: '₺${cost['daily_cost_try'].toStringAsFixed(2)}',
                    icon: Icons.calendar_today,
                  ),
                  InfoTile(
                    label: 'Aylık',
                    value: '₺${cost['monthly_cost_try'].toStringAsFixed(2)}',
                    icon: Icons.event,
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

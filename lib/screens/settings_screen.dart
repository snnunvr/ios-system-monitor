import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_client.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _serverUrlController;
  late ApiClient apiClient;
  bool isConnected = false;
  bool isChecking = false;

  @override
  void initState() {
    super.initState();
    apiClient = context.read<ApiClient>();
    _serverUrlController = TextEditingController(text: 'http://localhost:1571');
    _checkConnection();
  }

  Future<void> _checkConnection() async {
    setState(() => isChecking = true);
    
    try {
      final connected = await apiClient.healthCheck();
      setState(() {
        isConnected = connected;
        isChecking = false;
      });
    } catch (e) {
      setState(() {
        isConnected = false;
        isChecking = false;
      });
    }
  }

  Future<void> _saveSettings() async {
    final url = _serverUrlController.text;
    apiClient.setBaseUrl(url);
    
    await _checkConnection();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isConnected 
              ? 'Bağlantı başarılı! $url'
              : 'Bağlantı başarısız. URL kontrol et.',
          ),
          backgroundColor: isConnected ? AppColors.success : AppColors.danger,
        ),
      );
    }
  }

  @override
  void dispose() {
    _serverUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('⚙️ Ayarlar'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sunucu Bağlantısı
            SectionHeader(title: 'Sunucu Ayarları'),
            SizedBox(height: 12),
            
            Text(
              'Backend URL',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _serverUrlController,
              decoration: InputDecoration(
                hintText: 'http://localhost:1571',
                label: Text('Sunucu Adresi'),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isChecking)
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.primary,
                          ),
                          strokeWidth: 2,
                        ),
                      )
                    else
                      Icon(
                        isConnected ? Icons.check_circle : Icons.error_circle,
                        color: isConnected
                            ? AppColors.success
                            : AppColors.danger,
                      ),
                    SizedBox(width: 8),
                  ],
                ),
              ),
            ),
            SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.refresh),
                    label: Text('Test Bağlantı'),
                    onPressed: _checkConnection,
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.save),
                    label: Text('Kaydet'),
                    onPressed: _saveSettings,
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),

            // Bağlantı Durumu
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: AppColors.gradientCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isConnected
                      ? AppColors.success.withOpacity(0.5)
                      : AppColors.danger.withOpacity(0.5),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        isConnected ? Icons.check_circle : Icons.error_circle,
                        color: isConnected
                            ? AppColors.success
                            : AppColors.danger,
                        size: 24,
                      ),
                      SizedBox(width: 12),
                      Text(
                        isConnected
                            ? 'Sunucuya bağlı'
                            : 'Sunucuya bağlı değil',
                        style: TextStyle(
                          color: isConnected
                              ? AppColors.success
                              : AppColors.danger,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    _serverUrlController.text,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),

            // Tailscale Bilgileri
            SectionHeader(title: 'Tailscale Kullanımı'),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: AppColors.gradientCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.bgCardLight,
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '📱 iPhone\'dan Erişim',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '1. iPhone\'da Tailscale uygulamasını yükle\n'
                    '2. Aynı Tailscale ağına bağlan\n'
                    '3. Ubuntu cihazının Tailscale IP\'sini kullan\n'
                    '4. Örneğin: http://100.x.x.x:1571',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),

            // Hakkında
            SectionHeader(title: 'Hakkında'),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: AppColors.gradientCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.bgCardLight,
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InfoTile(
                    label: 'Uygulama',
                    value: 'System Monitor',
                    icon: Icons.info,
                  ),
                  InfoTile(
                    label: 'Sürüm',
                    value: '1.0.0',
                    icon: Icons.tag,
                  ),
                  InfoTile(
                    label: 'Geliştirici',
                    value: 'System Monitor Team',
                    icon: Icons.person,
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

import 'package:flutter/material.dart';
import 'package:dartssh2/dartssh2.dart';
import 'package:xterm/xterm.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class TerminalScreen extends StatefulWidget {
  const TerminalScreen({super.key});

  @override
  State<TerminalScreen> createState() => _TerminalScreenState();
}

class _TerminalScreenState extends State<TerminalScreen> {
  final terminal = Terminal();
  SSHClient? client;
  SSHSession? session;
  bool isConnected = false;
  bool isConnecting = false;
  
  final TextEditingController _hostController = TextEditingController(text: '100.64.0.1');
  final TextEditingController _portController = TextEditingController(text: '22');
  final TextEditingController _usernameController = TextEditingController(text: 'ubuntu');
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    terminal.write('Ubuntu Terminal - Tailscale SSH\r\n');
    terminal.write('Bağlanmak için yukarıdaki bilgileri girin.\r\n\r\n');
  }

  Future<void> _connectSSH() async {
    if (isConnecting) return;
    
    setState(() => isConnecting = true);
    terminal.write('\r\n[Bağlanılıyor ${_hostController.text}:${_portController.text}...]\r\n');

    try {
      final socket = await SSHSocket.connect(
        _hostController.text,
        int.parse(_portController.text),
        timeout: Duration(seconds: 10),
      );

      client = SSHClient(
        socket,
        username: _usernameController.text,
        onPasswordRequest: () => _passwordController.text,
      );

      await client!.authenticated;
      
      session = await client!.shell();
      
      session!.stdout.listen((data) {
        terminal.write(String.fromCharCodes(data));
      });
      
      session!.stderr.listen((data) {
        terminal.write('\x1b[31m${String.fromCharCodes(data)}\x1b[0m');
      });
      
      terminal.onOutput = (data) {
        session?.stdin.add(data.codeUnits);
      };

      setState(() {
        isConnected = true;
        isConnecting = false;
      });
      
      terminal.write('\r\n[✓ Bağlantı başarılı!]\r\n\r\n');
    } catch (e) {
      terminal.write('\r\n[✗ Hata: $e]\r\n\r\n');
      setState(() => isConnecting = false);
    }
  }

  Future<void> _disconnect() async {
    session?.close();
    client?.close();
    setState(() {
      isConnected = false;
      session = null;
      client = null;
    });
    terminal.write('\r\n[Bağlantı kesildi]\r\n\r\n');
  }

  @override
  void dispose() {
    _disconnect();
    _hostController.dispose();
    _portController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('🖥️ Ubuntu Terminal'),
        actions: [
          if (!isConnected && !isConnecting)
            IconButton(
              icon: Icon(Icons.login),
              onPressed: _showConnectionDialog,
            ),
          if (isConnected)
            IconButton(
              icon: Icon(Icons.logout, color: AppColors.danger),
              onPressed: _disconnect,
            ),
        ],
      ),
      body: Column(
        children: [
          // Status Bar
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: isConnected ? AppColors.success : AppColors.surface,
            child: Row(
              children: [
                Icon(
                  isConnected ? Icons.check_circle : Icons.cancel,
                  color: isConnected ? Colors.white : AppColors.textSecondary,
                  size: 20,
                ),
                SizedBox(width: 8),
                Text(
                  isConnected 
                    ? 'Bağlı: ${_usernameController.text}@${_hostController.text}'
                    : 'Bağlantı yok',
                  style: TextStyle(
                    color: isConnected ? Colors.white : AppColors.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          
          // Terminal
          Expanded(
            child: Container(
              color: Color(0xFF1E1E1E),
              child: TerminalView(
                terminal,
                theme: TerminalTheme(
                  foreground: Colors.white,
                  background: Color(0xFF1E1E1E),
                  cursor: Colors.green,
                  selection: Colors.blue.withOpacity(0.3),
                ),
                padding: EdgeInsets.all(16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showConnectionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('SSH Bağlantısı'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _hostController,
                decoration: InputDecoration(
                  labelText: 'Host (Tailscale IP)',
                  hintText: '100.64.0.1',
                ),
              ),
              SizedBox(height: 12),
              TextField(
                controller: _portController,
                decoration: InputDecoration(
                  labelText: 'Port',
                  hintText: '22',
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 12),
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Kullanıcı Adı',
                  hintText: 'ubuntu',
                ),
              ),
              SizedBox(height: 12),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Şifre',
                ),
                obscureText: true,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _connectSSH();
            },
            child: Text('Bağlan'),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/device_provider.dart';
import '../theme/app_theme.dart';

class ResetWifiScreen extends StatefulWidget {
  const ResetWifiScreen({super.key});
  @override
  State<ResetWifiScreen> createState() => _ResetWifiScreenState();
}

class _ResetWifiScreenState extends State<ResetWifiScreen> with SingleTickerProviderStateMixin {
  String? _selectedDeviceId;
  bool _isResetting = false;
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _resetWifi() {
    if (_selectedDeviceId == null) return;
    setState(() => _isResetting = true);
    _animController.forward().then((_) => _animController.reverse());
    context.read<DeviceProvider>().sendCommand(_selectedDeviceId!, {'reset_wifi': true});
    Future.delayed(Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() => _isResetting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Perintah reset dikirim. Perangkat akan restart.'),
          backgroundColor: AppTheme.primaryGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final devices = context.watch<DeviceProvider>().devices;

    return Scaffold(
      appBar: AppBar(
        title: Text('Reset WiFi'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Warning Icon
              AnimatedContainer(
                duration: Duration(milliseconds: 500),
                width: 100,
                height: 100,
                child: Icon(
                  Icons.warning_amber_rounded,
                  size: 80,
                  color: AppTheme.dangerRed.withValues(alpha: _isResetting ? 0.5 : 1.0),
                ),
              ),
              SizedBox(height: 24),
              Text(
                'Reset WiFi Perangkat',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              SizedBox(height: 8),
              Text(
                'Ini akan menghapus konfigurasi WiFi yang tersimpan.\n'
                'Perangkat akan kembali ke mode Access Point.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.textSecondary),
              ),
              SizedBox(height: 32),
              // Device Selector
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.cardBg,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedDeviceId,
                  decoration: InputDecoration(
                    labelText: 'Pilih Perangkat',
                    prefixIcon: Icon(Icons.sensors),
                    filled: true,
                    fillColor: AppTheme.surfaceBg,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                  dropdownColor: AppTheme.surfaceBg,
                  items: devices.map((d) => DropdownMenuItem(
                    value: d.id,
                    child: Text('Device ${d.id.substring(0, 8)}...'),
                  )).toList(),
                  onChanged: (val) => setState(() => _selectedDeviceId = val),
                ),
              ),
              SizedBox(height: 32),
              // Reset Button
              ScaleTransition(
                scale: _scaleAnimation,
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    icon: _isResetting
                        ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Icon(Icons.restart_alt),
                    label: Text(_isResetting ? 'Mereset...' : 'Reset WiFi'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.dangerRed,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    onPressed: (_selectedDeviceId != null && !_isResetting) ? _resetWifi : null,
                  ),
                ),
              ),
              SizedBox(height: 24),
              Text(
                'Setelah reset, WiFi perangkat: "PestTrap-Setup-XXXXXX"\n'
                'Kirim konfigurasi baru melalui API 192.168.4.1/save',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
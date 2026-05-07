import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/device_provider.dart';
import '../theme/app_theme.dart';

class ResetWifiScreen extends StatefulWidget {
  const ResetWifiScreen({super.key});
  @override
  State<ResetWifiScreen> createState() => _ResetWifiScreenState();
}

class _ResetWifiScreenState extends State<ResetWifiScreen>
    with SingleTickerProviderStateMixin {
  String? _selectedDeviceId;
  bool _isResetting = false;
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
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
    context.read<DeviceProvider>().sendCommand(_selectedDeviceId!, {
      'reset_wifi': true,
    });
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() => _isResetting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.check_circle_rounded, color: Colors.white),
              SizedBox(width: 12),
              Expanded(
                child: Text('Perintah reset dikirim. Perangkat akan restart.'),
              ),
            ],
          ),
          backgroundColor: AppTheme.primaryGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: const EdgeInsets.all(20),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final devices = context.watch<DeviceProvider>().devices;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: AppTheme.darkBg.withValues(alpha: 0.5)),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Reset WiFi'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            24,
            MediaQuery.of(context).padding.top + kToolbarHeight + 20,
            24,
            100,
          ),
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppTheme.cardBg,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: AppTheme.dangerRed.withValues(alpha: 0.2),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.dangerRed.withValues(alpha: 0.1),
                  blurRadius: 30,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Warning Icon
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.dangerRed.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.dangerRed.withValues(alpha: 0.3),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.warning_rounded,
                      size: 64,
                      color: AppTheme.dangerRed.withValues(
                        alpha: _isResetting ? 0.5 : 1.0,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Bahaya: Reset Jaringan',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Ini akan menghapus konfigurasi WiFi yang tersimpan. Perangkat akan terputus dari jaringan dan kembali ke mode Access Point.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 40),
                // Device Selector
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceBg,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedDeviceId,
                      hint: const Text(
                        'Pilih Perangkat...',
                        style: TextStyle(color: AppTheme.textSecondary),
                      ),
                      icon: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: AppTheme.textSecondary,
                      ),
                      isExpanded: true,
                      dropdownColor: AppTheme.surfaceBg,
                      items: devices
                          .map(
                            (d) => DropdownMenuItem(
                              value: d.id,
                              child: Text(
                                'Device ${(d.id.length >= 6 ? d.id.substring(0, 6) : d.id).toUpperCase()}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (val) =>
                          setState(() => _selectedDeviceId = val),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                // Reset Button
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.dangerRed,
                      foregroundColor: Colors.white,
                      elevation: 8,
                      shadowColor: AppTheme.dangerRed.withValues(alpha: 0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: (_selectedDeviceId != null && !_isResetting)
                        ? _resetWifi
                        : null,
                    child: _isResetting
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            ),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.restart_alt_rounded, size: 24),
                              SizedBox(width: 12),
                              Text(
                                'Reset WiFi Sekarang',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.warningOrange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.info_outline_rounded,
                        color: AppTheme.warningOrange,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Setelah reset, hubungkan ke WiFi "PestzoneSpray-Setup-XXXXXX" dan buka 192.168.4.1 untuk mengatur ulang.',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppTheme.warningOrange.withValues(
                              alpha: 0.9,
                            ),
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

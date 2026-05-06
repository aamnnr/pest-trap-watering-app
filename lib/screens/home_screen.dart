import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/device_provider.dart';
import '../theme/app_theme.dart';
import '../models/device.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DeviceProvider>();
    final devices = provider.devices;
    final onlineCount = provider.onlineCount;
    final isMqttConnected = provider.isMqttConnected;

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
        title: const Text('PestTrap Watering System'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => provider.refresh(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => provider.refresh(),
        color: AppTheme.primaryGreen,
        backgroundColor: AppTheme.cardBg,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + kToolbarHeight,
              ),
            ),
            // Header Summary Card
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    // --- KOLOM KIRI: MONITORING PERANGKAT ---
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryGreen.withValues(
                                alpha: 0.3,
                              ),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Icon(
                                    Icons.devices_other_rounded,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                                if (onlineCount > 0)
                                  const PulsingIndicator(color: Colors.white),
                              ],
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Perangkat',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$onlineCount / ${devices.length} Online',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(width: 16),

                    // --- KOLOM KANAN: MONITORING BROKER MQTT ---
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          // Anda dapat mengubah warna gradient ini jika ingin membedakannya
                          gradient: AppTheme.primaryGradient,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryGreen.withValues(
                                alpha: 0.3,
                              ),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Icon(
                                    Icons.cloud_sync_rounded,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                                // Asumsi variabel isMqttConnected bernilai boolean
                                if (isMqttConnected)
                                  const PulsingIndicator(color: Colors.white),
                              ],
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Broker MQTT',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isMqttConnected ? 'Terhubung' : 'Terputus',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Devices List Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                child: Row(
                  children: [
                    Icon(
                      Icons.widgets_rounded,
                      color: AppTheme.textSecondary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Perangkat Terhubung',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${devices.length}',
                        style: const TextStyle(
                          color: AppTheme.primaryGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Device Cards
            devices.isEmpty
                ? SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: Column(
                          children: [
                            Icon(
                              Icons.sensors_off_rounded,
                              size: 80,
                              color: AppTheme.surfaceBg,
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              'Tidak ada perangkat',
                              style: TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Nyalakan ESP32 dan hubungkan ke MQTT.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: AppTheme.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : SliverPadding(
                    padding: const EdgeInsets.only(
                      bottom: 100,
                    ), // padding for bottom nav
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final dev = devices[index];
                        return DeviceCard(device: dev);
                      }, childCount: devices.length),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

class DeviceCard extends StatelessWidget {
  final Device device;
  const DeviceCard({super.key, required this.device});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<DeviceProvider>();
    final isOnline =
        device.lastSeen != null &&
        DateTime.now().difference(device.lastSeen!).inMinutes < 5;
    final lastSeenStr = device.lastSeen != null
        ? DateFormat('HH:mm').format(device.lastSeen!)
        : '--:--';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // Glassmorphism accent glow
              Positioned(
                top: -20,
                right: -20,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        (isOnline ? AppTheme.onlineGreen : AppTheme.offlineGrey)
                            .withValues(alpha: 0.1),
                  ),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: Container(color: Colors.transparent),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Status Indicator
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isOnline
                                ? AppTheme.onlineGreen
                                : AppTheme.offlineGrey,
                            boxShadow: isOnline
                                ? [
                                    BoxShadow(
                                      color: AppTheme.onlineGreen.withValues(
                                        alpha: 0.6,
                                      ),
                                      blurRadius: 8,
                                    ),
                                  ]
                                : [],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Device ${(device.id.length >= 6 ? device.id.substring(0, 6) : device.id).toUpperCase()}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const Spacer(),
                        // Battery
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: getBatteryColor(
                              device.battery,
                            ).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                getBatteryIcon(device.battery),
                                color: getBatteryColor(device.battery),
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${device.battery}%',
                                style: TextStyle(
                                  color: getBatteryColor(device.battery),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Quick Controls
                    Row(
                      children: [
                        Expanded(
                          child: _QuickControlButton(
                            icon: Icons.lightbulb_rounded,
                            label: 'UV Light',
                            isOn: device.uvOn,
                            color: AppTheme.accentPurple,
                            onToggle: (val) => provider.sendCommand(device.id, {
                              'uv_action': val ? 'ON' : 'OFF',
                            }),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _QuickControlButton(
                            icon: Icons.water_drop_rounded,
                            label: 'Pump',
                            isOn: device.pumpOn,
                            color: AppTheme.accentBlue,
                            onToggle: (val) => provider.sendCommand(device.id, {
                              'pump_action': val ? 'ON' : 'OFF',
                            }),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Footer details
                    Row(
                      children: [
                        Icon(
                          Icons.history_rounded,
                          size: 14,
                          color: AppTheme.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Sync: $lastSeenStr',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData getBatteryIcon(int level) {
    if (level > 80) return Icons.battery_full_rounded;
    if (level > 50) return Icons.battery_5_bar_rounded;
    if (level > 20) return Icons.battery_3_bar_rounded;
    return Icons.battery_0_bar_rounded;
  }

  Color getBatteryColor(int level) {
    if (level > 50) return AppTheme.onlineGreen;
    if (level > 20) return AppTheme.warningOrange;
    return AppTheme.dangerRed;
  }
}

class _QuickControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isOn;
  final Color color;
  final ValueChanged<bool> onToggle;

  const _QuickControlButton({
    required this.icon,
    required this.label,
    required this.isOn,
    required this.color,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onToggle(!isOn),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: isOn ? color.withValues(alpha: 0.15) : AppTheme.surfaceBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isOn ? color.withValues(alpha: 0.5) : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isOn ? color : AppTheme.cardBg,
                shape: BoxShape.circle,
                boxShadow: isOn
                    ? [
                        BoxShadow(
                          color: color.withValues(alpha: 0.4),
                          blurRadius: 8,
                        ),
                      ]
                    : [],
              ),
              child: Icon(
                icon,
                color: isOn ? Colors.white : AppTheme.textSecondary,
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isOn
                          ? AppTheme.textPrimary
                          : AppTheme.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    isOn ? 'ON' : 'OFF',
                    style: TextStyle(
                      color: isOn
                          ? color
                          : AppTheme.textSecondary.withValues(alpha: 0.5),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
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

class PulsingIndicator extends StatefulWidget {
  final Color color;
  const PulsingIndicator({super.key, required this.color});

  @override
  State<PulsingIndicator> createState() => _PulsingIndicatorState();
}

class _PulsingIndicatorState extends State<PulsingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _animation = Tween<double>(
      begin: 0.4,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.color.withValues(alpha: _animation.value),
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: 0.4 * _animation.value),
                blurRadius: 12,
                spreadRadius: 4,
              ),
            ],
          ),
        );
      },
    );
  }
}

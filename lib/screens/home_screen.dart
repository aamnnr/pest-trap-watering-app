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

    return Scaffold(
      appBar: AppBar(
        title: Text('PestTrap Watering'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded),
            onPressed: () => provider.refresh(), // trigger rebuild
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            provider.refresh();
          },
          child: CustomScrollView(
            slivers: [
              // Header Summary Card
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppTheme.primaryGreen.withValues(alpha:0.3), AppTheme.primaryGreen.withValues(alpha:0.05)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.primaryGreen.withValues(alpha:0.3)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.primaryGreen.withValues(alpha:0.2),
                          ),
                          child: Icon(Icons.devices_other, color: AppTheme.primaryGreen, size: 36),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Sistem Monitor',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                              SizedBox(height: 4),
                              Text(
                                '$onlineCount dari ${devices.length} perangkat online',
                                style: TextStyle(color: Colors.white70),
                              ),
                            ],
                          ),
                        ),
                        // Pulsing indicator for online devices
                        if (onlineCount > 0)
                          PulsingIndicator(color: AppTheme.onlineGreen),
                      ],
                    ),
                  ),
                ),
              ),

              // Devices List Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    children: [
                      Icon(Icons.list_alt_rounded, color: AppTheme.textSecondary, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Daftar Perangkat',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
                      ),
                      Spacer(),
                      Text('${devices.length} perangkat', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                    ],
                  ),
                ),
              ),

              // Device Cards
              devices.isEmpty
                  ? SliverToBoxAdapter(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            children: [
                              Icon(Icons.sensors_off, size: 64, color: AppTheme.textSecondary.withValues(alpha:0.5)),
                              SizedBox(height: 16),
                              Text('Tidak ada perangkat terdeteksi', style: TextStyle(color: AppTheme.textSecondary)),
                              SizedBox(height: 8),
                              Text('Nyalakan ESP32 dan pastikan terhubung ke MQTT', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                            ],
                          ),
                        ),
                      ),
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final dev = devices[index];
                          return DeviceCard(device: dev);
                        },
                        childCount: devices.length,
                      ),
                    ),
            ],
          ),
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
    final isOnline = device.lastSeen != null &&
        DateTime.now().difference(device.lastSeen!).inMinutes < 5;
    final lastSeenStr = device.lastSeen != null
        ? DateFormat('HH:mm:ss').format(device.lastSeen!)
        : 'Belum pernah';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          // Arahkan ke tab kontrol dengan perangkat ini terpilih (opsional, biarkan user pilih sendiri)
        },
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.cardBg,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 2)),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Status Indicator
                    AnimatedContainer(
                      duration: Duration(milliseconds: 500),
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isOnline ? AppTheme.onlineGreen : AppTheme.offlineGrey,
                        boxShadow: isOnline
                            ? [BoxShadow(color: AppTheme.onlineGreen.withValues(alpha:0.6), blurRadius: 8)]
                            : [],
                      ),
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Device ${device.id.substring(0, 8)}...',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                    ),
                    Spacer(),
                    // Battery Icon + percentage
                    Row(
                      children: [
                        Icon(getBatteryIcon(device.battery), color: getBatteryColor(device.battery), size: 20),
                        SizedBox(width: 4),
                        Text('${device.battery}%', style: TextStyle(color: getBatteryColor(device.battery), fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 12),
                // Status indicators rows
                Row(
                  children: [
                    // UV Status
                    _StatusChip(
                      icon: Icons.lightbulb,
                      label: device.uvOn ? 'UV ON' : 'UV OFF',
                      isActive: device.uvOn,
                      activeColor: AppTheme.accentPurple,
                    ),
                    SizedBox(width: 12),
                    // Pump Status
                    _StatusChip(
                      icon: Icons.water_drop,
                      label: device.pumpOn ? 'Pompa ON' : 'Pompa OFF',
                      isActive: device.pumpOn,
                      activeColor: AppTheme.accentBlue,
                    ),
                    Spacer(),
                    // Last seen
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(lastSeenStr, style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                        Text('terakhir', style: TextStyle(fontSize: 10, color: AppTheme.textSecondary.withValues(alpha:0.7))),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 12),
                // Quick Controls
                Row(
                  children: [
                    Expanded(
                      child: _QuickControlButton(
                        icon: Icons.lightbulb,
                        label: 'UV',
                        isOn: device.uvOn,
                        onToggle: (val) => provider.sendCommand(device.id, {'uv_action': val ? 'ON' : 'OFF'}),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: _QuickControlButton(
                        icon: Icons.water,
                        label: 'Pompa',
                        isOn: device.pumpOn,
                        onToggle: (val) => provider.sendCommand(device.id, {'pump_action': val ? 'ON' : 'OFF'}),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData getBatteryIcon(int level) {
    if (level > 80) return Icons.battery_full;
    if (level > 50) return Icons.battery_5_bar;
    if (level > 20) return Icons.battery_3_bar;
    return Icons.battery_0_bar;
  }

  Color getBatteryColor(int level) {
    if (level > 50) return AppTheme.primaryGreen;
    if (level > 20) return Colors.orange;
    return Colors.red;
  }
}

class _StatusChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final Color activeColor;

  const _StatusChip({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? activeColor.withValues(alpha:0.2) : Colors.white10,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive ? activeColor.withValues(alpha:0.5) : Colors.white24,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: isActive ? activeColor : Colors.white54),
          SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isActive ? activeColor : Colors.white54,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isOn;
  final ValueChanged<bool> onToggle;

  const _QuickControlButton({
    required this.icon,
    required this.label,
    required this.isOn,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => onToggle(!isOn),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: isOn ? AppTheme.primaryGreen.withValues(alpha:0.2) : Colors.white10,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isOn ? AppTheme.primaryGreen : Colors.white24,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isOn ? AppTheme.primaryGreen : Colors.white54, size: 18),
            SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isOn ? AppTheme.primaryGreen : Colors.white54,
                fontSize: 13,
              ),
            ),
            SizedBox(width: 4),
            AnimatedSwitcher(
              duration: Duration(milliseconds: 200),
              child: Icon(
                isOn ? Icons.toggle_on : Icons.toggle_off,
                key: ValueKey(isOn),
                color: isOn ? AppTheme.primaryGreen : Colors.white38,
                size: 20,
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
  PulsingIndicatorState createState() => PulsingIndicatorState();
}

class PulsingIndicatorState extends State<PulsingIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.6, end: 1.0).animate(_controller);
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
            color: widget.color.withValues(alpha:_animation.value),
            boxShadow: [
              BoxShadow(color: widget.color.withValues(alpha:0.4), blurRadius: 12, spreadRadius: 2),
            ],
          ),
        );
      },
    );
  }
}
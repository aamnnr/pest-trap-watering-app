import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/device_provider.dart';
import '../models/log_entry.dart';
import '../theme/app_theme.dart';

class InfoScreen extends StatefulWidget {
  const InfoScreen({super.key});
  @override
  State<InfoScreen> createState() => _InfoScreenState();
}

class _InfoScreenState extends State<InfoScreen> {
  String? _filterDeviceId;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DeviceProvider>();
    final devices = provider.devices;

    final List<LogEntry> logs = _filterDeviceId == null
        ? provider.allLogs
        : provider.logsForDevice(_filterDeviceId!);

    // Battery chart data
    final telemetryLogs = logs
        .where((l) => l.event == 'telemetry' && l.data != null && l.data!['bat'] != null)
        .take(20)
        .toList();
    final batteryData = <FlSpot>[];
    double x = 0;
    for (final log in telemetryLogs.reversed) {
      batteryData.add(FlSpot(x, (log.data!['bat'] as num).toDouble()));
      x++;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Info & Log'),
        centerTitle: true,
        actions: [
          // Filter device
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: AppTheme.surfaceBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _filterDeviceId,
                  hint: Text('Semua', style: TextStyle(color: AppTheme.textSecondary)),
                  dropdownColor: AppTheme.surfaceBg,
                  icon: Icon(Icons.filter_list, color: AppTheme.primaryGreen),
                  items: [
                    DropdownMenuItem(value: null, child: Text('Semua', style: TextStyle(color: Colors.white))),
                    ...devices.map((d) => DropdownMenuItem(
                      value: d.id,
                      child: Text(d.id.substring(0, 8), style: TextStyle(color: Colors.white)),
                    )),
                  ],
                  onChanged: (val) => setState(() => _filterDeviceId = val),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Battery Graph
          if (batteryData.isNotEmpty)
            Container(
              margin: EdgeInsets.all(16),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.cardBg,
                borderRadius: BorderRadius.circular(16),
              ),
              height: 220,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.battery_charging_full, color: AppTheme.primaryGreen),
                      SizedBox(width: 8),
                      Text('Histori Baterai', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                    ],
                  ),
                  SizedBox(height: 12),
                  Expanded(
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: 25),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: true, reservedSize: 35, getTitlesWidget: (value, meta) {
                              return Text('${value.toInt()}%', style: TextStyle(color: AppTheme.textSecondary, fontSize: 10));
                            }),
                          ),
                          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: batteryData,
                            isCurved: true,
                            color: AppTheme.primaryGreen,
                            barWidth: 3,
                            belowBarData: BarAreaData(
                              show: true,
                              color: AppTheme.primaryGreen.withValues(alpha:0.2),
                            ),
                            dotData: FlDotData(show: false),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          // App Info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.cardBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: AppTheme.primaryGreen),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('PestTrap Watering', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                        Text('v1.0.0 | broker.hivemq.com', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                      ],
                    ),
                  ),
                  Text('${logs.length} log', style: TextStyle(color: AppTheme.textSecondary)),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),
          // Log List
          Expanded(
            child: logs.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.history, size: 48, color: Colors.white24),
                        SizedBox(height: 16),
                        Text('Belum ada log aktivitas', style: TextStyle(color: AppTheme.textSecondary)),
                      ],
                    ),
                  )
                : ListView.separated(
                    itemCount: logs.length,
                    separatorBuilder: (_, _) => Divider(indent: 72, color: Colors.white12),
                    itemBuilder: (ctx, i) {
                      final log = logs[i];
                      return ListTile(
                        leading: _LogIcon(event: log.event),
                        title: Text(log.event, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                        subtitle: Text(
                          DateFormat('dd/MM HH:mm:ss').format(log.timestamp),
                          style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                        ),
                        trailing: _buildLogTrailing(log),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogTrailing(LogEntry log) {
    if (log.data == null) return SizedBox();
    if (log.data!.containsKey('bat')) {
      return Text('${log.data!['bat']}%', style: TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold));
    }
    if (log.data!.containsKey('duration')) {
      return Text('${log.data!['duration']}s', style: TextStyle(color: AppTheme.accentBlue));
    }
    if (log.data!.containsKey('source')) {
      return Text('${log.data!['source']}', style: TextStyle(color: Colors.white70, fontSize: 11));
    }
    return SizedBox();
  }
}

class _LogIcon extends StatelessWidget {
  final String event;
  const _LogIcon({required this.event});

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;
    if (event.contains('uv')) {
      icon = Icons.lightbulb;
      color = AppTheme.accentPurple;
    } else if (event.contains('pump')) {
      icon = Icons.water_drop;
      color = AppTheme.accentBlue;
    } else if (event.contains('schedule')) {
      icon = Icons.schedule;
      color = Colors.orange;
    } else if (event.contains('telemetry')) {
      icon = Icons.info;
      color = AppTheme.primaryGreen;
    } else {
      icon = Icons.circle;
      color = Colors.grey;
    }

    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha:0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }
}
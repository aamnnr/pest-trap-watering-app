import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/device_provider.dart';
import '../models/log_entry.dart';

class LogScreen extends StatefulWidget {
  const LogScreen({super.key});
  @override
  State<LogScreen> createState() => _LogScreenState();
}

class _LogScreenState extends State<LogScreen> {
  String? _filterDeviceId;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DeviceProvider>();
    final devices = provider.devices;

    // Filter log
    final List<LogEntry> logs = _filterDeviceId == null
        ? provider.allLogs
        : provider.logsForDevice(_filterDeviceId!);

    // Data grafik baterai (20 titik terakhir)
    final batteryData = <FlSpot>[];
    final telemetryLogs = logs
        .where(
          (l) =>
              l.event == 'telemetry' &&
              l.data != null &&
              l.data!['bat'] != null,
        )
        .take(20)
        .toList(); // ubah ke list agar bisa reversed
    double x = 0;
    // Mulai dari yang terlama (reversed)
    for (final log in telemetryLogs.reversed) {
      batteryData.add(FlSpot(x, (log.data!['bat'] as num).toDouble()));
      x++;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Aktivitas'),
        actions: [
          DropdownButton<String>(
            value: _filterDeviceId,
            hint: const Text('Semua'),
            underline: const SizedBox(),
            items: [
              const DropdownMenuItem(value: null, child: Text('Semua')),
              ...devices.map(
                (d) => DropdownMenuItem(
                  value: d.id,
                  child: Text(d.id.substring(0, 8)),
                ),
              ),
            ],
            onChanged: (val) => setState(() => _filterDeviceId = val),
          ),
        ],
      ),
      body: Column(
        children: [
          if (batteryData.isNotEmpty)
            Container(
              height: 200,
              padding: const EdgeInsets.all(16),
              child: LineChart(
                LineChartData(
                  lineBarsData: [
                    LineChartBarData(
                      spots: batteryData,
                      isCurved: true,
                      color: Colors.green,
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.green.withValues(
                          alpha: 0.3,
                        ), // ganti withOpacity
                      ),
                    ),
                  ],
                  titlesData: const FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 32,
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: const FlGridData(show: true),
                ),
              ),
            ),
          Expanded(
            child: logs.isEmpty
                ? const Center(child: Text('Belum ada log'))
                : ListView.builder(
                    itemCount: logs.length,
                    itemBuilder: (ctx, i) {
                      final log = logs[i];
                      String title = log.event;
                      String subtitle = DateFormat(
                        'dd/MM HH:mm:ss',
                      ).format(log.timestamp);
                      if (log.data != null) {
                        if (log.data!.containsKey('bat'))
                          subtitle += ' | Bat: ${log.data!['bat']}%';
                        if (log.data!.containsKey('duration'))
                          subtitle += ' | Durasi: ${log.data!['duration']}s';
                        if (log.data!.containsKey('source'))
                          subtitle += ' | Sumber: ${log.data!['source']}';
                      }

                      return ListTile(
                        dense: true,
                        leading: CircleAvatar(
                          backgroundColor: _eventColor(log.event),
                          child: Icon(
                            _eventIcon(log.event),
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                        title: Text(title),
                        subtitle: Text(subtitle),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Color _eventColor(String event) {
    switch (event) {
      case 'uv_on':
        return Colors.purple;
      case 'uv_off':
        return Colors.grey;
      case 'pump_on':
        return Colors.blue;
      case 'pump_off':
        return Colors.grey;
      case 'telemetry':
        return Colors.green;
      default:
        return Colors.orange;
    }
  }

  IconData _eventIcon(String event) {
    if (event.contains('uv')) return Icons.lightbulb;
    if (event.contains('pump')) return Icons.water;
    if (event.contains('schedule')) return Icons.schedule;
    return Icons.info;
  }
}

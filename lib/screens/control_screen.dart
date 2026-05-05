import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/device_provider.dart';
import '../theme/app_theme.dart';

class ControlScreen extends StatefulWidget {
  const ControlScreen({super.key});

  @override
  State<ControlScreen> createState() => _ControlScreenState();
}

class _ControlScreenState extends State<ControlScreen> {
  String? _selectedDeviceId;
  final _uvStartController = TextEditingController();
  final _uvStopController = TextEditingController();
  final _pumpHourController = TextEditingController();
  final _pumpMinuteController = TextEditingController();
  final _pumpDurationController = TextEditingController();
  final _manualPumpDurationController = TextEditingController(text: '10');

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DeviceProvider>();
    final devices = provider.devices;
    final device = _selectedDeviceId != null ? provider.getDevice(_selectedDeviceId!) : null;

    return Scaffold(
      appBar: AppBar(
        title: Text('Kontrol & Penjadwalan'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Device Selector
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.devices, color: AppTheme.primaryGreen),
                      SizedBox(width: 8),
                      Text('Pilih Perangkat', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                  SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedDeviceId,
                    decoration: InputDecoration(
                      hintText: 'Pilih perangkat...',
                      filled: true,
                      fillColor: AppTheme.surfaceBg,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      prefixIcon: Icon(Icons.sensors),
                    ),
                    dropdownColor: AppTheme.surfaceBg,
                    items: devices.map((d) => DropdownMenuItem(
                      value: d.id,
                      child: Text('Device ${d.id.substring(0, 8)}...'),
                    )).toList(),
                    onChanged: (val) => setState(() => _selectedDeviceId = val),
                  ),
                ],
              ),
            ),
            if (device != null) ...[
              SizedBox(height: 20),
              // Status Bar
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.cardBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatusItem(icon: Icons.lightbulb, label: 'UV', isOn: device.uvOn, color: AppTheme.accentPurple),
                    _StatusItem(icon: Icons.water_drop, label: 'Pompa', isOn: device.pumpOn, color: AppTheme.accentBlue),
                    _StatusItem(icon: Icons.battery_std, label: 'Baterai', value: '${device.battery}%', color: Colors.orange),
                  ],
                ),
              ),
              SizedBox(height: 20),

              // Section: Kontrol Manual
              Text('Kontrol Manual', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _ControlButton(
                      icon: Icons.lightbulb,
                      label: 'UV',
                      isOn: device.uvOn,
                      onToggle: (val) => provider.sendCommand(device.id, {'uv_action': val ? 'ON' : 'OFF'}),
                      color: AppTheme.accentPurple,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _ControlButton(
                      icon: Icons.water,
                      label: 'Pompa',
                      isOn: device.pumpOn,
                      onToggle: (val) => provider.sendCommand(device.id, {'pump_action': val ? 'ON' : 'OFF'}),
                      color: AppTheme.accentBlue,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _manualPumpDurationController,
                      keyboardType: TextInputType.number,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Durasi Manual (detik)',
                        suffixIcon: Icon(Icons.timer, color: AppTheme.textSecondary),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  ElevatedButton.icon(
                    icon: Icon(Icons.play_arrow),
                    label: Text('Jalankan'),
                    onPressed: () {
                      int dur = int.tryParse(_manualPumpDurationController.text) ?? 10;
                      provider.sendCommand(device.id, {'pump_action': 'ON', 'duration_sec': dur});
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentBlue,
                      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24),

              // Section: Penjadwalan
              Text('Penjadwalan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 12),

              // UV Schedule Card
              _ScheduleCard(
                icon: Icons.lightbulb,
                title: 'Jadwal UV',
                color: AppTheme.accentPurple,
                children: [
                  Row(
                    children: [
                      Expanded(child: _buildTextField('Jam Mulai', _uvStartController)),
                      SizedBox(width: 12),
                      Expanded(child: _buildTextField('Jam Selesai', _uvStopController)),
                    ],
                  ),
                  SizedBox(height: 12),
                  ElevatedButton.icon(
                    icon: Icon(Icons.save),
                    label: Text('Simpan Jadwal UV'),
                    onPressed: () {
                      int start = int.tryParse(_uvStartController.text) ?? 18;
                      int stop = int.tryParse(_uvStopController.text) ?? 23;
                      provider.sendCommand(device.id, {'uv_start': start, 'uv_stop': stop});
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentPurple),
                  ),
                ],
              ),
              SizedBox(height: 16),

              // Pump Schedule Card
              _ScheduleCard(
                icon: Icons.water,
                title: 'Jadwal Penyiraman',
                color: AppTheme.accentBlue,
                children: [
                  Row(
                    children: [
                      Expanded(child: _buildTextField('Jam', _pumpHourController)),
                      SizedBox(width: 8),
                      Expanded(child: _buildTextField('Menit', _pumpMinuteController)),
                      SizedBox(width: 8),
                      Expanded(child: _buildTextField('Durasi (s)', _pumpDurationController)),
                    ],
                  ),
                  SizedBox(height: 12),
                  ElevatedButton.icon(
                    icon: Icon(Icons.save),
                    label: Text('Simpan Jadwal'),
                    onPressed: () {
                      int h = int.tryParse(_pumpHourController.text) ?? 6;
                      int m = int.tryParse(_pumpMinuteController.text) ?? 0;
                      int d = int.tryParse(_pumpDurationController.text) ?? 15;
                      provider.sendCommand(device.id, {
                        'pump_schedule': {'hour': h, 'minute': m, 'duration_sec': d}
                      });
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentBlue),
                  ),
                ],
              ),
            ] else if (devices.isEmpty)
              Padding(
                padding: const EdgeInsets.all(32),
                child: Column(children: [
                  Icon(Icons.sensors_off, size: 64, color: Colors.white24),
                  SizedBox(height: 16),
                  Text('Tidak ada perangkat', style: TextStyle(color: AppTheme.textSecondary)),
                ]),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    );
  }
}

class _StatusItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool? isOn;
  final String? value;
  final Color color;

  const _StatusItem({
    required this.icon,
    required this.label,
    this.isOn,
    this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: isOn != null ? (isOn! ? color : Colors.white38) : color),
        SizedBox(height: 4),
        Text(
          value ?? (isOn != null ? (isOn! ? 'ON' : 'OFF') : ''),
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        Text(label, style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
      ],
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isOn;
  final ValueChanged<bool> onToggle;
  final Color color;

  const _ControlButton({
    required this.icon,
    required this.label,
    required this.isOn,
    required this.onToggle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => onToggle(!isOn),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isOn ? color.withValues(alpha:0.2) : AppTheme.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isOn ? color : Colors.white10, width: 2),
          boxShadow: isOn ? [BoxShadow(color: color.withValues(alpha:0.3), blurRadius: 12)] : [],
        ),
        child: Column(
          children: [
            Icon(icon, size: 40, color: isOn ? color : Colors.white38),
            SizedBox(height: 8),
            Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            SizedBox(height: 4),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              decoration: BoxDecoration(
                color: isOn ? color : Colors.white10,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                isOn ? 'ON' : 'OFF',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final List<Widget> children;

  const _ScheduleCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha:0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color),
              SizedBox(width: 8),
              Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
            ],
          ),
          SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}
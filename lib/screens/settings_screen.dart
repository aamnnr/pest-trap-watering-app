import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/device_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<DeviceProvider>();
    final devices = provider.devices;

    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan & Info')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('Aplikasi PestTrap Watering'),
            subtitle: Text('Versi 1.0.0'),
          ),
          const Divider(),
          const ListTile(
            leading: Icon(Icons.cloud),
            title: Text('Broker MQTT'),
            subtitle: Text('broker.hivemq.com:1883'),
          ),
          const Divider(),
          const Text('Perangkat yang Terdeteksi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ...devices.map((d) => ListTile(
                title: Text(d.id),
                subtitle: Text('Baterai: ${d.battery}% | UV: ${d.uvOn} | Pompa: ${d.pumpOn}'),
              )),
          if (devices.isEmpty) const ListTile(title: Text('Tidak ada perangkat')),
        ],
      ),
    );
  }
}
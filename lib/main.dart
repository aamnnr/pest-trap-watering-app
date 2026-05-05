import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/mqtt_service.dart';
import 'providers/device_provider.dart';
import 'screens/home_screen.dart';
import 'screens/control_screen.dart';
import 'screens/reset_wifi_screen.dart';
import 'screens/info_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final mqttService = MqttService();
  mqttService.connect();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DeviceProvider(mqttService)),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PestTrap Watering',
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.green,
      ),
      home: const MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const ControlScreen(),
    const ResetWifiScreen(),
    const InfoScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed, // agar lebih dari 3 item terlihat
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.control_camera), label: 'Kontrol'),
          BottomNavigationBarItem(icon: Icon(Icons.wifi_off), label: 'Reset WiFi'),
          BottomNavigationBarItem(icon: Icon(Icons.info), label: 'Info'),
        ],
      ),
    );
  }
}
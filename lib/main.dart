import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'pages/manual_page.dart';
import 'pages/autonomous_page.dart';
import 'pages/settings_page.dart';


void main() {
  runApp(const VisionSandboxApp());
}

class VisionSandboxApp extends StatelessWidget {
  const VisionSandboxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rover Control',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.teal,
        useMaterial3: true,
      ),
      home: const RootNav(),
    );
  }
}

class RootNav extends StatefulWidget {
  const RootNav({super.key});

  @override
  State<RootNav> createState() => _RootNavState();
}

class _RootNavState extends State<RootNav> {
  int _index = 0;

  static const List<Widget> _pages = [
    HomePage(),
    ManualControlPage(),
    AutonomousControlPage(),
    SettingsPage(),
  ];

  static const List<String> _titles = [
    '',
    'Manual Control',
    'Autonomous Mounting Control',
    'Settings',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _index == 0
      ? null
      : AppBar(title: Text(_titles[_index])),
      // IndexedStack keeps each page's state alive when switching tabs.
      body: IndexedStack(
        index: _index,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.gamepad_outlined),
            selectedIcon: Icon(Icons.gamepad),
            label: 'Manual',
          ),
          NavigationDestination(
            icon: Icon(Icons.front_hand_outlined),
            selectedIcon: Icon(Icons.front_hand),
            label: 'Autonomous',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

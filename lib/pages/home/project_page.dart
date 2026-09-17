import 'package:flutter/material.dart';
import '../../widgets/spec_tile.dart';

class ProjectPage extends StatelessWidget {
  const ProjectPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Center(
          child: CircleAvatar(
            radius: 64,
            backgroundImage: AssetImage('assets/images/parker_the_rover.png'),
          ),
        ),
        const SizedBox(height: 12),
        const Center(
          child: Text(
            'Rover Parker',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ),
        const Center(
          child: Text(
            'Gesture-Controlled Exploration Rover',
            style: TextStyle(color: Colors.grey),
          ),
        ),
        const SizedBox(height: 24),
        Card(
          child: Column(
            children: const [
              SpecTile(icon: Icons.memory, label: 'Controller', value: 'ESP32-S3 & Smartphone'),
              Divider(height: 1),
              SpecTile(icon: Icons.blur_on, label: 'Sensors', value: 'ToF VL53L5X, HC-SR04, IMU MPU6050'),
              Divider(height: 1),
              SpecTile(icon: Icons.camera_alt, label: 'Camera', value: 'Onboard, CameraX'),
              Divider(height: 1),
              SpecTile(
                icon: Icons.front_hand,
                label: 'Gesture Engine',
                value: 'MediaPipe Gesture Recognizer',
              ),
              Divider(height: 1),
              SpecTile(icon: Icons.wifi, label: 'Link', value: 'Wi-Fi'),
              Divider(height: 1),
              SpecTile(icon: Icons.battery_full, label: 'Power', value: '3000mAh Li-ion'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Card(
          color: Theme.of(context).colorScheme.secondaryContainer,
          child: const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Use the Manual tab to drive over Wi-Fi, or the Autonomous tab to '
              'let the rover follow hand gestures from its onboard camera.',
            ),
          ),
        ),
      ],
    );
  }
}

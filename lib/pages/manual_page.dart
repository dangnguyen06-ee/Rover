import 'package:flutter/material.dart';


/// Manual driving screen — layout only. The D-pad buttons and IP field
/// aren't hooked up to any Wi-Fi command channel yet.
class ManualControlPage extends StatefulWidget {
  const ManualControlPage({super.key});

  @override
  State<ManualControlPage> createState() => _ManualControlPageState();
}

class _ManualControlPageState extends State<ManualControlPage> {
  final _ipController = TextEditingController(text: '192.168.4.1');

  @override
  void dispose() {
    _ipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: _ipController,
            decoration: const InputDecoration(
              labelText: 'Rover IP Address',
              prefixIcon: Icon(Icons.wifi),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          const Align(
            alignment: Alignment.centerLeft,
            child: Chip(
              avatar: Icon(Icons.circle, size: 12, color: Colors.grey),
              label: Text('Not connected'),
            ),
          ),
          const Spacer(),
          const _DPad(),
          const Spacer(),
          const Text(
            "Wi-Fi driving isn't wired up yet — this is layout only.",
            style: TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _DPad extends StatelessWidget {
  const _DPad();

  @override
  Widget build(BuildContext context) {
    Widget dirButton(IconData icon) => SizedBox(
          width: 72,
          height: 72,
          child: FilledButton.tonal(
            onPressed: () {},
            style: FilledButton.styleFrom(shape: const CircleBorder()),
            child: Icon(icon, size: 32),
          ),
        );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        dirButton(Icons.keyboard_arrow_up),
        const SizedBox(height: 8),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            dirButton(Icons.keyboard_arrow_left),
            const SizedBox(
              width: 72,
              child: Icon(Icons.stop_circle_outlined, size: 32),
            ),
            dirButton(Icons.keyboard_arrow_right),
          ],
        ),
        const SizedBox(height: 8),
        dirButton(Icons.keyboard_arrow_down),
      ],
    );
  }
}

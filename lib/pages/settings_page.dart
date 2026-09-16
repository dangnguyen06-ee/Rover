import 'package:flutter/material.dart';

/// Camera resolution / fps settings. State is local only right now — nothing
/// here is plumbed through to the native camera yet.
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _resolution = '1280x720';
  int _fps = 30;

  static const _resolutions = ['640x480', '1280x720', '1920x1080'];
  static const _fpsOptions = [15, 24, 30, 60];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Camera', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.aspect_ratio),
                title: const Text('Resolution'),
                trailing: DropdownButton<String>(
                  value: _resolution,
                  items: _resolutions
                      .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                      .toList(),
                  onChanged: (v) => setState(() => _resolution = v ?? _resolution),
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.speed),
                title: const Text('Frame Rate'),
                trailing: DropdownButton<int>(
                  value: _fps,
                  items: _fpsOptions
                      .map((f) => DropdownMenuItem(value: f, child: Text('$f fps')))
                      .toList(),
                  onChanged: (v) => setState(() => _fps = v ?? _fps),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Saved: $_resolution @ $_fps fps (not wired up yet)')),
            );
          },
          icon: const Icon(Icons.save),
          label: const Text('Save'),
        ),
      ],
    );
  }
}

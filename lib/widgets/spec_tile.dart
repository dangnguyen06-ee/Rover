import 'package:flutter/material.dart';

class SpecTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const SpecTile({
    super.key,
    required this.icon, required this.label, required this.value});

@override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      trailing: Text(value, style: const TextStyle(color: Colors.grey)),
    );
  }
}
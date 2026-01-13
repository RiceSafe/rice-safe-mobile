import 'package:flutter/material.dart';
import 'package:ricesafe_app/main.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ตั้งค่า'), centerTitle: true),
      body: const Center(
        child: Text(
          'Settings & Profile (Coming Soon)',
          style: TextStyle(color: riceSafeTextPrimary),
        ),
      ),
    );
  }
}

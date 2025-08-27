import 'package:flutter/material.dart';

class OfflineHistoryScreen extends StatelessWidget {
  const OfflineHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat (Offline)'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.construction, size: 64, color: Colors.orange),
            SizedBox(height: 16),
            Text('Fitur ini sedang dalam pengembangan'),
            SizedBox(height: 8),
            Text('Akan segera tersedia di versi berikutnya'),
          ],
        ),
      ),
    );
  }
}
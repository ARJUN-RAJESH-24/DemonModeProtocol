import 'package:flutter/material.dart';

class DailyLogScreen extends StatelessWidget {
  const DailyLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Log'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text("Log Your Day:", style: TextStyle(fontSize: 20)),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: () {}, child: const Text("📍 Log Meals")),
            ElevatedButton(onPressed: () {}, child: const Text("💧 Log Water")),
            ElevatedButton(onPressed: () {}, child: const Text("🏋️ Log Workout")),
            ElevatedButton(onPressed: () {}, child: const Text("📸 Body Check")),
          ],
        ),
      ),
    );
  }
}

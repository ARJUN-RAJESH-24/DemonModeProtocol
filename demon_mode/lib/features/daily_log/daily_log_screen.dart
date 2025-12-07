import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_pallete.dart';
import 'daily_log_view_model.dart';
import 'widgets/glass_action_card.dart'; // We'll create this widget for glassmorphism

class DailyLogScreen extends StatefulWidget {
  const DailyLogScreen({super.key});

  @override
  State<DailyLogScreen> createState() => _DailyLogScreenState();
}

class _DailyLogScreenState extends State<DailyLogScreen> {
  @override
  void initState() {
    super.initState();
    // Load log on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DailyLogViewModel>().loadLogForToday();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DailyLogViewModel>();
    final log = vm.currentLog;

    if (vm.isLoading || log == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Transformation'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () {}, // Future: Pick date
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Today's Progress",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),
            
            // Water Section
            _buildSectionHeader("Hydration"),
            GlassActionCard(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("${log.waterIntake} ml", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      const Text("Target: 3000 ml", style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(onPressed: () { HapticFeedback.selectionClick(); vm.updateWater(-250); }, icon: const Icon(Icons.remove_circle_outline)),
                      IconButton(onPressed: () { HapticFeedback.selectionClick(); vm.updateWater(250); }, icon: const Icon(Icons.add_circle, color: AppPallete.primaryColor, size: 32)),
                    ],
                  )
                ],
              ),
            ),
            
            const SizedBox(height: 20),

            // Workout Section
            _buildSectionHeader("Training"),
            GlassActionCard(
              child: SwitchListTile(
                title: const Text("Workout Completed?", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                subtitle: const Text("Mark if you trained today"),
                value: log.workoutDone,
                activeThumbColor: AppPallete.primaryColor,
                onChanged: (_) { HapticFeedback.mediumImpact(); vm.toggleWorkout(); },
              ),
            ),

             const SizedBox(height: 20),

            // Change Tracker Section
            _buildSectionHeader("Body Check"),
            GlassActionCard(
              child: Column(
                children: [
                  if (log.photoPaths.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Text("No photos today. Capture your form!"),
                    )
                  else
                    SizedBox(
                      height: 120,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: log.photoPaths.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(File(log.photoPaths[index]), height: 120, width: 90, fit: BoxFit.cover),
                            ),
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: vm.addPhoto,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text("Take Photo"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: AppPallete.secondaryColor,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

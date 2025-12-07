// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_pallete.dart';
import 'workout_view_model.dart';
import '../daily_log/widgets/glass_action_card.dart';

class WorkoutScreen extends StatelessWidget {
  const WorkoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _WorkoutBody();
  }
}

class _WorkoutBody extends StatelessWidget {
  const _WorkoutBody();

  String _formatTime(int seconds) {
    final m = (seconds / 60).floor().toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return "$m:$s";
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12, letterSpacing: 1.5)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<WorkoutViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('DEMON MODE // TRAIN')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Spacer(),
            
            // Timer Display
            GestureDetector(
              onTap: vm.toggleWorkout,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: vm.isWorkingOut ? AppPallete.primaryColor : Colors.grey,
                    width: 4,
                  ),
                  boxShadow: [
                    if (vm.isWorkingOut)
                      BoxShadow(color: AppPallete.primaryColor.withOpacity(0.5), blurRadius: 30)
                  ],
                ),
                alignment: Alignment.center,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formatTime(vm.seconds),
                      style: const TextStyle(fontSize: 64, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                    ),
                    Text(
                      vm.isWorkingOut ? "PAUSE" : "START",
                      style: const TextStyle(letterSpacing: 2, fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // GPS Stats
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem("DISTANCE", "${vm.totalDistance.toStringAsFixed(2)} km"),
                _buildStatItem("PACE", "${vm.currentPace} min/km"),
              ],
            ),
            
            const Spacer(),
            
            // Spotify Controls
            GlassActionCard(
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.music_note, color: AppPallete.primaryColor),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          vm.currentTrack,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(onPressed: vm.connectSpotify, icon: const Icon(Icons.link)),
                      IconButton(onPressed: vm.skipPrevious, icon: const Icon(Icons.skip_previous)),
                      IconButton(
                        onPressed: vm.isPaused ? vm.play : vm.pause,
                        icon: Icon(vm.isPaused ? Icons.play_circle_fill : Icons.pause_circle_filled, size: 48, color: AppPallete.primaryColor),
                      ),
                      IconButton(onPressed: vm.skipNext, icon: const Icon(Icons.skip_next)),
                    ],
                  )
                ],
              ),
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

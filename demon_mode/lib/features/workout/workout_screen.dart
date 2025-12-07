// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_pallete.dart';
import 'workout_view_model.dart';
import '../daily_log/widgets/glass_action_card.dart';
import '../../data/models/workout_model.dart';

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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddSetDialog(context, vm),
        backgroundColor: AppPallete.primaryColor,
        child: const Icon(Icons.add, color: Colors.black),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          const SizedBox(height: 20),
          
          // Timer Display
          GestureDetector(
            onTap: vm.toggleWorkout,
            child: Center(
              child: Container(
                width: 250,
                height: 250,
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
                      style: const TextStyle(fontSize: 54, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                    ),
                    Text(
                      vm.isWorkingOut ? "PAUSE" : "START",
                      style: const TextStyle(letterSpacing: 2, fontWeight: FontWeight.bold),
                    )
                  ],
                ),
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
          
          const SizedBox(height: 30),
          
          // SESSION LOG
          if (vm.exercises.isNotEmpty) ...[
            const Text("SESSION LOG", style: TextStyle(color: AppPallete.primaryColor, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            const SizedBox(height: 10),
            ...vm.exercises.map((exercise) => GlassActionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(exercise.name.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const Divider(color: Colors.white24),
                  ...exercise.sets.asMap().entries.map((entry) {
                    final setIndex = entry.key + 1;
                    final s = entry.value;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("SET $setIndex", style: const TextStyle(color: Colors.grey)),
                          Text("${s.weight}kg x ${s.reps}", style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            )),
            const SizedBox(height: 30),
          ],
          
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
          
          const SizedBox(height: 80), // Space for FAB
        ],
      ),
    );
  }

  void _showAddSetDialog(BuildContext context, WorkoutViewModel vm) {
    final nameController = TextEditingController();
    final repsController = TextEditingController();
    final weightController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("LOG SET"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: "Exercise Name (e.g. Bench)")),
            Row(
              children: [
                Expanded(child: TextField(controller: repsController, decoration: const InputDecoration(labelText: "Reps"), keyboardType: TextInputType.number)),
                const SizedBox(width: 10),
                Expanded(child: TextField(controller: weightController, decoration: const InputDecoration(labelText: "Weight (kg)"), keyboardType: TextInputType.number)),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("CANCEL")),
          TextButton(
            onPressed: () {
              if (nameController.text.isNotEmpty && repsController.text.isNotEmpty) {
                 vm.logSet(
                   nameController.text.toUpperCase(), 
                   int.tryParse(repsController.text) ?? 0, 
                   double.tryParse(weightController.text) ?? 0.0
                 );
                 Navigator.pop(ctx);
              }
            },
            child: const Text("SAVE"),
          ),
        ],
      ),
    );
  }
}

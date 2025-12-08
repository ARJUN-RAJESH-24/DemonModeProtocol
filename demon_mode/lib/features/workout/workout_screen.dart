// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_pallete.dart';
import 'workout_view_model.dart';
import '../daily_log/widgets/glass_action_card.dart';
import '../../data/models/workout_model.dart';
import '../devices/devices_screen.dart';

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
    final h = (seconds / 3600).floor().toString().padLeft(2, '0');
    final m = ((seconds % 3600) / 60).floor().toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return h == "00" ? "$m:$s" : "$h:$m:$s";
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<WorkoutViewModel>();
    // Simple Calorie Estimate: 5 kcal/min for now
    final calories = (vm.seconds / 60 * 5).toInt();
    // Demon Points: 1 pt per 10 mins
    final demonPts = (vm.seconds / 600).toInt();

    return Scaffold(
      appBar: AppBar(
        title: const Text('DEMON MODE // TRAIN'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.bluetooth_audio),
            onPressed: () {
               ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Checking Bluetooth State...")));
               Navigator.push(context, MaterialPageRoute(builder: (_) => const DevicesScreen()));
            },
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddSetDialog(context, vm),
        backgroundColor: AppPallete.primaryColor,
        child: const Icon(Icons.add, color: Colors.black),
      ),
      body: Column(
        children: [
           // Top Area: Timer & Main Stat
           Expanded(
             flex: 2,
             child: Container(
               alignment: Alignment.center,
               child: Column(
                 mainAxisAlignment: MainAxisAlignment.center,
                 children: [
                    Text(
                      _formatTime(vm.seconds),
                      style: const TextStyle(fontSize: 80, fontWeight: FontWeight.bold, fontFamily: 'monospace', letterSpacing: -2),
                    ),
                    const Text("DURATION", style: TextStyle(color: Colors.grey, letterSpacing: 2)),
                 ],
               ),
             ),
           ),

           // Stats Grid (Google Fit Style)
           Expanded(
             flex: 3,
             child: Container(
               padding: const EdgeInsets.symmetric(horizontal: 20),
               child: GridView.count(
                 crossAxisCount: 2,
                 childAspectRatio: 1.5,
                 crossAxisSpacing: 15,
                 mainAxisSpacing: 15,
                 children: [
                   _MetricCard(label: "DISTANCE", value: "${vm.totalDistance.toStringAsFixed(2)}", unit: "km", icon: Icons.map),
                   _MetricCard(label: "ENERGY", value: "$calories", unit: "kcal", icon: Icons.local_fire_department),
                   _MetricCard(label: "PACE", value: vm.currentPace, unit: "min/km", icon: Icons.speed),
                   _MetricCard(label: "DEMON PTS", value: "$demonPts", unit: "pts", icon: Icons.bolt),
                 ],
               ),
             ),
           ),

           // Logs & Controls
           Expanded(
             flex: 3,
             child: Container(
               padding: const EdgeInsets.all(20),
               decoration: const BoxDecoration(
                 color: AppPallete.surfaceColor,
                 borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
               ),
               child: Column(
                 children: [
                   // Set Logs Preview (Last 2)
                   if (vm.exercises.isNotEmpty)
                     Expanded(
                       child: ListView(
                         children: vm.exercises.map((e) => ListTile(
                           title: Text(e.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                           subtitle: Text("${e.sets.length} Sets Completed"),
                           trailing: Text("${e.sets.last.weight}kg x ${e.sets.last.reps}"),
                         )).toList(),
                       ),
                     )
                   else 
                     const Expanded(child: Center(child: Text("NO SETS LOGGED", style: TextStyle(color: Colors.grey)))),

                   // Controls
                   const SizedBox(height: 10),
                   Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _ControlButton(
                          icon: Icons.stop, 
                          label: "STOP", 
                          color: Colors.red[900]!, 
                          onTap: vm.toggleWorkout // Handles stop logic if paused? No, toggle pauses. We need Stop.
                          // VM has _stopWorkout. Exposed? 
                          // toggleWorkout call: if workingOut -> _stopWorkout(). No, it toggles _isWorkingOut and cancels timer.
                          // Wait, looking at VM: toggleWorkout() -> if _isWorkingOut -> _stopWorkout().
                          // Correct.
                        ),
                        // Play/Pause
                        GestureDetector(
                          onTap: vm.toggleWorkout,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: AppPallete.primaryColor,
                              shape: BoxShape.circle,
                              boxShadow: const [BoxShadow(color: AppPallete.primaryColor, blurRadius: 20, spreadRadius: -5)]
                            ),
                            child: Icon(
                              vm.isWorkingOut ? Icons.pause : Icons.play_arrow, 
                              size: 40, 
                              color: Colors.black
                            ),
                          ),
                        ),
                         _ControlButton(
                          icon: Icons.music_note, 
                          label: "MUSIC", 
                          color: Colors.blueGrey, 
                          onTap: vm.connectSpotify
                        ),
                      ],
                   )
                 ],
               ),
             ),
           )
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

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final IconData icon;

  const _MetricCard({required this.label, required this.value, required this.unit, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: AppPallete.primaryColor),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              Text("$unit $label", style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
            ],
          )
        ],
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ControlButton({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(radius: 24, backgroundColor: color.withOpacity(0.2), child: Icon(icon, color: color)),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold))
        ],
      ),
    );
  }
}

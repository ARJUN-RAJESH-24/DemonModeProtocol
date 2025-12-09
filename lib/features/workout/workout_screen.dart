// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_pallete.dart';
import 'workout_view_model.dart';
import '../daily_log/widgets/glass_action_card.dart';
import '../../data/models/workout_model.dart';
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
    final h = (seconds / 3600).floor().toString().padLeft(2, '0');
    final m = ((seconds % 3600) / 60).floor().toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return h == "00" ? "$m:$s" : "$h:$m:$s";
  }

  @override
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<WorkoutViewModel>();
    final calories = (vm.seconds / 60 * 5).toInt();
    final demonPts = (vm.seconds / 600).toInt();
    final secProgress = (vm.seconds % 60) / 60.0;
    
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text('DEMON MODE // TRAIN'),
        centerTitle: true,
      ),
      floatingActionButton: vm.isWorkingOut ? FloatingActionButton(
        onPressed: () => _showAddSetDialog(context, vm),
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add, color: Colors.black),
      ) : null,
      body: SafeArea(
        child: Column(
          children: [
            // 1. TIMER SECTION (Top 35%)
            SizedBox(
              height: size.height * 0.28,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Base Ring
                  SizedBox(
                    width: 220,
                    height: 220,
                    child: CircularProgressIndicator(
                      value: 1.0,
                      strokeWidth: 15,
                      color: AppPallete.surfaceColor,
                    ),
                  ),
                  // Active Ring
                  SizedBox(
                    width: 220,
                    height: 220,
                    child: CircularProgressIndicator(
                      value: secProgress,
                      strokeWidth: 15,
                      color: vm.isWorkingOut ? Theme.of(context).primaryColor : Colors.grey,
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _formatTime(vm.seconds),
                        style: const TextStyle(fontSize: 50, fontWeight: FontWeight.bold, fontFamily: 'monospace', letterSpacing: -2),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        vm.isWorkingOut ? "ACTIVE" : "READY",
                        style: TextStyle(
                            color: vm.isWorkingOut ? Theme.of(context).primaryColor : Colors.grey, 
                            letterSpacing: 4, 
                            fontWeight: FontWeight.bold
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),

            // 2. MODE TOGGLE & METRICS
            Container(
               margin: const EdgeInsets.symmetric(horizontal: 20),
               padding: const EdgeInsets.all(4),
               decoration: BoxDecoration(
                 color: Colors.black45,
                 borderRadius: BorderRadius.circular(30),
                 border: Border.all(color: Colors.white10)
               ),
               child: Row(
                 children: [
                   Expanded(
                     child: GestureDetector(
                       onTap: () => vm.setWorkoutType('Gym'),
                       child: Container(
                         padding: const EdgeInsets.symmetric(vertical: 10),
                         decoration: BoxDecoration(
                           color: vm.isGymMode ? Theme.of(context).primaryColor : Colors.transparent,
                           borderRadius: BorderRadius.circular(25)
                         ),
                         alignment: Alignment.center,
                         child: Text("GYM / LIFTS", style: TextStyle(fontWeight: FontWeight.bold, color: vm.isGymMode ? Colors.black : Colors.grey)),
                       ),
                     ),
                   ),
                   Expanded(
                     child: GestureDetector(
                       onTap: () => vm.setWorkoutType('Run'),
                       child: Container(
                         padding: const EdgeInsets.symmetric(vertical: 10),
                         decoration: BoxDecoration(
                           color: !vm.isGymMode ? Theme.of(context).primaryColor : Colors.transparent,
                           borderRadius: BorderRadius.circular(25)
                         ),
                         alignment: Alignment.center,
                         child: Text("CARDIO / RUN", style: TextStyle(fontWeight: FontWeight.bold, color: !vm.isGymMode ? Colors.black : Colors.grey)),
                       ),
                     ),
                   ),
                 ],
               ),
            ),
            
            const SizedBox(height: 15),

            if (!vm.isGymMode)
            SizedBox(
              height: 100,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _MetricChip("DISTANCE", "${vm.totalDistance.toStringAsFixed(2)} km", Icons.map),
                  const SizedBox(width: 10),
                  _MetricChip("ENERGY", "$calories kcal", Icons.local_fire_department),
                  const SizedBox(width: 10),
                  _MetricChip("PACE", vm.currentPace, Icons.speed),
                  const SizedBox(width: 10),
                  _MetricChip("POINTS", "$demonPts", Icons.bolt),
                ],
              ),
            ),
             
            if (vm.isGymMode)
               Container(
                 margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                 padding: const EdgeInsets.all(16),
                 decoration: BoxDecoration(
                   color: AppPallete.surfaceColor,
                   borderRadius: BorderRadius.circular(16)
                 ),
                 child: Row(
                   mainAxisAlignment: MainAxisAlignment.spaceAround,
                   children: [
                      Column(
                        children: [
                          const Text("SETS", style: TextStyle(color: Colors.grey, fontSize: 12)),
                          Text("${vm.exercises.fold(0, (p, e) => p + e.sets.length)}", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Column(
                        children: [
                          const Text("VOLUME", style: TextStyle(color: Colors.grey, fontSize: 12)),
                          Text("${vm.exercises.fold(0, (p, e) => p + e.sets.fold(0, (p2, s) => p2 + (s.weight * s.reps).toInt()))} kg", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                        ],
                      ),
                   ],
                 ),
               ),
            
            const SizedBox(height: 20),

            // 3. LOGS & CONTROLS (Expanded Bottom Panel)
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: AppPallete.surfaceColor,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                  boxShadow: [BoxShadow(color: Colors.black54, blurRadius: 20, offset: Offset(0, -5))]
                ),
                child: Column(
                  children: [
                    // Header / Handle
                    Container(
                      margin: const EdgeInsets.only(top: 16, bottom: 8),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(color: Colors.grey[800], borderRadius: BorderRadius.circular(2)),
                    ),
                    const Text("SESSION LOG", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Colors.grey)),
                    
                    // List
                    Expanded(
                       child: vm.exercises.isEmpty 
                         ? const Center(child: Text("NO SETS RECORDED", style: TextStyle(color: Colors.white24, letterSpacing: 2)))
                         : ListView.separated(
                             padding: const EdgeInsets.all(20),
                             itemCount: vm.exercises.length,
                             separatorBuilder: (_, __) => const SizedBox(height: 10),
                             itemBuilder: (ctx, i) {
                               final e = vm.exercises[i];
                               return Container(
                                 padding: const EdgeInsets.all(12),
                                 decoration: BoxDecoration(
                                   color: Colors.black26, 
                                   borderRadius: BorderRadius.circular(12),
                                   border: Border.all(color: Colors.white10)
                                 ),
                                 child: Row(
                                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                   children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(e.name, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                                          Text("${e.sets.length} Sets", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                        ],
                                      ),
                                      Text(
                                        "${e.sets.last.weight}kg x ${e.sets.last.reps}",
                                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),
                                      ),
                                   ],
                                 ),
                               );
                             }
                           ),
                    ),

                    // Controls Area
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: const BoxDecoration(
                        color: Colors.black26,
                        border: Border(top: BorderSide(color: Colors.white10))
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _ControlButton(Icons.stop, "FINISH", Colors.redAccent, vm.toggleWorkout),
                          
                          // Big Play Button
                           GestureDetector(
                            onTap: vm.toggleWorkout,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                color: vm.isWorkingOut ? Colors.transparent : Theme.of(context).primaryColor,
                                shape: BoxShape.circle,
                                border: Border.all(color: Theme.of(context).primaryColor, width: 2),
                                boxShadow: [
                                  if (!vm.isWorkingOut)
                                    BoxShadow(color: Theme.of(context).primaryColor, blurRadius: 15)
                                ]
                              ),
                              child: Icon(
                                vm.isWorkingOut ? Icons.pause : Icons.play_arrow, 
                                size: 35, 
                                color: vm.isWorkingOut ? Theme.of(context).primaryColor : Colors.black
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
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
        backgroundColor: AppPallete.surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("LOG SET", style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: "Exercise Name", filled: true, fillColor: Colors.black12)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: TextField(controller: repsController, decoration: const InputDecoration(labelText: "Reps", filled: true, fillColor: Colors.black12), keyboardType: TextInputType.number)),
                const SizedBox(width: 10),
                Expanded(child: TextField(controller: weightController, decoration: const InputDecoration(labelText: "Weight (kg)", filled: true, fillColor: Colors.black12), keyboardType: TextInputType.number)),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("CANCEL", style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor),
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
            child: const Text("SAVE SET", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _MetricChip(this.label, this.value, this.icon);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppPallete.surfaceColor,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Theme.of(context).primaryColor),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
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

  const _ControlButton(this.icon, this.label, this.color, this.onTap);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2), 
              shape: BoxShape.circle,
              border: Border.all(color: color.withOpacity(0.5))
            ),
            child: Icon(icon, color: color, size: 24)
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1))
        ],
      ),
    );
  }
}

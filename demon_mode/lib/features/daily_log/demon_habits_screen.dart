import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_pallete.dart';
import 'daily_log_view_model.dart';
import '../settings/settings_view_model.dart';

class DemonHabitsScreen extends StatelessWidget {
  const DemonHabitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final logVm = context.watch<DailyLogViewModel>();
    final settingsVm = context.watch<SettingsViewModel>();
    
    final log = logVm.currentLog;
    if (log == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    // Merge settings habits with log habits to ensure we check everything
    // If a habit is in settings but not in log (newly added), treat as false.
    final allHabits = settingsVm.habits;
    final logHabits = log.customHabits;

    return Scaffold(
      appBar: AppBar(title: const Text("DEMON DISCIPLINE")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Score Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [Colors.red[900]!, Colors.black]),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.redAccent),
            ),
            child: Column(
              children: [
                const Text("DAILY DEMON SCORE", style: TextStyle(color: Colors.redAccent, letterSpacing: 2)),
                const SizedBox(height: 10),
                Text(
                  log.demonScore.toStringAsFixed(1),
                  style: const TextStyle(fontSize: 64, fontWeight: FontWeight.bold, color: Colors.white, shadows: [Shadow(color: Colors.red, blurRadius: 20)]),
                ),
                Text(
                  log.demonScore > 8 ? "RUTHLESS." : "WEAK.",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white70),
                )
              ],
            ),
          ),
          
          const SizedBox(height: 30),

           // Sleep Input
          const Text("RECOVERY", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppPallete.surfaceColor, borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                 Row(
                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                   children: [
                     const Text("Sleep Duration", style: TextStyle(fontWeight: FontWeight.bold)),
                     Text("${log.sleepHours.toStringAsFixed(1)} h", style: const TextStyle(color: AppPallete.primaryColor, fontSize: 20, fontWeight: FontWeight.bold)),
                   ],
                 ),
                 Slider(
                   value: log.sleepHours, 
                   min: 0, 
                   max: 12, 
                   divisions: 24, 
                   label: "${log.sleepHours} h",
                   activeColor: AppPallete.primaryColor,
                   onChanged: (val) => logVm.updateSleep(val),
                 ),
                 if (log.sleepHours >= 7)
                   const Text("Target Reached (+1 Point)", style: TextStyle(color: Colors.green, fontSize: 12))
                 else 
                   const Text("Target: 7+ hours", style: TextStyle(color: Colors.red, fontSize: 12)),
              ],
            ),
          ),

          const SizedBox(height: 30),
          const Text("NON-NEGOTIABLES", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 10),
          
          ...allHabits.map((key) {
             final isDone = logHabits[key] ?? false;
             return SwitchListTile(
               title: Text(key, style: const TextStyle(fontWeight: FontWeight.bold)),
               value: isDone,
               activeColor: Colors.redAccent,
               onChanged: (val) {
                 logVm.toggleCustomHabit(key, val);
               },
             );
          }),
        ],
      ),
    );
  }
}

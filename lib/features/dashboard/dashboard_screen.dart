import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_pallete.dart';
import 'dashboard_view_model.dart';
import '../settings/settings_screen.dart';
import '../settings/settings_view_model.dart';
import '../zen_mode/zen_mode_screen.dart';
import '../daily_log/widgets/glass_action_card.dart';
import '../daily_log/daily_log_view_model.dart';
import '../nutrition/nutrition_screen.dart';
import '../nutrition/nutrition_view_model.dart';
import '../expert_hub/expert_hub_screen.dart';
import '../body_metrics/body_metrics_screen.dart';
import '../daily_log/demon_habits_screen.dart';
import '../workout/workout_screen.dart';


class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardViewModel>().init();
      context.read<DailyLogViewModel>().loadLog(DateTime.now());
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DashboardViewModel>();
    final nutVm = context.watch<NutritionViewModel>();
    final logVm = context.watch<DailyLogViewModel>();
    final settingsVm = context.watch<SettingsViewModel>();

    final userLog = logVm.currentLog;
    final habits = settingsVm.habits;
    final logHabits = userLog?.customHabits ?? {};

    return Scaffold(
      appBar: AppBar(
        title: const Text('DEMON MODE // DASH'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
          },
        ),
        actions: [
           IconButton(
            icon: const Icon(Icons.accessibility_new), 
            onPressed: () {
               Navigator.push(context, MaterialPageRoute(builder: (_) => const BodyMetricsScreen()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.self_improvement),
            tooltip: 'Zen Mode',
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ZenModeScreen()));
            },
          ),
        ],
      ),
      body: userLog == null 
        ? const Center(child: CircularProgressIndicator()) 
        : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Safety Warning Banner
            if (nutVm.safetyWarning != null)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.redAccent)
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning, color: Colors.redAccent),
                    const SizedBox(width: 12),
                    Expanded(child: Text(nutVm.safetyWarning!, style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold))),
                  ],
                ),
              ),

            // Streak Banner
            if (vm.streak > 0)
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.redAccent.withOpacity(0.3))
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.local_fire_department, color: Colors.orange, size: 20),
                    const SizedBox(width: 8),
                    Text("Streak: ${vm.streak} Days", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
                  ],
                ),
              ),

            // Demon Score Ring
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: 250,
                  width: 250,
                  child: CircularProgressIndicator(
                    value: userLog.demonScore / 10.0,
                    strokeWidth: 20,
                    backgroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.white10 : Colors.black12,
                    color: _getScoreColor(userLog.demonScore),
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Column(
                  children: [
                    Text(
                      userLog.demonScore.toStringAsFixed(1),
                      style: const TextStyle(fontSize: 60, fontWeight: FontWeight.bold),
                    ),
                    const Text("DEMON SCORE", style: TextStyle(letterSpacing: 2, color: Colors.grey)),
                  ],
                )
              ],
            ),
            
            const SizedBox(height: 30),

            // Mood & Focus Slider
            GlassActionCard(
               child: Padding(
                 padding: const EdgeInsets.all(16),
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     Row(
                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                       children: [
                         const Text("MOOD & FOCUS", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
                         Text("${userLog.moodScore}%", style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
                       ],
                     ),
                     Slider(
                       value: userLog.moodScore.toDouble(),
                       min: 0, 
                       max: 100,
                       activeColor: Theme.of(context).primaryColor,
                       inactiveColor: Theme.of(context).brightness == Brightness.dark ? Colors.white10 : Colors.black12,
                       onChanged: (val) {
                          logVm.updateMoodScore(val.toInt());
                       },
                     ),
                     const Row(
                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                       children: [
                         Text("Weak", style: TextStyle(fontSize: 10, color: Colors.grey)),
                         Text("Demon", style: TextStyle(fontSize: 10, color: Colors.grey)),
                       ],
                     )
                   ],
                 ),
               ),
            ),
            
            const SizedBox(height: 16),
            
            // Steps Card
            GlassActionCard(
               child: Padding(
                 padding: const EdgeInsets.all(16),
                 child: Row(
                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                   children: [
                     Row(
                       children: [
                         Container(
                           padding: const EdgeInsets.all(10),
                           decoration: BoxDecoration(color: Theme.of(context).primaryColor.withOpacity(0.1), shape: BoxShape.circle),
                           child: Icon(Icons.directions_walk, color: Theme.of(context).primaryColor, size: 24),
                         ),
                         const SizedBox(width: 15),
                         Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                             const Text("STEPS", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.grey, letterSpacing: 1.5)),
                             Text("${vm.steps}", style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                           ],
                         ),
                       ],
                     ),
                     Column(
                       crossAxisAlignment: CrossAxisAlignment.end,
                       children: [
                         SizedBox(
                           height: 40,
                           width: 40,
                           child: CircularProgressIndicator(
                             value: (vm.steps / 10000).clamp(0.0, 1.0),
                             backgroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.white10 : Colors.black12,
                             color: Theme.of(context).primaryColor,
                           ),
                         ),
                         const SizedBox(height: 4),
                         const Text("10k Goal", style: TextStyle(fontSize: 10, color: Colors.grey)),
                       ],
                     )
                   ],
                 ),
               ),
            ),

            // Nutrition Summary (Calories In vs Out)
            GlassActionCard(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("CALORIES", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 10)),
                            const SizedBox(height: 4),
                            Text("${nutVm.totalKCal.toInt()} / ${nutVm.targetKCal.toInt()}", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        // Mini Macros
                        Row(
                           children: [
                              _MiniMacro("P", nutVm.totalProtein.toInt(), Colors.blue),
                              const SizedBox(width: 8),
                              _MiniMacro("C", nutVm.totalCarbs.toInt(), Colors.green),
                              const SizedBox(width: 8),
                              _MiniMacro("F", nutVm.totalFats.toInt(), Colors.orange),
                           ],
                        )
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                       borderRadius: BorderRadius.circular(4),
                       child: LinearProgressIndicator(
                         value: nutVm.targetKCal > 0 ? (nutVm.totalKCal / nutVm.targetKCal).clamp(0.0, 1.0) : 0,
                         color: Theme.of(context).primaryColor,
                         backgroundColor: Colors.white10,
                         minHeight: 6,
                       ),
                    )
                  ],
                ),
              ),
              onTap: () {
                 // Open Nutrition Tab via NavigationBar logic? 
                 // It's in ProtocolLog now. We can't easily switch tabs from here without global key or provider logic.
                 // For now, simple user tap on 'LOG' botton nav is enough.
              },
            ),

            const SizedBox(height: 20),
            
            // "Demon Protocol" Checklist
            Align(
              alignment: Alignment.centerLeft,
              child: Text("NON-NEGOTIABLES", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Theme.of(context).primaryColor)),
            ),
            const SizedBox(height: 10),
            
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16)
              ),
              child: Column(
                children: [
                   // Sleep Check
                   SwitchListTile(
                     title: const Text("Sleep 7+ Hours", style: TextStyle(fontWeight: FontWeight.bold)),
                     subtitle: const Text("Recovery Basis", style: TextStyle(fontSize: 10, color: Colors.grey)),
                     secondary: const Icon(Icons.bed, color: Colors.deepPurpleAccent),
                     value: userLog.sleepHours >= 7,
                     activeColor: Theme.of(context).primaryColor,
                     onChanged: (val) {
                        logVm.updateSleep(val ? 8.0 : 6.0);
                     },
                   ),
                   Divider(color: Theme.of(context).dividerColor),
                   // Dynamic Habits
                   ...habits.map((habit) {
                     final isDone = logHabits[habit] ?? false;
                     return Column(
                       children: [
                         SwitchListTile(
                           title: Text(habit, style: const TextStyle(fontWeight: FontWeight.bold)),
                           secondary: const Icon(Icons.check_circle_outline, color: Colors.grey),
                           value: isDone,
                           activeColor: Theme.of(context).primaryColor,
                           onChanged: (val) {
                             HapticFeedback.lightImpact();
                             logVm.toggleCustomHabit(habit, val);
                           },
                         ),
                         if (habit != habits.last) Divider(color: Theme.of(context).dividerColor),
                       ],
                     );
                   }).toList(),
                ],
              ),
            ),
            
            const SizedBox(height: 30),

            // Zen Quote
            GlassActionCard(
               child: Padding(
                 padding: const EdgeInsets.all(16),
                 child: Column(
                   children: [
                     Icon(Icons.format_quote, color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5) ?? Colors.grey),
                     Text(
                       '"${vm.randomQuote}"',
                       textAlign: TextAlign.center,
                       style: TextStyle(fontStyle: FontStyle.italic, color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7)),
                     ),
                     const SizedBox(height: 5),
                     // const Text("- M. Tyson", style: TextStyle(fontSize: 10, color: Colors.grey))
                   ],
                 ),
               ),
               onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ZenModeScreen())),
            ),
            
            const SizedBox(height: 40),

            const SizedBox(height: 80),
            
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 8) return Theme.of(context).primaryColor;
    if (score >= 5) return Colors.orange;
    return Colors.grey;
  }
}

class _MiniMacro extends StatelessWidget {
  final String label;
  final int val;
  final Color color;
  const _MiniMacro(this.label, this.val, this.color);
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(val.toString(), style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }
}

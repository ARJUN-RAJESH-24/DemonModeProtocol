import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_pallete.dart';
import 'daily_log_view_model.dart';
import 'widgets/glass_action_card.dart';
import '../settings/settings_view_model.dart';
import '../nutrition/nutrition_view_model.dart';
import '../workout/workout_view_model.dart';

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
      context.read<DailyLogViewModel>().loadLog(DateTime.now());
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DailyLogViewModel>();
    final settingsVM = context.watch<SettingsViewModel>();
    final log = vm.currentLog;

    if (vm.isLoading) {
      return Center(child: CircularProgressIndicator(color: Theme.of(context).primaryColor));
    }

    if (log == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            const Text("Failed to load log.", style: TextStyle(color: Colors.white70)),
            TextButton(
              onPressed: () => vm.loadLog(DateTime.now()),
              child: const Text("RETRY"),
            )
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
           log.date.day == DateTime.now().day ? 'Daily Transformation' : "${log.date.year}-${log.date.month}-${log.date.day}",
           style: const TextStyle(fontSize: 16),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: log.date,
                firstDate: DateTime(2024),
                lastDate: DateTime.now(),
              );
              if (picked != null) {
                vm.loadLog(picked);
              }
            }, 
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
                      IconButton(onPressed: () { HapticFeedback.selectionClick(); vm.updateWater(250); }, icon: Icon(Icons.add_circle, color: Theme.of(context).primaryColor, size: 32)),
                    ],
                  )
                ],
              ),
            ),
            
            const SizedBox(height: 20),

            // Coffee Section (New)
            _buildSectionHeader("Caffeine"),
            GlassActionCard(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("${log.coffeeIntake} cups", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      const Text("Limit: 400mg", style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(onPressed: () { HapticFeedback.selectionClick(); vm.updateCoffee(-1); }, icon: const Icon(Icons.remove_circle_outline)),
                      IconButton(onPressed: () { HapticFeedback.selectionClick(); vm.updateCoffee(1); }, icon: Icon(Icons.add_circle, color: Theme.of(context).primaryColor, size: 32)), // Keeping explicit AppPallete here for now, will replace in bulk or use context
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
                activeThumbColor: Theme.of(context).primaryColor,
                onChanged: (_) { HapticFeedback.mediumImpact(); vm.toggleWorkout(); },
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Custom Habits Section
            if (settingsVM.habits.isNotEmpty) ...[
              _buildSectionHeader("Daily Habits"),
              ...settingsVM.habits.map((habit) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: GlassActionCard(
                  child: CheckboxListTile(
                    title: Text(habit, style: const TextStyle(fontWeight: FontWeight.bold)),
                    value: log.customHabits[habit] ?? false,
                    activeColor: Theme.of(context).primaryColor,
                    onChanged: (val) { 
                      HapticFeedback.lightImpact(); 
                      vm.toggleCustomHabit(habit, val ?? false); 
                    },
                  ),
                ),
              )),
            ],

            const SizedBox(height: 20),

             // NUTRITION INTEGRATION
             Consumer<NutritionViewModel>(
                builder: (context, nvm, _) {
                   return Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       _buildSectionHeader("Fuel & Nutrition"),
                       GlassActionCard(
                         child: Column(
                           children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("${nvm.totalKCal.toInt()} / ${nvm.targetKCal.toInt()} kcal", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                  Text("${(nvm.totalKCal / nvm.targetKCal * 100).clamp(0, 100).toStringAsFixed(0)}%", style: TextStyle(color: Theme.of(context).primaryColor)),
                                ],
                              ),
                              const SizedBox(height: 10),
                              LinearProgressIndicator(
                                value: (nvm.totalKCal / (nvm.targetKCal == 0 ? 1 : nvm.targetKCal)).clamp(0.0, 1.0),
                                color: Theme.of(context).primaryColor,
                                backgroundColor: Colors.white10,
                              ),
                              const SizedBox(height: 10),
                              if (nvm.todayLogs.isEmpty)
                                const Text("No meals logged yet.", style: TextStyle(color: Colors.grey, fontSize: 12))
                              else
                                ...nvm.todayLogs.take(3).map((e) => Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 2),
                                  child: Row(
                                    children: [
                                      Expanded(child: Text("${e.mealType}: ${e.food?.name ?? 'Unknown'}", style: const TextStyle(fontSize: 12))),
                                      Text("${e.totalKCal.toInt()} kcal", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                    ],
                                  ),
                                ))
                           ],
                         ),
                       ),
                     ],
                   );
                },
             ),

            const SizedBox(height: 20),

            // WORKOUT INTEGRATION
            Consumer<WorkoutViewModel>(
              builder: (context, wvm, _) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader("Live Session"),
                    GlassActionCard(
                      child: wvm.exercises.isEmpty 
                        ? const Text("No active workout session.", style: TextStyle(color: Colors.grey))
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Active Session • ${wvm.exercises.length} Exercises", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.greenAccent)),
                              const Divider(color: Colors.white10),
                              ...wvm.exercises.map((e) => Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(e.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                    Text("${e.sets.length} sets", style: const TextStyle(color: Colors.grey)),
                                  ],
                                ),
                              ))
                            ],
                          ),
                    ),
                  ],
                );
              },
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

import 'dart:io';
import 'package:flutter/material.dart';
import '../../data/models/daily_log_model.dart';
import 'widgets/glass_action_card.dart';
import 'package:provider/provider.dart';
import 'history_view_model.dart';
import '../../core/theme/app_pallete.dart';

class LogDetailScreen extends StatelessWidget {
  final DailyLogModel log;

  const LogDetailScreen({super.key, required this.log});

  @override
  Widget build(BuildContext context) {
    // Trigger loading of deep details (meals/metrics) when viewing
    WidgetsBinding.instance.addPostFrameCallback((_) {
       context.read<HistoryViewModel>().loadDetails(log);
    });

    final vm = context.watch<HistoryViewModel>();
    final isLoading = vm.isLoadingDetails;

    return Scaffold(
      appBar: AppBar(
        title: Text("LOG // ${log.date.year}-${log.date.month}-${log.date.day}"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Score Header
              _buildScoreHeader(context, log),
              const SizedBox(height: 20),
  
              // 2. Hydration & Caffeine
               _buildSectionHeader("Fundamentals"),
               GlassActionCard(
                 child: Column(
                   children: [
                      _buildDetailRow("Hydration", "${log.waterIntake} ml", Icons.water_drop, Colors.blue),
                      const Divider(color: Colors.white10),
                      _buildDetailRow("Caffeine", "${log.coffeeIntake} cups", Icons.coffee, Colors.brown),
                      const Divider(color: Colors.white10),
                      _buildDetailRow("Sleep", "${log.sleepHours} hrs", Icons.bed, Colors.deepPurple),
                      const Divider(color: Colors.white10),
                      _buildDetailRow("Steps", "${log.steps}", Icons.directions_walk, Colors.orange),
                   ],
                 ),
               ),
               const SizedBox(height: 20),
  
               // 3. Mood & Journal
               if (log.journalEntry != null || log.mood.isNotEmpty) ...[
                  _buildSectionHeader("Mindset"),
                  GlassActionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                         Row(
                           children: [
                              const Icon(Icons.mood, color: Colors.grey, size: 20),
                              const SizedBox(width: 10),
                              Text("${log.mood} (${log.moodScore}%)", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                           ],
                         ),
                         if (log.journalEntry != null && log.journalEntry!.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            const Divider(color: Colors.white10),
                            const SizedBox(height: 10),
                            Text('"${log.journalEntry}"', style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.white70)),
                         ]
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
               ],
  
               // 4. Workout Details (From JSON)
              _buildSectionHeader("Training Log"),
               GlassActionCard(
                 child: log.workouts.isEmpty
                 ? const Padding(padding: EdgeInsets.all(8), child: Text("No training logged.", style: TextStyle(color: Colors.grey)))
                 : Column(
                     children: log.workouts.map((session) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                             Text("WORKOUT SESSION // ${_formatTime(session.durationSeconds)}", style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold)),
                             const SizedBox(height: 8),
                             ...session.exercises.map((ex) => Padding(
                               padding: const EdgeInsets.symmetric(vertical: 4),
                               child: Row(
                                 crossAxisAlignment: CrossAxisAlignment.start,
                                 children: [
                                    Expanded(child: Text(ex.name, style: const TextStyle(fontWeight: FontWeight.bold))),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: ex.sets.map((s) => Text("${s.reps} x ${s.weight}kg", style: const TextStyle(color: Colors.grey, fontSize: 12))).toList(),
                                    )
                                 ],
                               ),
                             )),
                             const Divider(color: Colors.white10),
                          ],
                        );
                     }).toList(),
                 ),
               ),
               const SizedBox(height: 20),
               
               // 5. Nutrition (From DB Fetch)
               _buildSectionHeader("Nutrition Log"),
               GlassActionCard(
                  child: isLoading 
                  ? const Center(child: CircularProgressIndicator())
                  : vm.selectedMeals.isEmpty
                    ? const Padding(padding: EdgeInsets.all(8), child: Text("No meals logged.", style: TextStyle(color: Colors.grey)))
                    : Column(
                        children: vm.selectedMeals.map((meal) {
                           return Padding(
                             padding: const EdgeInsets.symmetric(vertical: 6),
                             child: Row(
                               children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                         Text(meal['food_name'] ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold)),
                                         Text(meal['meal_type'], style: const TextStyle(fontSize: 10, color: Colors.grey)),
                                      ],
                                    ),
                                  ),
                                  Text("${(meal['kcal'] * meal['serving_multiplier']).toInt()} kcal", style: const TextStyle(fontWeight: FontWeight.bold)),
                               ],
                             ),
                           );
                        }).toList(),
                    )
               ),
               
               const SizedBox(height: 20),
               
               // 6. Body Metrics (From DB Fetch)
               if (vm.selectedMetrics.isNotEmpty) ...[
                  _buildSectionHeader("Body Check"),
                   GlassActionCard(
                     child: Column(
                       children: [
                          ...vm.selectedMetrics.map((m) => Row(
                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
                             children: [
                                const Text("Weight", style: TextStyle(fontWeight: FontWeight.bold)),
                                Text("${m['weight']} kg", style: const TextStyle(color: Colors.white)),
                             ],
                          )),
                          const SizedBox(height: 10),
                          if (log.photoPaths.isNotEmpty)
                            SizedBox(
                              height: 100,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                children: log.photoPaths.map((path) => Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(File(path), width: 80, height: 100, fit: BoxFit.cover, cacheWidth: 400),
                                  ),
                                )).toList(),
                              ),
                            )
                       ],
                     )
                   ),
                   const SizedBox(height: 20),
               ],
  
               _buildSectionHeader("Habits"),
               GlassActionCard(
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                       ...log.customHabits.entries.where((e) => e.value).map((e) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.green)
                          ),
                          child: Text(e.key.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.green)),
                       )),
                       ...log.supplements.map((s) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.blue)
                          ),
                          child: Text(s.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blue)),
                       ))
                    ],
                  ),
               )
  
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 4),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: AppPallete.secondaryColor,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
          fontSize: 12
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
         Icon(icon, color: color, size: 20),
         const SizedBox(width: 15),
         Expanded(child: Text(label, style: const TextStyle(color: Colors.grey))),
         Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }

  Widget _buildScoreHeader(BuildContext context, DailyLogModel log) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Theme.of(context).primaryColor.withOpacity(0.2), Colors.transparent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.3))
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
           Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
                const Text("DEMON SCORE", style: TextStyle(letterSpacing: 2, color: Colors.grey, fontSize: 10)),
                Text(log.demonScore.toStringAsFixed(1), style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold)),
             ],
           ),
           if (log.workoutDone)
             Container(
               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
               decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(20)),
               child: const Row(children: [Icon(Icons.check, size: 16, color: Colors.white), SizedBox(width: 4), Text("CONQUERED", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10))]),
             )
        ],
      ),
    );
  }

  String _formatTime(int? seconds) {
    if (seconds == null) return "00:00";
    final h = (seconds / 3600).floor().toString().padLeft(2, '0');
    final m = ((seconds % 3600) / 60).floor().toString().padLeft(2, '0');
    return "$h:$m";
  }
}

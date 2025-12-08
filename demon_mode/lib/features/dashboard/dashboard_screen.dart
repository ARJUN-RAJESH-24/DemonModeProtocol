import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/services.dart';
import '../../data/repositories/daily_log_repository.dart';
import '../../core/theme/app_pallete.dart';
import 'dashboard_view_model.dart';
import '../settings/settings_screen.dart';
import '../zen_mode/zen_mode_screen.dart';
import '../daily_log/widgets/glass_action_card.dart';
import '../daily_log/daily_log_view_model.dart';
import '../nutrition/nutrition_screen.dart';
import '../expert_hub/expert_hub_screen.dart';
import '../body_metrics/body_metrics_screen.dart';
import '../daily_log/demon_habits_screen.dart';

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
      // Ensure daily log is fresh
      context.read<DailyLogViewModel>().loadLog(DateTime.now());
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DashboardViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('DEMON MODE'),
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
            icon: const Icon(Icons.self_improvement), // Zen Icon
            onPressed: () {
               HapticFeedback.lightImpact();
               Navigator.push(context, MaterialPageRoute(builder: (_) => const ZenModeScreen()));
            },
          ),

        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Zen Quote Card
            const GlassActionCard(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text("DAILY STOIC", style: TextStyle(fontWeight: FontWeight.bold, color: AppPallete.secondaryColor, letterSpacing: 2)),
                    SizedBox(height: 10),
                    Text(
                      '"The obstacle is the way."', // Placeholder
                      textAlign: TextAlign.center,
                      style: TextStyle(fontStyle: FontStyle.italic, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Steps Ring
            SizedBox(
              height: 250,
              child: Stack(
                alignment: Alignment.center,
                children: [
                   SizedBox(
                    width: 200,
                    height: 200,
                    child: CircularProgressIndicator(
                      value: vm.steps / 10000, // Goal: 10k
                      strokeWidth: 15,
                      backgroundColor: AppPallete.surfaceColor,
                      color: AppPallete.primaryColor,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.directions_run, size: 40, color: AppPallete.primaryColor),
                      Text(
                        "${vm.steps}",
                        style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                      ),
                      const Text("STEPS", style: TextStyle(color: Colors.grey, letterSpacing: 2)),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 10),

            // Feature Grid
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _FeatureCard(
                  icon: Icons.restaurant,
                  title: "NUTRITION",
                  color: Colors.green,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NutritionScreen())),
                ),
                 _FeatureCard(
                  icon: Icons.school,
                  title: "EXPERT HUB",
                  color: Colors.redAccent,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ExpertHubScreen())),
                ),
                _FeatureCard(
                  icon: Icons.accessibility_new,
                  title: "BODY METRICS",
                  color: Colors.purple,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BodyMetricsScreen())),
                ),
                 _FeatureCard(
                  icon: Icons.bolt,
                  title: "DEMON SCORE",
                  value: vm.todayLog?.demonScore.toStringAsFixed(1),
                  color: Colors.orange,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DemonHabitsScreen())),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Weekly Consistency
             const Align(
              alignment: Alignment.centerLeft,
              child: Text("WEEKLY CONSISTENCY", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: const FlTitlesData(show: false),
                   borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: vm.weeklyLogs.asMap().entries.map((e) {
                        return FlSpot(e.key.toDouble(), e.value.workoutDone ? 1 : 0);
                      }).toList(),
                      isCurved: true,
                      color: AppPallete.primaryColor,
                      barWidth: 4,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(show: true, color: AppPallete.primaryColor.withOpacity(0.1)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppPallete.primaryColor,
        child: const Icon(Icons.add, color: Colors.black),
        onPressed: () {
          showModalBottomSheet(
            context: context, 
            backgroundColor: AppPallete.surfaceColor,
            builder: (ctx) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.local_drink, color: Colors.blue),
                  title: const Text("Log Water (+250ml)"),
                  onTap: () {
                    context.read<DailyLogViewModel>().updateWater(250);
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Water Logged")));
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.monitor_weight, color: Colors.purple),
                  title: const Text("Log Weight"),
                  onTap: () {
                    Navigator.pop(ctx);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const BodyMetricsScreen()));
                  },
                ),
                 ListTile(
                  leading: const Icon(Icons.mood, color: Colors.yellow),
                  title: const Text("Log Mood"),
                  onTap: () {
                    // Quick Mood logic or nav? Let's just nav to Daily Log for full details
                    // Or keep it simple for now
                     Navigator.pop(ctx);
                     // Navigator.push... 
                     // Since DailyLogScreen is complex, let's just hint functionality
                     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Mood logging coming to Quick Actions soon.")));
                  },
                ),
              ],
            )
          );
        },
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? value;
  final Color color;
  final VoidCallback onTap;

  const _FeatureCard({required this.icon, required this.title, this.value, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppPallete.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1)),
            if (value != null)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(value!, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 18)),
              )
          ],
        ),
      ),
    );
  }
}

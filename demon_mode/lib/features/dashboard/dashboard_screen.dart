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
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () async {
              final repo = DailyLogRepository();
              final logs = await repo.getAllLogs();
              debugPrint("Exporting ${logs.length} logs...");
              if (context.mounted) {
                 ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Exported ${logs.length} logs (Mock)")),
                );
              }
            },
          )
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
            
            const SizedBox(height: 30),
            
            // Weekly Chart
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("WEEKLY CONSISTENCY", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 && value.toInt() < vm.weeklyLogs.length) {
                             return Text(
                               ['S','M','T','W','T','F','S'][DateTime.now().subtract(Duration(days: 6 - value.toInt())).weekday % 7],
                               style: const TextStyle(color: Colors.grey),
                             );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: vm.weeklyLogs.asMap().entries.map((e) {
                    return BarChartGroupData(
                      x: e.key,
                      barRods: [
                        BarChartRodData(
                          toY: e.value.workoutDone ? 1 : 0.2, // 1 for workout, 0.2 for miss
                          color: e.value.workoutDone ? AppPallete.primaryColor : AppPallete.surfaceColor,
                          width: 16,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

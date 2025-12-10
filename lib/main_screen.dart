import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_pallete.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'features/daily_log/protocol_log_screen.dart';
import 'features/workout/workout_screen.dart';
import 'features/expert_hub/expert_hub_screen.dart';
import 'features/body_metrics/body_metrics_screen.dart';

class MainScreen extends StatefulWidget {
  final int initialIndex;
  const MainScreen({super.key, this.initialIndex = 0});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  final List<Widget> _screens = [
    const DashboardScreen(),
    const ProtocolLogScreen(), // "Log" section
    const WorkoutScreen(),
    const ExpertHubScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          labelTextStyle: MaterialStateProperty.all(
            const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)
          )
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (idx) {
            HapticFeedback.lightImpact();
            setState(() => _currentIndex = idx);
          },
          backgroundColor: Theme.of(context).navigationBarTheme.backgroundColor ?? Theme.of(context).colorScheme.surface,
          indicatorColor: Theme.of(context).primaryColor.withOpacity(0.5),
          destinations: const [
             NavigationDestination(
               icon: Icon(Icons.dashboard_outlined), 
               selectedIcon: Icon(Icons.dashboard),
               label: "DASH"
             ),
             NavigationDestination(
               icon: Icon(Icons.restaurant_menu_outlined), 
               selectedIcon: Icon(Icons.restaurant_menu),
               label: "LOG"
             ),
             NavigationDestination(
               icon: Icon(Icons.fitness_center_outlined), 
               selectedIcon: Icon(Icons.fitness_center),
               label: "TRAIN"
             ),
             NavigationDestination(
               icon: Icon(Icons.school_outlined), 
               selectedIcon: Icon(Icons.school),
               label: "HUB"
             ),
          ],
        ),
      ),
    );
  }
}

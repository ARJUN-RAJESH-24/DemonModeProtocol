import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/demon_theme.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'features/daily_log/daily_log_screen.dart';
import 'features/workout/workout_screen.dart';
import 'features/splash/splash_screen.dart';
import 'features/devices/devices_screen.dart';
import 'features/dashboard/dashboard_view_model.dart';
import 'features/daily_log/daily_log_view_model.dart';
import 'features/workout/workout_view_model.dart';
import 'features/devices/devices_view_model.dart';
import 'features/settings/settings_view_model.dart';
import 'features/nutrition/nutrition_view_model.dart';
import 'features/body_metrics/body_metrics_view_model.dart';
import 'features/expert_hub/expert_hub_screen.dart';

void main() {
  runApp(const DemonModeApp());
}

class DemonModeApp extends StatelessWidget {
  const DemonModeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DashboardViewModel()),
        ChangeNotifierProvider(create: (_) => DailyLogViewModel()),
        ChangeNotifierProvider(create: (_) => WorkoutViewModel()),
        ChangeNotifierProvider(create: (_) => DevicesViewModel()),
        ChangeNotifierProvider(create: (_) => SettingsViewModel()..init()),
        ChangeNotifierProvider(create: (_) => NutritionViewModel()),
        ChangeNotifierProvider(create: (_) => BodyMetricsViewModel()),
      ],
      child: MaterialApp(
        title: 'Demon Mode Protocol',
        debugShowCheckedModeBanner: false,
        theme: DemonTheme.darkThemeMode,
        home: const SplashScreen(),
      ),
    );
  }
}

class MainNavigationWrapper extends StatefulWidget {
  const MainNavigationWrapper({super.key});

  @override
  State<MainNavigationWrapper> createState() => _MainNavigationWrapperState();
}

class _MainNavigationWrapperState extends State<MainNavigationWrapper> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const DashboardScreen(),
    const DailyLogScreen(),
    const WorkoutScreen(),
    const ExpertHubScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.edit_note_outlined),
            selectedIcon: Icon(Icons.edit_note),
            label: 'Log',
          ),
          NavigationDestination(
            icon: Icon(Icons.fitness_center_outlined),
            selectedIcon: Icon(Icons.fitness_center),
            label: 'Workout',
          ),
          NavigationDestination(
            icon: Icon(Icons.school_outlined),
            selectedIcon: Icon(Icons.school),
            label: 'Expert Hub',
          ),
        ],
      ),
    );
  }
}
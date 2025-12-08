import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main_screen.dart';
import 'core/theme/app_pallete.dart';
import 'data/database/database_service.dart';
import 'features/settings/settings_view_model.dart';
import 'features/nutrition/nutrition_view_model.dart';
import 'features/workout/workout_view_model.dart';
import 'features/daily_log/daily_log_view_model.dart';
import 'features/dashboard/dashboard_view_model.dart';
import 'features/body_metrics/body_metrics_view_model.dart';
import 'features/onboarding/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseService.instance.database;
  
  final prefs = await SharedPreferences.getInstance();
  final showOnboarding = !prefs.containsKey('onboarding_complete');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsViewModel()),
        ChangeNotifierProxyProvider<SettingsViewModel, NutritionViewModel>(
          create: (_) => NutritionViewModel(),
          update: (_, settings, nutrition) => nutrition!..init(settings),
        ),
        ChangeNotifierProvider(create: (_) => WorkoutViewModel()),
        ChangeNotifierProvider(create: (_) => DailyLogViewModel()),
        ChangeNotifierProvider(create: (_) => DashboardViewModel()),
        ChangeNotifierProvider(create: (_) => BodyMetricsViewModel()),
      ],
      child: DemonModeApp(showOnboarding: showOnboarding),
    ),
  );
}

class DemonModeApp extends StatelessWidget {
  final bool showOnboarding;
  const DemonModeApp({super.key, required this.showOnboarding});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Demon Mode',
      theme: AppTheme.darkTheme,
      home: showOnboarding ? const OnboardingScreen() : const MainScreen(),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'main_screen.dart';
import 'core/theme/app_pallete.dart';
import 'data/database/database_service.dart';
import 'features/settings/settings_view_model.dart';
import 'features/nutrition/nutrition_view_model.dart';
import 'features/workout/workout_view_model.dart';
import 'features/daily_log/daily_log_view_model.dart';
import 'features/dashboard/dashboard_view_model.dart';
import 'features/body_metrics/body_metrics_view_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseService.instance.database;
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
      child: const DemonModeApp(),
    ),
  );
}

class DemonModeApp extends StatelessWidget {
  const DemonModeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Demon Mode',
      theme: AppTheme.darkTheme,
      home: const MainScreen(),
    );
  }
}
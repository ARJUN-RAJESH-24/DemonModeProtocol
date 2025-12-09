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
        ChangeNotifierProvider(create: (_) => BodyMetricsViewModel()),
        ChangeNotifierProxyProvider<BodyMetricsViewModel, NutritionViewModel>(
          create: (_) => NutritionViewModel(),
          update: (_, bodyMetrics, nutrition) => nutrition!..init(bodyMetrics),
        ),
        ChangeNotifierProvider(create: (_) => WorkoutViewModel()),
        ChangeNotifierProvider(create: (_) => DailyLogViewModel()),
        ChangeNotifierProvider(create: (_) => DashboardViewModel()),
      ],
      child: const DemonModeApp(),
    ),
  );
}

class DemonModeApp extends StatelessWidget {
  const DemonModeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsViewModel>(
      builder: (context, settings, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Demon Mode',
          theme: AppTheme.getTheme(settings.accentColor),
          home: const _AppLoader(), 
        );
      },
    );
  }
}

class _AppLoader extends StatefulWidget {
  const _AppLoader();
  @override
  State<_AppLoader> createState() => _AppLoaderState();
}

class _AppLoaderState extends State<_AppLoader> {
  @override
  void initState() {
    super.initState();
    _load();
  }
  
  Future<void> _load() async {
    // Determine onboarding state after provider init? 
    // Or just check prefs here directly.
    final prefs = await SharedPreferences.getInstance();
    final showOnboarding = !prefs.containsKey('onboarding_complete');
    
    if (mounted) {
       Navigator.of(context).pushReplacement(
         MaterialPageRoute(builder: (_) => showOnboarding ? const OnboardingScreen() : const MainScreen())
       );
    }
  }

  @override
  Widget build(BuildContext context) {
     return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

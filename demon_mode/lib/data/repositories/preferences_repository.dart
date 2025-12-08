import 'package:shared_preferences/shared_preferences.dart';

class PreferencesRepository {
  static const _keyHabits = 'custom_habits_list';
  static const _keyUnitSystem = 'unit_system'; // 'metric' or 'imperial'
  
  Future<List<String>> getHabits() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_keyHabits) ?? ['Cold Plunge', 'Read 10 Pages', 'Creatine', '10k Steps', 'Stretching', 'Zone 2 Cardio (45m)']; // Defaults
  }

  Future<void> addHabit(String habit) async {
    final prefs = await SharedPreferences.getInstance();
    final habits = prefs.getStringList(_keyHabits) ?? [];
    if (!habits.contains(habit)) {
      habits.add(habit);
      await prefs.setStringList(_keyHabits, habits);
    }
  }

  Future<void> removeHabit(String habit) async {
    final prefs = await SharedPreferences.getInstance();
    final habits = prefs.getStringList(_keyHabits) ?? [];
    habits.remove(habit);
    await prefs.setStringList(_keyHabits, habits);
  }

  Future<String> getUnitSystem() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUnitSystem) ?? 'metric';
  }

  Future<void> setUnitSystem(String system) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUnitSystem, system);
  }
}

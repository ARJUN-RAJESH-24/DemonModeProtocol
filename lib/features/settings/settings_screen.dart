import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'settings_view_model.dart';
import '../../core/theme/app_pallete.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _SettingsBody();
  }
}

class _SettingsBody extends StatelessWidget {
  const _SettingsBody();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SettingsViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text("PROTOCOL SETTINGS")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          
          // Theme Color Section
          const Text("THEME COLOR", style: TextStyle(color: AppPallete.primaryColor, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Card(
            color: AppPallete.surfaceColor,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Wrap(
                spacing: 15,
                runSpacing: 10,
                children: [
                  _ColorSwatch(Colors.redAccent, vm),
                  _ColorSwatch(const Color(0xFFFF0033), vm), // Neon Red
                  _ColorSwatch(Colors.blueAccent, vm),
                  _ColorSwatch(Colors.greenAccent, vm),
                  _ColorSwatch(Colors.purpleAccent, vm),
                  _ColorSwatch(Colors.orangeAccent, vm),
                  _ColorSwatch(Colors.tealAccent, vm),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 10),
          SwitchListTile(
            title: const Text("Light Mode"),
             secondary: const Icon(Icons.wb_sunny, color: Colors.orange),
             value: vm.themeMode == ThemeMode.light,
             activeColor: AppPallete.primaryColor,
             onChanged: (val) => vm.toggleTheme(val),
          ),
          
          const SizedBox(height: 20),
          const Text("CUSTOMIZATIONS", style: TextStyle(color: AppPallete.primaryColor, fontWeight: FontWeight.bold)),
          SwitchListTile(
            title: const Text("Use Metric System (kg/km)"),
            value: vm.unitSystem == 'metric',
            activeColor: AppPallete.primaryColor,
            onChanged: (val) => vm.toggleUnitSystem(val ? 'metric' : 'imperial'),
          ),
          const SizedBox(height: 10),
          const Text("DAILY HABITS", style: TextStyle(color: Colors.grey, fontSize: 12)),
          ...vm.habits.map((habit) => ListTile(
            title: Text(habit),
            trailing: IconButton(
              icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
              onPressed: () => vm.removeHabit(habit),
            ),
          )),
          ListTile(
            leading: const Icon(Icons.add, color: AppPallete.primaryColor),
            title: const Text("Add Custom Habit"),
            onTap: () async {
              final controller = TextEditingController();
              await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text("New Habit"),
                  content: TextField(
                    controller: controller,
                    decoration: const InputDecoration(hintText: "e.g., Creatine, Read, Meditate"),
                    autofocus: true,
                  ),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("CANCEL")),
                    TextButton(
                      onPressed: () {
                         if (controller.text.isNotEmpty) {
                           vm.addHabit(controller.text);
                           Navigator.pop(ctx, true);
                         }
                      }, 
                      child: const Text("ADD"),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          const Text("DATA", style: TextStyle(color: AppPallete.primaryColor, fontWeight: FontWeight.bold)),
          ListTile(
            title: const Text("Export Data"),
            subtitle: const Text("Save logs to CSV/JSON"),
            trailing: const Icon(Icons.upload_file, color: Colors.blue),
            onTap: () => vm.exportData(),
          ),
          ListTile(
            title: const Text("Import Data"),
            subtitle: const Text("Restore logs from backup"),
            trailing: const Icon(Icons.download, color: Colors.green),
            onTap: () => vm.importData(),
          ),
          ListTile(
            title: const Text("Clear All Data"),
            subtitle: const Text("Permanently delete logs & workouts"),
            trailing: const Icon(Icons.delete_forever, color: Colors.red),
            onTap: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text("NUKE DATA?"),
                  content: const Text("This cannot be undone."),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("CANCEL")),
                    TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("DELETE", style: TextStyle(color: Colors.red))),
                  ],
                ),
              );
              
              if (confirm == true) {
                await vm.clearAllData();
                if (context.mounted) {
                   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Data Nuked.")));
                }
              }
            },
          ),
          
          const SizedBox(height: 20),
          const Text("ABOUT", style: TextStyle(color: AppPallete.primaryColor, fontWeight: FontWeight.bold)),
          ListTile(
            title: const Text("Version"),
            subtitle: Text(vm.version),
          ),
          const SizedBox(height: 20),
          Center(
            child: InkWell(
              onTap: () async {
                final uri = Uri.parse("https://github.com/ARJUN-RAJESH-24/DemonModeProtocol");
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              },
              child: Column(
                children: [
                  const Text("Built by Arjun Rajesh", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                  const Text("for the bold and strong", style: TextStyle(color: Colors.grey, fontSize: 12, fontStyle: FontStyle.italic)),
                  const SizedBox(height: 4),
                  Text("github.com/ARJUN-RAJESH-24", style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 12, decoration: TextDecoration.underline)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _ColorSwatch(Color color, SettingsViewModel vm) {
    bool isSelected = vm.accentColor.value == color.value;
    return GestureDetector(
      onTap: () => vm.setAccentColor(color),
      child: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: isSelected ? Border.all(color: Colors.white, width: 3) : Border.all(color: Colors.transparent),
          boxShadow: isSelected ? [BoxShadow(color: color.withOpacity(0.5), blurRadius: 10)] : [],
        ),
      ),
    );
  }
}

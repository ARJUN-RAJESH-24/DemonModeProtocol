import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'settings_view_model.dart';
import '../../core/theme/app_pallete.dart';

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
        ],
      ),
    );
  }
}

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
          
          // Profile Section
          const Text("DEMON PROFILE", style: TextStyle(color: AppPallete.primaryColor, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Card(
            color: AppPallete.surfaceColor,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                   Row(
                     children: [
                       Expanded(child: _ProfileInput("Age", vm.age?.toString(), (v) => vm.updateProfile(a: int.tryParse(v)))),
                       const SizedBox(width: 10),
                       Expanded(child: DropdownButtonFormField<String>(
                         value: vm.gender,
                         dropdownColor: Colors.grey[900],
                         decoration: const InputDecoration(labelText: "Gender", border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5)),
                         items: const [
                           DropdownMenuItem(value: 'male', child: Text("Male")),
                           DropdownMenuItem(value: 'female', child: Text("Female")),
                         ],
                         onChanged: (val) => vm.updateProfile(sex: val),
                       )),
                     ],
                   ),
                   const SizedBox(height: 10),
                   Row(
                     children: [
                       Expanded(child: _ProfileInput("Height (cm)", vm.height?.toString(), (v) => vm.updateProfile(h: double.tryParse(v)))),
                       const SizedBox(width: 10),
                       Expanded(child: _ProfileInput("Weight (kg)", vm.weight?.toString(), (v) => vm.updateProfile(w: double.tryParse(v)))),
                     ],
                   ),
                   const SizedBox(height: 10),
                   DropdownButtonFormField<double>(
                     value: vm.activityLevel,
                     dropdownColor: Colors.grey[900],
                     decoration: const InputDecoration(labelText: "Activity Level", border: OutlineInputBorder()),
                     items: const [
                       DropdownMenuItem(value: 1.2, child: Text("Sedentary (Office Job)")),
                       DropdownMenuItem(value: 1.375, child: Text("Light Exercise (1-2 days)")),
                       DropdownMenuItem(value: 1.55, child: Text("Moderate (3-5 days)")),
                       DropdownMenuItem(value: 1.725, child: Text("Heavy (6-7 days)")),
                     ],
                     onChanged: (val) => vm.updateProfile(activity: val),
                   ),
                   const SizedBox(height: 10),
                   DropdownButtonFormField<String>(
                     value: vm.goal,
                     dropdownColor: Colors.grey[900],
                     decoration: const InputDecoration(labelText: "Current Protocol", border: OutlineInputBorder()),
                     items: const [
                       DropdownMenuItem(value: 'cut', child: Text("CUT (Deficit)")),
                       DropdownMenuItem(value: 'maintain', child: Text("MAINTAIN")),
                       DropdownMenuItem(value: 'bulk', child: Text("BULK (Surplus)")),
                     ],
                     onChanged: (val) => vm.updateProfile(g: val),
                   ),
                   const SizedBox(height: 20),
                   // Calorie Override
                   Row(
                     children: [
                        Expanded(
                          child: TextFormField(
                            initialValue: vm.calorieTargetOverride?.toString(),
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: "Override Calorie Target (Optional)",
                              border: OutlineInputBorder(),
                              hintText: "Leave empty to auto-calc"
                            ),
                            onChanged: (val) {
                               if (val.isEmpty) {
                                 vm.updateProfile(calOverride: -1);
                               } else {
                                 vm.updateProfile(calOverride: double.tryParse(val));
                               }
                            },
                          ),
                        ),
                     ],
                   ),
                   const SizedBox(height: 10),
                   if (vm.tdee != null)
                     Container(
                       padding: const EdgeInsets.all(8),
                       width: double.infinity,
                       decoration: BoxDecoration(color: Colors.greenAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                       child: Center(child: Text("DAILY TARGET: ${vm.tdee!.toInt()} KCAL", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.greenAccent, fontSize: 16))),
                     )
                ],
              ),
            ),
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
        ],
      ),
    );
  }

  Widget _ProfileInput(String label, String? val, Function(String) onChanged) {
    return TextFormField(
      initialValue: val,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      ),
      onChanged: onChanged,
    );
  }
}

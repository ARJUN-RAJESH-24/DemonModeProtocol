import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'settings_view_model.dart';
import '../../core/theme/app_pallete.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SettingsViewModel()..init(),
      child: const _SettingsBody(),
    );
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

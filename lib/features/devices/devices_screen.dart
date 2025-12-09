import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_pallete.dart';
import 'devices_view_model.dart';
import '../daily_log/widgets/glass_action_card.dart';

class DevicesScreen extends StatelessWidget {
  const DevicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _DevicesBody();
  }
}

class _DevicesBody extends StatelessWidget {
  const _DevicesBody();

  @override
  Widget build(BuildContext context) {
     final vm = context.watch<DevicesViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('EQUIPMENT PAIRING')),
      floatingActionButton: FloatingActionButton(
        onPressed: vm.isScanning ? null : vm.startScan,
        backgroundColor: vm.isScanning ? Colors.grey : AppPallete.primaryColor,
        child: Icon(vm.isScanning ? Icons.hourglass_top : Icons.search),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (vm.connectedDevice != null) ...[
              GlassActionCard(
                child: Column(
                  children: [
                    const Icon(Icons.favorite, size: 60, color: AppPallete.primaryColor),
                    Text(
                      "${vm.heartRate} BPM",
                      style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                    ),
                    Text("Connected to ${vm.connectedDevice!.platformName}"),
                    const SizedBox(height: 10),
                    OutlinedButton(onPressed: vm.disconnect, child: const Text("Disconnect")),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            if (vm.scanResults.isEmpty && !vm.isScanning)
              const Center(child: Text("No devices found. Press search.", style: TextStyle(color: Colors.grey))),

            ...vm.scanResults.map((result) {
              return Card(
                color: AppPallete.surfaceColor,
                child: ListTile(
                  title: Text(result.device.platformName.isNotEmpty ? result.device.platformName : "Unknown Device"),
                  subtitle: Text(result.device.remoteId.toString()),
                  trailing: ElevatedButton(
                    onPressed: () => vm.connect(result.device),
                    child: const Text("Connect"),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

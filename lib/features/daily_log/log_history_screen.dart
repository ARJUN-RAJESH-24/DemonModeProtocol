import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_pallete.dart';
import 'history_view_model.dart';
import 'log_detail_screen.dart';
import 'widgets/glass_action_card.dart';
import 'package:intl/intl.dart';

class LogHistoryScreen extends StatefulWidget {
  const LogHistoryScreen({super.key});

  @override
  State<LogHistoryScreen> createState() => _LogHistoryScreenState();
}

class _LogHistoryScreenState extends State<LogHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HistoryViewModel>().loadHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HistoryViewModel>();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text("DEMON ARCHIVES"),
        centerTitle: true,
      ),
      body: vm.isLoading 
      ? const Center(child: CircularProgressIndicator())
      : vm.history.isEmpty
        ? const Center(child: Text("No records found.", style: TextStyle(color: Colors.grey)))
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: vm.history.length,
            itemBuilder: (context, index) {
              final log = vm.history[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GlassActionCard(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => LogDetailScreen(log: log)),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        // Date Box
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.3))
                          ),
                          child: Column(
                            children: [
                              Text(DateFormat('MMM').format(log.date).toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                              Text(log.date.day.toString(), style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),
                        
                        // Summary
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(DateFormat('EEEE, yyyy').format(log.date), style: const TextStyle(color: Colors.grey, fontSize: 12)),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Text("Score: ${log.demonScore.toStringAsFixed(1)}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  const SizedBox(width: 10),
                                  if (log.workoutDone) const Icon(Icons.fitness_center, size: 14, color: Colors.greenAccent),
                                ],
                              )
                            ],
                          ),
                        ),
                        
                        const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey)
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
    );
  }
}

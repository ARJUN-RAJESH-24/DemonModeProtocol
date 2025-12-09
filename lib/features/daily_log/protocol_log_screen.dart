import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_pallete.dart';
import '../nutrition/nutrition_screen.dart'; // Imports NutritionPage
import 'daily_log_view_model.dart';
import 'widgets/glass_action_card.dart';

class ProtocolLogScreen extends StatelessWidget {
  const ProtocolLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("PROTOCOL LOGGER"),
          centerTitle: true,
          bottom: const TabBar(
            isScrollable: true,
            indicatorColor: AppPallete.primaryColor,
            labelColor: AppPallete.primaryColor,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(icon: Icon(Icons.restaurant), text: "NUTRITION"),
              Tab(icon: Icon(Icons.water_drop), text: "HYDRATION"),
              Tab(icon: Icon(Icons.medication), text: "SUPPLEMENTS"),
              Tab(icon: Icon(Icons.psychology), text: "MIND"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            NutritionPage(),
            _HydrationView(),
            _SupplementsView(),
             _MindView(),
          ],
        ),
      ),
    );
  }
}

class _HydrationView extends StatelessWidget {
  const _HydrationView();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DailyLogViewModel>();
    final log = vm.currentLog;

    if (log == null) return const Center(child: CircularProgressIndicator());

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Water Section
           GlassActionCard(
             child: Padding(
               padding: const EdgeInsets.all(16),
               child: Column(
                 children: [
                   const Icon(Icons.water_drop, size: 50, color: Colors.blueAccent),
                   const SizedBox(height: 10),
                   const Text("WATER INTAKE", style: TextStyle(letterSpacing: 2, color: Colors.grey)),
                   Text("${(log.waterIntake / 1000).toStringAsFixed(1)}L", style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
                   const Text("Target: 5.0L", style: TextStyle(color: Colors.grey)),
                   
                   const SizedBox(height: 20),
                   Row(
                     children: [
                       Expanded(child: _ActionButton("250ml", Icons.add, () => vm.updateWater(250))),
                       const SizedBox(width: 10),
                       Expanded(child: _ActionButton("500ml", Icons.add, () => vm.updateWater(500))),
                     ],
                   )
                 ],
               ),
             ),
           ),
           
           const SizedBox(height: 20),
           
           // Coffee Section
           GlassActionCard(
             child: Padding(
               padding: const EdgeInsets.all(16),
               child: Column(
                 children: [
                   const Icon(Icons.coffee, size: 50, color: Colors.brown),
                   const SizedBox(height: 10),
                   const Text("CAFFEINE", style: TextStyle(letterSpacing: 2, color: Colors.grey)),
                   Text("${log.coffeeIntake} Cups", style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
                   
                   const SizedBox(height: 20),
                   _ActionButton("Add Cup", Icons.add, () => vm.updateCoffee(1)),
                 ],
               ),
             ),
           ),
        ],
      ),
    );
  }
}

class _SupplementsView extends StatelessWidget {
  const _SupplementsView();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DailyLogViewModel>();
    final log = vm.currentLog;
    final controller = TextEditingController();

    if (log == null) return const Center(child: CircularProgressIndicator());

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("DAILY STACK", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: log.supplements.map((s) => Chip(
              label: Text(s),
              backgroundColor: AppPallete.surfaceColor,
              deleteIcon: const Icon(Icons.close, size: 16),
              onDeleted: () => vm.removeSupplement(s),
            )).toList(),
          ),
          
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: "Add Supplement (e.g. Creatine)",
                    filled: true,
                    fillColor: AppPallete.surfaceColor,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              IconButton(
                style: IconButton.styleFrom(backgroundColor: AppPallete.primaryColor),
                icon: const Icon(Icons.add, color: Colors.black),
                onPressed: () {
                  if (controller.text.isNotEmpty) {
                    vm.addSupplement(controller.text);
                    controller.clear();
                  }
                },
              )
            ],
          )
        ],
      ),
    );
  }
}

class _MindView extends StatefulWidget {
  const _MindView();

  @override
  State<_MindView> createState() => _MindViewState();
}

class _MindViewState extends State<_MindView> {
  final _journalCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
       final log = context.read<DailyLogViewModel>().currentLog;
       if (log != null) {
         _journalCtrl.text = log.journalEntry ?? "";
       }
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DailyLogViewModel>();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
           GlassActionCard(
             child: Padding(
               padding: const EdgeInsets.all(16),
               child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   const Text("REFLECTION PROMPT", style: TextStyle(color: AppPallete.primaryColor, fontWeight: FontWeight.bold)),
                   const SizedBox(height: 5),
                   const Text('"What small victory can you build upon tomorrow?"', style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey)),
                 ],
               ),
             ),
           ),
           const SizedBox(height: 20),
           const Align(alignment: Alignment.centerLeft, child: Text("JOURNAL - CONQUESTS", style: TextStyle(fontWeight: FontWeight.bold))),
           const SizedBox(height: 10),
           TextField(
             controller: _journalCtrl,
             maxLines: 10,
             decoration: InputDecoration(
               hintText: "Record your daily conquests...",
               filled: true,
               fillColor: AppPallete.surfaceColor,
               border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
             ),
             onChanged: (val) => vm.updateJournal(val), // Auto-save on type might be too aggressive, but VM saves are async. Maybe debounce?
             // Since we use provider, let's update on focus lost or separate button? 
             // Simplest: Update on change for prototype feel.
           ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _ActionButton(this.label, this.icon, this.onTap);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppPallete.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppPallete.primaryColor.withOpacity(0.5)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: AppPallete.primaryColor),
            const SizedBox(width: 5),
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: AppPallete.primaryColor)),
          ],
        ),
      ),
    );
  }
}

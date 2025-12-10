import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_pallete.dart';
import '../nutrition/nutrition_screen.dart'; // Imports NutritionPage
import 'daily_log_view_model.dart';

import 'widgets/glass_action_card.dart';
import 'package:flutter/services.dart';
import 'dart:io';

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
                   Text("${(log.waterIntake / 1000).toStringAsFixed(1)}L", style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color)),
                   const SizedBox(height: 10),
                   Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _IntakeButton(icon: Icons.remove, onTap: () => vm.updateWater(-250)),
                        const SizedBox(width: 20),
                        _IntakeButton(icon: Icons.add, onTap: () => vm.updateWater(250)),
                      ],
                   )
                 ],
               ),
             ),
           ), 
           const SizedBox(height: 20),
           // Caffeine Section
           GlassActionCard(
             child: Padding(
               padding: const EdgeInsets.all(16),
               child: Column(
                 children: [
                   const Icon(Icons.coffee, size: 50, color: Colors.brown),
                   const SizedBox(height: 10),
                   const Text("CAFFEINE", style: TextStyle(letterSpacing: 2, color: Colors.grey)),
                   Text("${log.coffeeIntake} CUPS", style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color)),
                   const SizedBox(height: 10),
                   Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _IntakeButton(icon: Icons.remove, onTap: () => vm.updateCoffee(-1)),
                        const SizedBox(width: 20),
                        _IntakeButton(icon: Icons.add, onTap: () => vm.updateCoffee(1)),
                      ],
                   )
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
              backgroundColor: Theme.of(context).cardColor,
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
                    fillColor: Theme.of(context).cardColor,
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
               fillColor: Theme.of(context).cardColor,
               border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
             ),
             onChanged: (val) => vm.updateJournal(val), 
           ),
           
           const SizedBox(height: 25),
           const Align(alignment: Alignment.centerLeft, child: Text("PROGRESS PHOTOS", style: TextStyle(fontWeight: FontWeight.bold))),
           const SizedBox(height: 10),
           SizedBox(
             height: 120,
             child: ListView(
               scrollDirection: Axis.horizontal,
               children: [
                  GestureDetector(
                    onTap: () => vm.addPhoto(),
                    child: Container(
                      width: 100,
                      margin: const EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark ? Colors.white10 : Colors.black12,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Theme.of(context).dividerColor)
                      ),
                      child: Icon(Icons.camera_alt, color: Theme.of(context).textTheme.bodyLarge?.color),
                    ),
                  ),
                  if (vm.currentLog?.photoPaths != null)
                    ...vm.currentLog!.photoPaths.map((path) => Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(File(path), width: 100, height: 120, fit: BoxFit.cover),
                      ),
                    ))
               ],
             ),
           ),
        ],
      ),
    );
  }
}



class _IntakeButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  
  const _IntakeButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark ? Colors.white10 : Colors.black12,
          shape: BoxShape.circle,
          border: Border.all(color: Theme.of(context).dividerColor)
        ),
        child: Icon(icon, color: Theme.of(context).textTheme.bodyLarge?.color),
      ),
    );
  }
}

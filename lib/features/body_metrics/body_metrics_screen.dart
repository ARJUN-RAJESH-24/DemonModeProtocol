import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'body_metrics_view_model.dart';
import '../daily_log/daily_log_view_model.dart';
import '../../core/theme/app_pallete.dart';
import '../../core/theme/app_pallete.dart';
import 'package:fl_chart/fl_chart.dart';

class BodyMetricsScreen extends StatefulWidget {
  const BodyMetricsScreen({super.key});

  @override
  State<BodyMetricsScreen> createState() => _BodyMetricsScreenState();
}

class _BodyMetricsScreenState extends State<BodyMetricsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<BodyMetricsViewModel>().init();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<BodyMetricsViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text("BODY METRICS")),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showUpdateModal(context, vm),
        icon: const Icon(Icons.add),
        label: const Text("UPDATE METRICS"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Stats Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                   colors: [Theme.of(context).primaryColor.withOpacity(0.2), Theme.of(context).cardColor], 
                   begin: Alignment.topLeft, 
                   end: Alignment.bottomRight
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                       _StatItem("BMI", vm.bmi?.toStringAsFixed(1) ?? "--"),
                       _StatItem("BODY FAT", vm.bodyFat != null ? "${vm.bodyFat!.toStringAsFixed(1)}%" : "--"),
                       _StatItem("TDEE", vm.tdee?.toStringAsFixed(0) ?? "--"),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 10),
                   _StatItemSmall("MAX CAFFEINE", vm.maxDailyCaffeine != null ? "${vm.maxDailyCaffeine!.toInt()}mg" : "--"),
               ],
              ),
            ),
            
            const SizedBox(height: 15),
            
            // Photo Check Button
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                   Provider.of<DailyLogViewModel>(context, listen: false).addPhoto();
                },
                icon: const Icon(Icons.camera_alt),
                label: const Text("DAILY PHYSIQUE CHECK"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).cardColor, 
                  foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
                  minimumSize: const Size(200, 50)
                ),
              ),
            ),
            
            const SizedBox(height: 30),

            
            const SizedBox(height: 30),
            
            // History Chart
            
            const SizedBox(height: 30),
            
            // History Chart
            Padding(
              padding: const EdgeInsets.only(left: 8.0, bottom: 10),
              child: Row(
                children: [
                  Icon(Icons.show_chart, color: Colors.grey[400]),
                  const SizedBox(width: 8),
                  const Text("WEIGHT HISTORY", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                ],
              ),
            ),
            Container(
              height: 250,
              padding: const EdgeInsets.fromLTRB(10, 20, 20, 10),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor.withOpacity(0.5),
                borderRadius: BorderRadius.circular(24),
              ),
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                     show: true, 
                     drawVerticalLine: false, 
                     getDrawingHorizontalLine: (_) => FlLine(color: Theme.of(context).dividerColor, strokeWidth: 1)
                  ),
                  titlesData: const FlTitlesData(
                     show: true,
                     topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                     rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                     leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                     bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: vm.weightHistory.reversed.toList().asMap().entries.map((e) {
                         return FlSpot(e.key.toDouble(), e.value['weight'] as double);
                      }).toList(),
                      isCurved: true,
                      color: Theme.of(context).primaryColor,
                      barWidth: 4,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(radius: 4, color: Theme.of(context).primaryColor, strokeWidth: 2, strokeColor: Colors.black),
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [Theme.of(context).primaryColor.withOpacity(0.3), Colors.transparent],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    )
                  ]
                )
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _StatItem(String label, String val) {
    return Column(
      children: [
        Text(val, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, height: 1.0)),
        const SizedBox(height: 5),
        Text(label, style: TextStyle(color: Colors.grey[400], fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
      ],
    );
  }
  
  Widget _StatItemSmall(String label, String val) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("$label: ", style: TextStyle(color: Colors.grey[400], fontSize: 12, fontWeight: FontWeight.bold)),
        Text(val, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.orangeAccent)),
      ],
    );
  }

  void _showUpdateModal(BuildContext context, BodyMetricsViewModel vm) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, top: 20, left: 20, right: 20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("UPDATE METRICS", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
              const SizedBox(height: 20),
              
              const Text("Body Stats", style: TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _Input("Weight (kg)", (v) => vm.weight = double.tryParse(v), vm.weight?.toString())),
                  const SizedBox(width: 10),
                  Expanded(child: _Input("Height (cm)", (v) => vm.heightCm = double.tryParse(v), vm.heightCm?.toString())),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _Input("Waist (cm)", (v) => vm.waist = double.tryParse(v), vm.waist?.toString())),
                  const SizedBox(width: 10),
                  Expanded(child: _Input("Neck (cm)", (v) => vm.neck = double.tryParse(v), vm.neck?.toString())),
                ],
              ),
              
              const SizedBox(height: 20),
              const Divider(color: Colors.white10),
              const SizedBox(height: 10),
              const Text("Profile (Factors into TDEE)", style: TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 10),
              
              Row(
                children: [
                   Expanded(child: _Input("Age", (v) => vm.age = int.tryParse(v), vm.age?.toString())),
                   const SizedBox(width: 10),
                   Expanded(
                     child: DropdownButtonFormField<bool>(
                       value: vm.isMale,
                       dropdownColor: Theme.of(context).cardColor,
                       decoration: _inputDeco("Gender"),
                       items: const [
                         DropdownMenuItem(value: true, child: Text("Male")),
                         DropdownMenuItem(value: false, child: Text("Female")),
                       ],
                       onChanged: (val) { if(val!=null) vm.isMale = val; },
                     ),
                   ),
                ],
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                 value: vm.goal,
                 dropdownColor: Theme.of(context).cardColor,
                 decoration: _inputDeco("Goal"),
                 items: const [
                   DropdownMenuItem(value: 'cut', child: Text("CUT (Deficit)")),
                   DropdownMenuItem(value: 'maintain', child: Text("MAINTAIN")),
                   DropdownMenuItem(value: 'bulk', child: Text("BULK (Surplus)")),
                 ],
                 onChanged: (val) { if(val!=null) vm.goal = val; },
              ),
               const SizedBox(height: 10),
               DropdownButtonFormField<String>(
                 value: vm.activityLevel,
                 dropdownColor: Theme.of(context).cardColor,
                 decoration: _inputDeco("Activity"),
                 items: const [
                    DropdownMenuItem(value: 'Sedentary', child: Text("Sedentary (1.2)")),
                    DropdownMenuItem(value: 'Light', child: Text("Light (1.375)")),
                    DropdownMenuItem(value: 'Moderate', child: Text("Moderate (1.55)")),
                    DropdownMenuItem(value: 'Active', child: Text("Active (1.725)")),
                    DropdownMenuItem(value: 'Very Active', child: Text("Very Active (1.9)")),
                 ],
                 onChanged: (val) { if(val!=null) vm.activityLevel = val; },
              ),
              
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    // Update main profile values in shared prefs via updateProfile wrapper if we had one that took all args,
                    // or just direct set since we have vm vars publicly mutable and we call updateProfile individually.
                    // Actually BodyMetricsViewModel.updateProfile saves to prefs. But here we are setting fields directly?
                    // We need to call updateProfile to persist the "Profile" bits.
                    // The "Stats" bits (weight/waist) are persisted via saveLog().
                    
                    vm.updateProfile(
                      a: vm.age,
                      h: vm.heightCm,
                      male: vm.isMale,
                      act: vm.activityLevel,
                      g: vm.goal
                    );
                    vm.saveLog(); // Saves weight history
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Metrics & Profile Updated")));
                  },
                  child: const Text("SAVE CHANGES"),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _Input(String label, Function(String) onChanged, String? initVal) {
    return TextFormField(
      initialValue: initVal,
      keyboardType: TextInputType.number,
      decoration: _inputDeco(label),
      onChanged: onChanged,
    );
  }
  
  InputDecoration _inputDeco(String label) {
    return InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: Theme.of(context).brightness == Brightness.dark ? Colors.black12 : Colors.grey[200],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      );
  }
}

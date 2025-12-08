import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'body_metrics_view_model.dart';
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Stats Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppPallete.surfaceColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                   _StatItem("BMI", vm.bmi?.toStringAsFixed(1) ?? "--"),
                   _StatItem("BODY FAT", vm.bodyFat != null ? "${vm.bodyFat!.toStringAsFixed(1)}%" : "--"),
                   _StatItem("TDEE", vm.tdee?.toStringAsFixed(0) ?? "--"),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Input Form
            Card(
              color: AppPallete.surfaceColor,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("UPDATE METRICS", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent)),
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
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                        onPressed: () {
                           vm.calculateAll();
                           vm.saveLog();
                           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Metrics Saved")));
                        },
                        child: const Text("CALCULATE & SAVE", style: TextStyle(color: Colors.white)),
                      ),
                    )
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // History Chart (Simple Weight)
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("WEIGHT TREND", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: true, border: Border.all(color: Colors.white10)),
                  lineBarsData: [
                    LineChartBarData(
                      spots: vm.weightHistory.reversed.toList().asMap().entries.map((e) {
                         return FlSpot(e.key.toDouble(), e.value['weight'] as double);
                      }).toList(),
                      isCurved: true,
                      color: Colors.blueAccent,
                      barWidth: 3,
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
        Text(val, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  Widget _Input(String label, Function(String) onChanged, String? initVal) {
    return TextFormField(
      initialValue: initVal,
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

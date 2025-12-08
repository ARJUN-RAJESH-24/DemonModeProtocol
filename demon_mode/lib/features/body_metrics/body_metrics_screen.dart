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
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [Colors.blueAccent.withOpacity(0.2), AppPallete.surfaceColor], begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white10),
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
            
            const SizedBox(height: 30),
            
            // Input Form
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppPallete.surfaceColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   const Row(
                    children: [
                      Icon(Icons.edit, color: Colors.blueAccent, size: 20),
                      SizedBox(width: 8),
                      Text("UPDATE STATS", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(child: _Input("Weight (kg)", (v) => vm.weight = double.tryParse(v), vm.weight?.toString())),
                      const SizedBox(width: 16),
                      Expanded(child: _Input("Height (cm)", (v) => vm.heightCm = double.tryParse(v), vm.heightCm?.toString())),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _Input("Waist (cm)", (v) => vm.waist = double.tryParse(v), vm.waist?.toString())),
                      const SizedBox(width: 16),
                      Expanded(child: _Input("Neck (cm)", (v) => vm.neck = double.tryParse(v), vm.neck?.toString())),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      onPressed: () {
                         vm.calculateAll();
                         vm.saveLog();
                         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Metrics Saved")));
                      },
                      child: const Text("CALCULATE & SAVE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  )
                ],
              ),
            ),
            
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
                color: AppPallete.surfaceColor.withOpacity(0.5),
                borderRadius: BorderRadius.circular(24),
              ),
              // Use a gradient chart
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                     show: true, 
                     drawVerticalLine: false, 
                     getDrawingHorizontalLine: (_) => const FlLine(color: Colors.white10, strokeWidth: 1)
                  ),
                  titlesData: const FlTitlesData(
                     show: true,
                     topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                     rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                     leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)), // Hide Y axis numbers for clean look? Or keep them? Let's hide to be minimal.
                     bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: vm.weightHistory.reversed.toList().asMap().entries.map((e) {
                         return FlSpot(e.key.toDouble(), e.value['weight'] as double);
                      }).toList(),
                      isCurved: true,
                      color: Colors.blueAccent,
                      barWidth: 4,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(radius: 4, color: Colors.blueAccent, strokeWidth: 2, strokeColor: Colors.black),
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [Colors.blueAccent.withOpacity(0.3), Colors.transparent],
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
        Text(val, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, height: 1.0)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: Colors.grey[400], fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
      ],
    );
  }

  Widget _Input(String label, Function(String) onChanged, String? initVal) {
    return TextFormField(
      initialValue: initVal,
      keyboardType: TextInputType.number,
      style: const TextStyle(fontWeight: FontWeight.bold),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: Colors.black12,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      onChanged: onChanged,
    );
  }
}

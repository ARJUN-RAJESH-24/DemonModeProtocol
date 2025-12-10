import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'nutrition_view_model.dart';
import '../../core/theme/app_pallete.dart';
import '../../data/models/food_model.dart';

class NutritionPage extends StatefulWidget {
  const NutritionPage({super.key});

  @override
  State<NutritionPage> createState() => _NutritionPageState();
}

class _NutritionPageState extends State<NutritionPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<NutritionViewModel>();
      vm.fetchTodayLogs();
      vm.seedIndianDatabase();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<NutritionViewModel>();

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppPallete.primaryColor,
        child: const Icon(Icons.add, color: Colors.black),
        onPressed: () {
           showSearch(context: context, delegate: FoodSearchDelegate(vm));
        },
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Summary Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Text("DAILY INTAKE", style: TextStyle(color: Colors.grey, letterSpacing: 2)),
                  const SizedBox(height: 10),
                  Text(
                    "${vm.totalKCal.toStringAsFixed(0)} / ${vm.targetKCal.toStringAsFixed(0)}",
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  const Text("KCALS", style: TextStyle(color: Colors.redAccent)),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _MacroItem("Prot", vm.totalProtein, vm.targetProtein, Colors.blue),
                      _MacroItem("Carb", vm.totalCarbs, 300, Colors.green),
                      _MacroItem("Fat", vm.totalFats, 80, Colors.orange),
                    ],
                  )
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            const Align(alignment: Alignment.centerLeft, child: Text("LOGS", style: TextStyle(fontWeight: FontWeight.bold))),
            const SizedBox(height: 10),
            
            if (vm.todayLogs.isEmpty)
              const Padding(
                padding: EdgeInsets.all(20.0),
                child: Text("No meals logged yet.", style: TextStyle(color: Colors.grey)),
              ),
              
            ...vm.todayLogs.map((log) => ListTile(
              title: Text(log.food?.name ?? "Unknown"),
              subtitle: Text("${log.mealType} • ${log.totalKCal.toInt()} kcal"),
              trailing: Text("${log.totalProtein.toInt()}g P"),
            )),
          ],
        ),
      ),
    );
  }

  Widget _MacroItem(String label, double val, double target, Color color) {
    double progress = target > 0 ? (val / target).clamp(0.0, 1.0) : 0;
    return Column(
      children: [
        Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
        const SizedBox(height: 6),
        Stack(
          alignment: Alignment.center,
          children: [
             SizedBox(
               width: 60,
               height: 60,
               child: CircularProgressIndicator(
                 value: progress,
                 backgroundColor: color.withOpacity(0.2),
                 color: color,
                 strokeWidth: 6,
                 strokeCap: StrokeCap.round,
               ),
             ),
             Column(
               children: [
                 Text("${val.toInt()}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                 Text("g", style: TextStyle(color: color, fontSize: 10)),
               ],
             )
          ],
        ),
        const SizedBox(height: 4),
        Text("of ${target.toInt()}g", style: const TextStyle(color: Colors.grey, fontSize: 10)),
      ],
    );
  }
}

class FoodSearchDelegate extends SearchDelegate {
  final NutritionViewModel vm;
  String _lastQuery = '';
  
  FoodSearchDelegate(this.vm);

  @override
  List<Widget>? buildActions(BuildContext context) => [IconButton(onPressed: () => query = '', icon: const Icon(Icons.clear))];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(onPressed: () => close(context, null), icon: const Icon(Icons.arrow_back));

  @override
  Widget buildResults(BuildContext context) => buildSuggestions(context);

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query != _lastQuery) {
      _lastQuery = query;
      if (query.length > 2) {
         vm.searchFood(query);
      }
    }
    
    return AnimatedBuilder(
      animation: vm,
      builder: (context, child) {
        return ListView(
          children: [
            ListTile(
              leading: const Icon(Icons.add_circle, color: AppPallete.primaryColor),
              title: const Text("Create New Food"),
              subtitle: const Text("Enter macros manually"),
              onTap: () => _showCreateFoodDialog(context),
            ),
            ...vm.foodSearchResults.map((food) => ListTile(
              title: Text(food.name),
              subtitle: Text("${food.kCal} kcal • ${food.protein}g P • ${food.carbs}g C • ${food.fats}g F"),
              trailing: const Icon(Icons.add),
              onTap: () => _showLogDialog(context, food),
            )),
          ],
        );
      }
    );
  }

  void _showLogDialog(BuildContext context, FoodItem food) {
    double multiplier = 1.0;
    String mealType = 'Snack';
    final controller = TextEditingController(text: "1.0");

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Log ${food.name}"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
             DropdownButtonFormField<String>(
               value: mealType,
               items: const [
                 DropdownMenuItem(value: 'Breakfast', child: Text("Breakfast")),
                 DropdownMenuItem(value: 'Lunch', child: Text("Lunch")),
                 DropdownMenuItem(value: 'Dinner', child: Text("Dinner")),
                 DropdownMenuItem(value: 'Snack', child: Text("Snack")),
               ],
               onChanged: (val) => mealType = val!,
               decoration: const InputDecoration(labelText: "Meal Type"),
             ),
             const SizedBox(height: 10),
             TextFormField(
               controller: controller,
               keyboardType: TextInputType.number,
               decoration: InputDecoration(
                 labelText: "Quantity (x ${food.servingQuantity} ${food.servingUnit})",
                 hintText: "e.g. 1.0, 0.5, 2"
               ),
               onChanged: (val) {
                 multiplier = double.tryParse(val) ?? 1.0;
               },
             ),
             const SizedBox(height: 10),
             Text("Total: ${food.kCal * multiplier} kcal", style: const TextStyle(color: Colors.grey)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("CANCEL")),
          TextButton(
            onPressed: () {
               final qty = double.tryParse(controller.text) ?? 1.0;
               Navigator.pop(ctx); // Close dialog first to prevent context issues
               vm.logFood(food, mealType, qty);
               close(context, null); // Then close search
            }, 
            child: const Text("LOG"),
          ),
        ],
      ),
    );
  }

  void _showCreateFoodDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final kcalCtrl = TextEditingController();
    final protCtrl = TextEditingController();
    final carbCtrl = TextEditingController();
    final fatCtrl = TextEditingController();
    String unit = 'serving';
    String qty = '1';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Create Custom Food"),
        scrollable: true,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Food Name*")),
            Row(
              children: [
                Expanded(child: TextField(controller: kcalCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "KCal*"))),
                const SizedBox(width: 10),
                Expanded(child: TextField(controller: protCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Protein (g)")))
              ],
            ),
             Row(
              children: [
                Expanded(child: TextField(controller: carbCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Carbs (g)"))),
                const SizedBox(width: 10),
                Expanded(child: TextField(controller: fatCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Fats (g)")))
              ],
            ),
            const SizedBox(height: 10),
            TextField(controller: TextEditingController(text: "1 serving"), readOnly: true, decoration: const InputDecoration(labelText: "Serving Size", hintText: "Default: 1 serving")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("CANCEL")),
          TextButton(
            onPressed: () async {
              if (nameCtrl.text.isNotEmpty && kcalCtrl.text.isNotEmpty) {
                final food = FoodItem(
                  name: nameCtrl.text,
                  kCal: double.tryParse(kcalCtrl.text) ?? 0,
                  protein: double.tryParse(protCtrl.text) ?? 0,
                  carbs: double.tryParse(carbCtrl.text) ?? 0,
                  fats: double.tryParse(fatCtrl.text) ?? 0,
                  servingUnit: 'serving',
                  servingQuantity: 1,
                  isCustom: true,
                );
                
                final id = await vm.addCustomFood(food);
                // Create a copy with ID to log it
                final savedFood = FoodItem(
                  id: id,
                  name: food.name,
                  kCal: food.kCal,
                  protein: food.protein,
                  carbs: food.carbs,
                  fats: food.fats,
                  servingUnit: food.servingUnit,
                  servingQuantity: food.servingQuantity,
                  isCustom: true
                );
                
                if (context.mounted) {
                   Navigator.pop(ctx); // Close create dialog
                   _showLogDialog(context, savedFood); // Open log dialog
                }
              }
            }, 
            child: const Text("CREATE & LOG"),
          ),
        ],
      ),
    );
  }
  
  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context).copyWith(
      appBarTheme: const AppBarTheme(
        // backgroundColor: Colors.black, // removed to adhere to theme
      ),
    );
  }
}

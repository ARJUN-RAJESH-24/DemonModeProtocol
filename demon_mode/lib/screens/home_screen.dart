import 'package:flutter/material.dart';
import 'daily_log_screen.dart';

class HomeScreen extends StatelessWidget{
    Const HomeScreen({super.key});

    @override
    Widget build(BuildContext context){
      return Scaffold(
        appBar: AppBar(
          title : const Text('Demon Mode Protocol'),
          centerTitle: true;
        ),
        body : Center(
          child:ElevatedButton(
            child : const Text("🔥 Enter Daily Log"),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder:(_) => const DailyLogScreen()),
              );
            },
          ),
        ),
      );
    }
}
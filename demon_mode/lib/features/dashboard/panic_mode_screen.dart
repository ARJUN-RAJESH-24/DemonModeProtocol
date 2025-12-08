import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_pallete.dart';

class PanicModeScreen extends StatefulWidget {
  const PanicModeScreen({super.key});

  @override
  State<PanicModeScreen> createState() => _PanicModeScreenState();
}

class _PanicModeScreenState extends State<PanicModeScreen> {
  bool _isPlaying = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
               // Skull Icon
               Container(
                 width: 120,
                 height: 120,
                 decoration: const BoxDecoration(
                   color: Colors.redAccent,
                   shape: BoxShape.circle,
                   boxShadow: [
                     BoxShadow(color: Colors.redAccent, blurRadius: 20, spreadRadius: 5)
                   ]
                 ),
                 child: const Icon(Icons.dangerous, size: 60, color: Colors.white), // Skull icon fallback
               ),
               const SizedBox(height: 30),
               
               const Text(
                 "DEMON ACTIVATED",
                 style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 3, color: Colors.white),
               ),
               const SizedBox(height: 10),
               const Text(
                 "Weakness has been purged from your system.",
                 textAlign: TextAlign.center,
                 style: TextStyle(color: Colors.white70),
               ),
               
               const SizedBox(height: 40),
               
               Container(
                 padding: const EdgeInsets.all(16),
                 decoration: BoxDecoration(
                   color: Colors.white10,
                   borderRadius: BorderRadius.circular(12)
                 ),
                 child: const Column(
                   children: [
                     Text(
                       '"THE PAIN YOU FEEL TODAY WILL BE THE STRENGTH YOU FEEL TOMORROW."',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                     ),
                     SizedBox(height: 8),
                     Text("- Demon Mode Mantra", style: TextStyle(color: Colors.grey, fontSize: 12))
                   ],
                 ),
               ),
               
               const SizedBox(height: 40),
               
               ElevatedButton.icon(
                 onPressed: () {
                   setState(() => _isPlaying = !_isPlaying);
                   HapticFeedback.heavyImpact();
                   // TODO: Implement audio player
                 },
                 icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                 label: Text(_isPlaying ? "PAUSE MOTIVATION" : "PLAY MOTIVATION AUDIO"),
                 style: ElevatedButton.styleFrom(
                   backgroundColor: Colors.white12,
                   foregroundColor: Colors.white,
                   padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                 ),
               ),
               
               const Spacer(),
               
               SizedBox(
                 width: double.infinity,
                 child: ElevatedButton(
                   onPressed: () {
                      Navigator.pop(context);
                   },
                   style: ElevatedButton.styleFrom(
                     backgroundColor: Colors.redAccent,
                     foregroundColor: Colors.white,
                     padding: const EdgeInsets.symmetric(vertical: 16),
                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                   ),
                   child: const Text("RETURN TO BATTLE", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                 ),
               )
            ],
          ),
        ),
      ),
    );
  }
}

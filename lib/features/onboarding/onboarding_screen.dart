import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_pallete.dart';
import '../../main_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView(
            controller: _controller,
            onPageChanged: (index) => setState(() => _currentPage = index),
            children: [
              _buildPage(
                title: "WELCOME TO\nTHE PROTOCOL",
                content: "Your goal is simple: Total Self-Mastery.\n\nWe track your Biology, Habits, and Mindset to calculate your daily Demon Score.",
                centerWidget: Icon(Icons.shield, size: 100, color: Theme.of(context).primaryColor),
              ),
              _buildPage(
                title: "100% PRIVATE\nSECURE DATA",
                content: "This app operates offline.\n\n• No Cloud Storage\n• No Data Tracking\n• Everything stays on this device.\n\nYour data is yours alone.",
                centerWidget: const Icon(Icons.lock_outline, size: 100, color: Colors.greenAccent),
              ),
              _buildScorePage(),
              _buildPermissionsPage(),
            ],
          ),
          
          // Indicators
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) => _buildDot(index)),
            ),
          ),
          
          // Next/Finish Button
          Positioned(
            bottom: 30,
            right: 20,
            child: _currentPage == 3 
              ? FloatingActionButton.extended(
                  onPressed: _finishOnboarding,
                  backgroundColor: Theme.of(context).primaryColor,
                  label: const Text("ENTER", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                  icon: const Icon(Icons.arrow_forward, color: Colors.black),
                )
              : IconButton(
                  onPressed: () => _controller.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut),
                  icon: const Icon(Icons.arrow_forward_ios, color: Colors.white54),
                ),
          )
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: _currentPage == index ? 24 : 8,
      decoration: BoxDecoration(
        color: _currentPage == index ? Theme.of(context).primaryColor : Colors.white24,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildPage({required String title, required String content, required Widget centerWidget}) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          centerWidget,
          const SizedBox(height: 40),
          Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 2)),
          const SizedBox(height: 20),
          Text(content, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, color: Colors.grey, height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildScorePage() {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("DEMON SCORE", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 2, color: Theme.of(context).primaryColor)),
          const SizedBox(height: 30),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(width: 200, height: 200, child: CircularProgressIndicator(value: 1.0, color: Theme.of(context).primaryColor.withOpacity(0.2), strokeWidth: 15)),
              const Text("10.0", style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 30),
          _buildScoreItem("Workout", "2.0 pts"),
          _buildScoreItem("Habits", "2.0 pts"),
          _buildScoreItem("Nutrition & Hydro", "1.5 pts"),
          _buildScoreItem("Sleep (8h+)", "1.5 pts"),
          _buildScoreItem("Journaling", "1.5 pts"),
          _buildScoreItem("Supplements", "1.5 pts"),
          const SizedBox(height: 20),
          const Text("Max out every day.", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildScoreItem(String label, String points) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, color: Colors.white70)),
          Text(points, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
        ],
      ),
    );
  }
  
  Widget _buildPermissionsPage() {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.security, size: 80, color: Colors.redAccent),
          const SizedBox(height: 30),
          const Text("GRANT ACCESS", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 2)),
          const SizedBox(height: 20),
          const Text("To track your progress and secure data locally, we need permissions.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 40),
          _buildPermissionButton("Activity & Sensors", [Permission.activityRecognition, Permission.sensors]),
          const SizedBox(height: 10),
          _buildPermissionButton("Location (Workouts)", [Permission.location]),
          const SizedBox(height: 10),
          _buildPermissionButton("Storage (Backup)", [Permission.storage, Permission.manageExternalStorage]), // Check permissions logic carefully
        ],
      ),
    );
  }
  
  Widget _buildPermissionButton(String label, List<Permission> perms) {
    return OutlinedButton(
      onPressed: () async {
        for (var p in perms) {
          await p.request();
        }
      },
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: const BorderSide(color: Colors.white24),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          const Icon(Icons.check_circle_outline, size: 16),
        ],
      ),
    );
  }

  Future<void> _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);
    
    if (mounted) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainScreen()));
    }
  }
}

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
                title: "WELCOME TO\nTHE VOID",
                content: "Demon Mode is not for the weak.\nIt is a protocol for total dominance.",
                centerWidget: const Icon(Icons.local_fire_department, size: 100, color: AppPallete.primaryColor),
              ),
              _buildPage(
                title: "THE PROTOCOL",
                content: "We track everything.\n\n• Nutrition\n• Training\n• Sleep\n• Hydration\n• Mind",
                centerWidget: const Icon(Icons.list_alt, size: 100, color: AppPallete.primaryColor),
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
                  backgroundColor: AppPallete.primaryColor,
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
        color: _currentPage == index ? AppPallete.primaryColor : Colors.white24,
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
          const Text("DEMON SCORE", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 2, color: AppPallete.primaryColor)),
          const SizedBox(height: 30),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(width: 200, height: 200, child: CircularProgressIndicator(value: 1.0, color: AppPallete.primaryColor.withOpacity(0.2), strokeWidth: 15)),
              const Text("10.0", style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 30),
          _buildScoreItem("Workout", "2.0 pts"),
          _buildScoreItem("Nutrition", "2.0 pts"),
          _buildScoreItem("Habits", "2.0 pts"),
          _buildScoreItem("Sleep", "2.0 pts"),
          _buildScoreItem("Hydration", "2.0 pts"),
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
          Text(label, style: const TextStyle(fontSize: 16, color: Colors.white70)),
          Text(points, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppPallete.primaryColor)),
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
          const Text("To track your progress, we need permissions.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 40),
          _buildPermissionButton("Activity & Sensors", [Permission.activityRecognition, Permission.sensors]),
          const SizedBox(height: 10),
          _buildPermissionButton("Location (Workouts)", [Permission.location]),
          const SizedBox(height: 10),
          _buildPermissionButton("Notification", [Permission.notification]),
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

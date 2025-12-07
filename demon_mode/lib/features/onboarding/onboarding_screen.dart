// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/theme/app_pallete.dart';
import '../../core/services/auth_service.dart';
import '../../main.dart'; // To navigate to LockScreen/Home
import '../auth/lock_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _page = 0;

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LockScreen(child: MainNavigationWrapper())),
      );
    }
  }

  Future<void> _requestPermissions() async {
    // Request all essential permissions
    await [
      Permission.activityRecognition,
      Permission.sensors,
      Permission.location,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.camera,
      Permission.notification,
    ].request();
    
    // Also trigger Biometric prompt to "warm up"
    await AuthService.hasBiometrics();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPallete.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (p) => setState(() => _page = p),
                children: [
                  _buildPage(
                    title: "DEMON MODE PROTOCOL",
                    subtitle: "Unleash your potential. Track everything.\nHydration. Training. Recovery.",
                    icon: Icons.flash_on,
                  ),
                  _buildPage(
                    title: "SECURE & PRIVATE",
                    subtitle: "Your data is encrypted locally.\nNo cloud leaks. Locked by Biometrics.",
                    icon: Icons.security,
                  ),
                  _buildPage(
                    title: "HARDWARE INTEGRATION",
                    subtitle: "GPS tracking. Step sensors.\nHeart rate monitors. Spotify control.",
                    icon: Icons.watch,
                  ),
                  _buildPage(
                    title: "PERMISSION CHECK",
                    subtitle: "We need access to your sensors and location to function correctly.",
                    icon: Icons.fact_check,
                    isLast: true,
                  ),
                ],
              ),
            ),
            
            // Indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) => 
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 8, height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _page == index ? AppPallete.primaryColor : Colors.grey.withOpacity(0.5),
                  ),
                ),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_page < 3) {
                      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.ease);
                    } else {
                      await _requestPermissions();
                      await _completeOnboarding();
                    }
                  },
                  child: Text(_page < 3 ? "NEXT" : "ACTIVATE PROTOCOL"),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildPage({required String title, required String subtitle, required IconData icon, bool isLast = false}) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 100, color: AppPallete.primaryColor),
          const SizedBox(height: 40),
          Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
          const SizedBox(height: 20),
          Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, color: Colors.grey, height: 1.5)),
        ],
      ),
    );
  }
}

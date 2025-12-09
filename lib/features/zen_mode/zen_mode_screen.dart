// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_pallete.dart';
import 'zen_mode_view_model.dart';

class ZenModeScreen extends StatelessWidget {
  const ZenModeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ZenModeViewModel()..loadThoughts(),
      child: const _ZenModeBody(),
    );
  }
}

class _ZenModeBody extends StatefulWidget {
  const _ZenModeBody();

  @override
  State<_ZenModeBody> createState() => _ZenModeBodyState();
}

class _ZenModeBodyState extends State<_ZenModeBody> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  String _breathingText = "INHALE";

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 16), // 4s in, 4s hold, 4s out, 4s hold
    )..repeat();

    _controller.addListener(() {
      final t = _controller.value;
      if (t < 0.25) {
        setState(() => _breathingText = "INHALE");
      } else if (t < 0.5) {
        setState(() => _breathingText = "HOLD");
      } else if (t < 0.75) {
        setState(() => _breathingText = "EXHALE");
      } else {
        setState(() => _breathingText = "HOLD");
      }
    });

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.5), weight: 25), // Inhale
      TweenSequenceItem(tween: ConstantTween(1.5), weight: 25), // Hold
      TweenSequenceItem(tween: Tween(begin: 1.5, end: 1.0), weight: 25), // Exhale
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 25), // Hold
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.linear));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ZenModeViewModel>();

    return Scaffold(
      backgroundColor: AppPallete.backgroundColor,
      appBar: AppBar(title: const Text("ZEN MODE")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Breathing Visualizer
            AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) {
                return Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppPallete.primaryColor.withOpacity(0.2),
                        AppPallete.backgroundColor,
                      ],
                      radius: _scaleAnimation.value * 0.5,
                    ),
                    border: Border.all(
                      color: AppPallete.primaryColor.withOpacity(0.5),
                      width: 2,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _breathingText,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      color: AppPallete.secondaryColor,
                    ),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 50),
            
            const Text(
              "COLLECT YOUR THOUGHTS",
              style: TextStyle(letterSpacing: 1.5, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: TextEditingController(text: vm.thoughts)
                ..selection = TextSelection.fromPosition(TextPosition(offset: vm.thoughts.length)),
              onChanged: (val) => vm.updateThoughts(val),
              maxLines: 8,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                hintText: "Write down what's on your mind...",
                hintStyle: TextStyle(color: Colors.grey.withOpacity(0.5)),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: vm.isSaving ? null : vm.saveThoughts,
                child: vm.isSaving 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) 
                    : const Text("SAVE TO LOG"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// lib/screens/setup_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../engine/risk_engine.dart';
import '../models/risk_model.dart';

class SetupScreen extends ConsumerStatefulWidget {
  const SetupScreen({super.key});

  @override
  ConsumerState<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends ConsumerState<SetupScreen>
    with TickerProviderStateMixin {
  late AnimationController _progressCtrl;
  late Animation<double> _progress;
  late AnimationController _fadeCtrl;
  late Animation<double> _fade;

  final List<String> _steps = [
    'Loading baseline models...',
    'Calibrating voice analysis...',
    'Initializing risk engine...',
    'Securing local storage...',
    'Ready.',
  ];
  int _stepIndex = 0;

  @override
  void initState() {
    super.initState();
    _progressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..forward();
    _progress = CurvedAnimation(parent: _progressCtrl, curve: Curves.easeOut);

    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _fade = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn);
    _fadeCtrl.forward();

    _runSteps();
  }

  void _runSteps() async {
    for (int i = 0; i < _steps.length; i++) {
      await Future.delayed(const Duration(milliseconds: 400));
      if (mounted) setState(() => _stepIndex = i);
    }
  }

  @override
  void dispose() {
    _progressCtrl.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final engine = ref.read(riskEngineProvider.notifier);
    final _ = ref.watch(riskEngineProvider); // keep reactive

    return Scaffold(
      backgroundColor: const Color(0xFF080A0F),
      body: FadeTransition(
        opacity: _fade,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(flex: 2),

                // Logo area
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: const Color(0xFF00E5A0).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                        color: const Color(0xFF00E5A0).withOpacity(0.3)),
                  ),
                  child: const Center(
                    child: Text('🛡', style: TextStyle(fontSize: 32)),
                  ),
                ),
                const SizedBox(height: 24),

                const Text(
                  'ShieldSense',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Personal Safety Index',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.4),
                    fontSize: 15,
                    letterSpacing: 1,
                  ),
                ),

                const Spacer(flex: 3),

                // Progress
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Text(
                        _steps[_stepIndex],
                        key: ValueKey(_stepIndex),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontFamily: 'monospace',
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    AnimatedBuilder(
                      animation: _progress,
                      builder: (_, __) => ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: _progress.value,
                          backgroundColor: Colors.white.withOpacity(0.07),
                          valueColor: const AlwaysStoppedAnimation(Color(0xFF00E5A0)),
                          minHeight: 4,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Start button
                AnimatedBuilder(
                  animation: _progressCtrl,
                  builder: (_, __) => AnimatedOpacity(
                    opacity: _progressCtrl.value > 0.9 ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 400),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _progressCtrl.value > 0.9
                            ? () => engine.startSetup()
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00E5A0),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'START MONITORING',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

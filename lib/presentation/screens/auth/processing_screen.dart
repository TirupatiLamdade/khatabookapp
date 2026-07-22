import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProcessingScreen extends StatefulWidget {
  final Map<String, String> prefilledData;
  const ProcessingScreen({Key? key, required this.prefilledData})
      : super(key: key);

  @override
  State<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends State<ProcessingScreen>
    with SingleTickerProviderStateMixin {
  double _progressValue = 0.0;
  late Timer _timer;
  late AnimationController _rotationController;

  get GoogleFonts => null;

  @override
  void initState() {
    super.initState();

    // Continuous Rotation for Outer Ring
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    // ⚡ Smooth 3-Second Processing Window
    const duration = Duration(seconds: 3);
    const tick = Duration(milliseconds: 30);
    int totalTicks = duration.inMilliseconds ~/ tick.inMilliseconds;
    int currentTick = 0;

    _timer = Timer.periodic(tick, (timer) {
      if (!mounted) return;

      currentTick++;
      setState(() {
        _progressValue = currentTick / totalTicks;
      });

      if (currentTick >= totalTicks) {
        _timer.cancel();

        // 🔀 Path unchanged - Reads Next Destination Dynamically
        final String nextRoute = widget.prefilledData['next'] ?? '/home';

        if (mounted) {
          context.go(nextRoute, extra: widget.prefilledData);
        }
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F17), // 🌌 Medium Professional Dark
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),

            // 🎯 Center Content: Professional Custom Loader
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // Outer Rotating Subtle Glow Ring
                      RotationTransition(
                        turns: _rotationController,
                        child: Container(
                          width: 156,
                          height: 156,
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: SweepGradient(
                              colors: [
                                const Color(0xFF2563EB).withOpacity(0.0),
                                const Color(0xFF2563EB).withOpacity(0.4),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Base Track Ring
                      const SizedBox(
                        width: 140,
                        height: 140,
                        child: CircularProgressIndicator(
                          value: 1.0,
                          strokeWidth: 5,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Color(0xFF1E293B)),
                        ),
                      ),

                      // Progress Indicator Ring
                      SizedBox(
                        width: 140,
                        height: 140,
                        child: CircularProgressIndicator(
                          value: _progressValue,
                          strokeWidth: 5,
                          strokeCap: StrokeCap.round,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFF3B82F6)),
                        ),
                      ),

                      // Center Percentage Text
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${(_progressValue * 100).toStringAsFixed(0)}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'SYNCING',
                            style: TextStyle(
                              color: const Color(0xFF38BDF8).withOpacity(0.8),
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),

                  // Status Titles
                  const Text(
                    'KhataBook',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight:
                          FontWeight.w700, // Premium look साठी heavy weight
                      letterSpacing: -0.4,
                      fontFamily: 'sans-serif', // Clean Modern Font
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Configuring isolated storage space. Please stay connected.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // 🏷️ Fixed Footer Logo Banner
            Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: const Icon(
                      Icons.menu_book_rounded,
                      color: Color(0xFF3B82F6),
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 10),
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(fontSize: 13, fontFamily: 'Roboto'),
                      children: [
                        TextSpan(
                            text: 'Khatabook ',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                        TextSpan(
                            text: 'Smart Engine',
                            style: TextStyle(
                                color: Color(0xFF64748B),
                                fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

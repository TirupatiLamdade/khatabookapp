import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _logoFadeController;
  late AnimationController _logoScaleController;
  late AnimationController _textFadeController;

  late Animation<double> _logoFadeAnimation;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _textFadeAnimation;

  @override
  void initState() {
    super.initState();

    // 1️⃣ Entrance Animations Setup
    _logoFadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _logoFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoFadeController, curve: Curves.easeIn),
    );

    _logoScaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _logoScaleAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _logoScaleController, curve: Curves.elasticOut),
    );

    _textFadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _textFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textFadeController, curve: Curves.easeIn),
    );

    _logoFadeController.forward();
    _logoScaleController.forward();
    
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _textFadeController.forward();
    });

    // ⏱️ ३ सेकंदांचा डिस्प्ले टाइमर (नेव्हिगेशनचा निर्णय AppRouter चे redirect स्वतः घेईल)
    Timer(const Duration(milliseconds: 3000), () {
      if (mounted) {
        context.go('/welcome');
      }
    });
  }

  @override
  void dispose() {
    _logoFadeController.dispose();
    _logoScaleController.dispose();
    _textFadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Stack(
        children: [
          // Background Vignette Canvas
          Positioned.fill(
            child: CustomPaint(
              painter: SplashBackgroundVignettePainter(),
            ),
          ),

          // Center Application Identity Structure Hub
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedBuilder(
                  animation: _logoScaleController,
                  builder: (context, child) {
                    return ScaleTransition(
                      scale: _logoScaleAnimation,
                      child: FadeTransition(
                        opacity: _logoFadeAnimation,
                        child: Container(
                          height: 120,
                          width: 120,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                            ),
                            borderRadius: BorderRadius.circular(32),
                            border: Border.all(color: Colors.white12, width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.6),
                                blurRadius: 24,
                                spreadRadius: 2,
                                offset: const Offset(0, 12),
                              )
                            ],
                          ),
                          child: const Icon(
                            Icons.menu_book_rounded, 
                            size: 60, 
                            color: Color(0xFF38BDF8),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 28),

                FadeTransition(
                  opacity: _textFadeAnimation,
                  child: const Column(
                    children: [
                      Text(
                        'Khatabook',
                        style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.5),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Smart Ledger Engine',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF64748B), letterSpacing: 1.5),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Core System Footer Sign off
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _textFadeAnimation,
              child: const Text(
                'SECURE MULTI-TENANT ARCHITECTURE',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF334155), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2.0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SplashBackgroundVignettePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    final Paint paint = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 0.85,
        colors: [
          const Color(0xFF1E293B),
          const Color(0xFF0F172A),
          const Color(0xFF080B10),
        ],
        stops: const [0.0, 0.6, 1.0],
      ).createShader(rect);

    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
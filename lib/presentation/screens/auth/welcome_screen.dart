
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with TickerProviderStateMixin {
  late AnimationController _floatController;
  late AnimationController _fadeController;
  late AnimationController _pulseController;
  late AnimationController _planeFlightController;

  late Animation<double> _floatAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _planeFlightAnimation;

  // 🔄 Processing States for 3-Second Professional Loading Flow
  bool _isScreenLoading = false;
  double _loadingProgress = 0.0;
  Timer? _progressTimer;

  // 🏪 Khatabook App Core Live Simulation Stream Data
  final List<Map<String, String>> _shopLiveActivities = [
    {
      "userName": "Yash Matre",
      "message": "Sent ₹1,500 via UPI for Bill #802",
      "ownerResponse": "Received! Ledger balance updated in Khatabook."
    },
    {
      "userName": "Bjrang Yedure",
      "message": "Requested ₹3,500 credit limit approval",
      "ownerResponse": "Approved! Credit logged securely on Khatabook."
    },
    {
      "userName": "Ashish Narwade",
      "message": "Cleared old pending balance of ₹5,000",
      "ownerResponse": "Transaction Closed! Your Khatabook balance is ₹0.00"
    }
  ];

  int _currentActivityIndex = 0;
  Timer? _ecosystemTimer;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _floatAnimation = Tween<double>(begin: -6.0, end: 6.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // ✈️ Curved Zig-Zag Airplane Flight Controller
    _planeFlightController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();
    _planeFlightAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _planeFlightController, curve: Curves.easeInOut),
    );

    _ecosystemTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted && !_isScreenLoading) {
        setState(() {
          _currentActivityIndex = (_currentActivityIndex + 1) % _shopLiveActivities.length;
          _planeFlightController.forward(from: 0.0);
        });
      }
    });

    _fadeController.forward();
  }

  @override
  void dispose() {
    _ecosystemTimer?.cancel();
    _progressTimer?.cancel();
    _floatController.dispose();
    _fadeController.dispose();
    _pulseController.dispose();
    _planeFlightController.dispose();
    super.dispose();
  }

  // ⚡ Professional Exact 3-Second Sequential Action Gate Loader
  void _triggerProfessionalOnboardingFlow() {
    if (_isScreenLoading) return;

    setState(() {
      _isScreenLoading = true;
      _loadingProgress = 0.0;
    });

    // ⏱️ ३ सेकंदांसाठी ३० स्टेप्स (प्रत्येक स्टेप १००ms) = ३०००ms
    const int totalSteps = 30;
    int currentStep = 0;

    _progressTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      currentStep++;
      if (mounted) {
        setState(() {
          _loadingProgress = currentStep / totalSteps;
        });
      }

      if (currentStep >= totalSteps) {
        _progressTimer?.cancel();
        if (mounted) {
          context.go('/login');
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 1024;

    return Scaffold(
      backgroundColor: const Color(0xFF070A0F),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _triggerProfessionalOnboardingFlow, // Screen Tap Trigger (Button Removed)
        child: Stack(
          children: [
            // 🖤 1. DARK CONCRETE STUDIO SPOTLIGHT BACKGROUND
            Positioned.fill(
              child: CustomPaint(
                painter: ConcreteStudioBackgroundPainter(),
              ),
            ),

            // 🔤 2. PRINTED "KHATABOOK" WALL WATERMARK TEXT
            Positioned.fill(
              child: Center(
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'KHATABOOK',
                      style: TextStyle(
                        fontSize: 160,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 14,
                        color: Colors.white.withOpacity(0.02),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // 📱 3. IMMERSIVE ENVIRONMENT STACK CONTAINER
            SafeArea(
              child: AnimatedBuilder(
                animation: _fadeController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _fadeAnimation.value,
                    child: Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                        child: Flex(
                          direction: isDesktop ? Axis.horizontal : Axis.vertical,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // 🏪 A. LIVE KHATABOOK APP ECOSYSTEM HUB
                            Container(
                              width: isDesktop ? size.width * 0.52 : double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 12.0),
                              child: _buildSeamlessShopEcosystem(isDesktop),
                            ),
                            
                            if (isDesktop) const SizedBox(width: 56) else const SizedBox(height: 40),

                            // 🎴 B. WELCOME CONFIGURATION TERMINAL CARD
                            Container(
                              width: isDesktop ? 390 : double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 12.0),
                              child: _buildSeamlessWelcomeForm(context),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🏪 LIVE KHATABOOK APP ECOSYSTEM
  Widget _buildSeamlessShopEcosystem(bool isDesktop) {
    final currentActivity = _shopLiveActivities[_currentActivityIndex];

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: isDesktop ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: isDesktop ? MainAxisAlignment.start : MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF0066CC).withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF0066CC).withOpacity(0.3)),
              ),
              child: const Icon(Icons.menu_book_rounded, size: 28, color: Color(0xFF38BDF8)),
            ),
            const SizedBox(width: 14),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Khatabook App',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.5),
                ),
                Text(
                  'Smart Digital Ledger Engine',
                  style: TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.bold),
                ),
              ],
            )
          ],
        ),
        const SizedBox(height: 32),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'KHATABOOK REALTIME NETWORK',
              style: TextStyle(color: Colors.white60, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1),
            ),
            FadeTransition(
              opacity: _pulseAnimation,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF10B981)),
                ),
                child: Row(
                  children: [
                    CircleAvatar(radius: 3, backgroundColor: _isScreenLoading ? Colors.amber : const Color(0xFF10B981)),
                    const SizedBox(width: 6),
                    Text(
                      _isScreenLoading ? 'HOLD SYSTEM' : 'ZIG-ZAG BEAM ACTIVE', 
                      style: TextStyle(color: _isScreenLoading ? Colors.amber : const Color(0xFF10B981), fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
        const SizedBox(height: 24),

        SizedBox(
          height: 160,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildKhatabookAppNode(),

              Expanded(
                child: AnimatedBuilder(
                  animation: _planeFlightController,
                  builder: (context, child) {
                    return CustomPaint(
                      size: const Size(double.infinity, 120),
                      painter: DashedZigZagAirplanePathPainter(_planeFlightAnimation.value, isPaused: _isScreenLoading),
                    );
                  },
                ),
              ),

              AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: _buildFullBodyCustomerVectorNode(
                  key: ValueKey<String>(currentActivity["userName"]!),
                  userName: currentActivity["userName"]!,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),

        AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          transitionBuilder: (child, anim) => FadeTransition(
            opacity: anim,
            child: SlideTransition(
              position: Tween<Offset>(begin: const Offset(0.0, 0.04), end: Offset.zero).animate(anim),
              child: child,
            ),
          ),
          child: Column(
            key: ValueKey<int>(_currentActivityIndex),
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSeamlessMessageRow(
                sender: currentActivity["userName"]!,
                msg: currentActivity["message"]!,
                isOwner: false,
              ),
              const SizedBox(height: 10),
              _buildSeamlessMessageRow(
                sender: "Khatabook Ledger System",
                msg: currentActivity["ownerResponse"]!,
                isOwner: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildKhatabookAppNode() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 80,
          width: 80,
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFF38BDF8), width: 2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF38BDF8).withOpacity(0.35),
                blurRadius: 18,
                spreadRadius: 2,
              )
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [const Color(0xFF38BDF8).withOpacity(0.2), Colors.transparent],
                  ),
                ),
              ),
              const Icon(Icons.account_balance_wallet_rounded, color: Color(0xFF38BDF8), size: 38),
            ],
          ),
        ),
        const SizedBox(height: 8),
        const Text('Khatabook App', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
        const Text('Ledger Hub', style: TextStyle(color: Color(0xFF64748B), fontSize: 10, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildFullBodyCustomerVectorNode({required Key key, required String userName}) {
    return Column(
      key: key,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 100,
          width: 80,
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFF38BDF8), width: 2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF38BDF8).withOpacity(0.3),
                blurRadius: 16,
                spreadRadius: 2,
              )
            ],
          ),
          child: CustomPaint(
            size: const Size(80, 100),
            painter: FullBodyCharacterVectorPainter(),
          ),
        ),
        const SizedBox(height: 8),
        Text(userName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
        const Text('Verified User', style: TextStyle(color: Color(0xFF38BDF8), fontSize: 10, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildSeamlessMessageRow({required String sender, required String msg, required bool isOwner}) {
    return Row(
      children: [
        Icon(
          isOwner ? Icons.verified_user_rounded : Icons.account_circle_rounded,
          color: isOwner ? const Color(0xFF38BDF8) : const Color(0xFF10B981),
          size: 16,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: RichText(
            text: TextSpan(
              text: '$sender: ',
              style: TextStyle(color: isOwner ? const Color(0xFF38BDF8) : const Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 12),
              children: [
                TextSpan(text: msg, style: const TextStyle(color: Color(0xFFCBD5E1), fontWeight: FontWeight.normal)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSeamlessWelcomeForm(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Ready to log?',
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 0.5),
        ),
        const SizedBox(height: 4),
        const Text(
          'Khatabook',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.5),
        ),
        const SizedBox(height: 32),

        AnimatedBuilder(
          animation: _floatController,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _floatAnimation.value),
              child: Center(
                child: Container(
                  height: 110,
                  width: 110,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                    ),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: _isScreenLoading ? Colors.amber.withOpacity(0.5) : Colors.white12, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.6),
                        blurRadius: 20,
                        spreadRadius: 2,
                        offset: const Offset(0, 10),
                      )
                    ],
                  ),
                  child: Icon(
                    Icons.menu_book_rounded, 
                    size: 56, 
                    color: _isScreenLoading ? Colors.amber : const Color(0xFF38BDF8),
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 36),

        Text(
          _isScreenLoading ? 'Establishing Secure Protocol...' : 'Welcome to Khatabook',
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          _isScreenLoading 
              ? 'Synchronizing local databases, encryption layers, and tenant parameters. Please stand by.'
              : 'Your intelligent, multi-tenant digital ledger engine. Secure your credits and streamline accounting effortlessly.',
          style: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8), height: 1.5),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),

        // ⚡ Get Started Button Removed - Direct Loading Indicator View
        if (_isScreenLoading) ...[
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: _loadingProgress,
                  minHeight: 8,
                  backgroundColor: Colors.white12,
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Loading Verification Stack... ${( _loadingProgress * 100).toInt()}%',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF10B981), fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 0.5),
              ),
            ],
          ),
        ] else ...[
          // Subtle Tap Indicator Text
          Text(
            'Tap anywhere on screen to continue',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: const Color(0xFF10B981).withOpacity(0.8),
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ],
        const SizedBox(height: 24),

        Text(
          'By continuing you agree to our Terms & Conditions.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white.withOpacity(0.25), fontSize: 11),
        ),
      ],
    );
  }
}

// 🖤 DARK CONCRETE STUDIO BACKGROUND PAINTER
class ConcreteStudioBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;

    final Paint backgroundPaint = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 0.95,
        colors: const [
          Color(0xFF262C36),
          Color(0xFF11151C),
          Color(0xFF080B10),
        ],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(rect);

    canvas.drawRect(rect, backgroundPaint);

    final Paint floorPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.transparent,
          Colors.black.withOpacity(0.4),
          Colors.black.withOpacity(0.85),
        ],
        stops: const [0.6, 0.85, 1.0],
      ).createShader(rect);

    canvas.drawRect(rect, floorPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// 👤 FIXED FULL BODY VECTOR CHARACTER PAINTER
class FullBodyCharacterVectorPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double cx = size.width / 2;

    final hairPaint = Paint()..color = const Color(0xFF1E293B);
    final skinPaint = Paint()..color = const Color(0xFFFDBA74);
    final shirtPaint = Paint()..color = const Color(0xFF9A3412); // Brown T-Shirt
    final pantsPaint = Paint()..color = const Color(0xFF38BDF8); // Light Blue Pants
    final shoePaint = Paint()..color = const Color(0xFF78350F);
    final phonePaint = Paint()..color = const Color(0xFF0F172A);

    // 1️⃣ Head & Hair
    canvas.drawCircle(Offset(cx, 16), 9, hairPaint);
    canvas.drawCircle(Offset(cx, 18), 7.5, skinPaint);

    // 2️⃣ T-Shirt (Torso)
    final RRect torso = RRect.fromRectAndRadius(
      Rect.fromLTWH(cx - 10, 26, 20, 26),
      const Radius.circular(6),
    );
    canvas.drawRRect(torso, shirtPaint);

    // 3️⃣ Left Arm (Pocket)
    final Path leftArm = Path()
      ..moveTo(cx - 10, 28)
      ..lineTo(cx - 15, 42)
      ..lineTo(cx - 8, 48);

    final armStrokePaint = Paint()
      ..color = const Color(0xFF9A3412)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    canvas.drawPath(leftArm, armStrokePaint);

    // 4️⃣ Right Arm (Holding Smartphone)
    final Path rightArm = Path()
      ..moveTo(cx + 10, 28)
      ..lineTo(cx + 18, 38)
      ..lineTo(cx + 22, 34);

    canvas.drawPath(rightArm, armStrokePaint);

    // Smartphone
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(cx + 18, 28, 8, 12), const Radius.circular(2)),
      phonePaint,
    );

    // 5️⃣ Pants (Legs)
    final Path legs = Path()
      ..moveTo(cx - 9, 52)
      ..lineTo(cx - 10, 86)
      ..lineTo(cx - 2, 86)
      ..lineTo(cx, 58)
      ..lineTo(cx + 2, 86)
      ..lineTo(cx + 10, 86)
      ..lineTo(cx + 9, 52)
      ..close();
    canvas.drawPath(legs, pantsPaint);

    // 6️⃣ Shoes
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(cx - 12, 86, 9, 5), const Radius.circular(2)), shoePaint);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(cx + 3, 86, 9, 5), const Radius.circular(2)), shoePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ✈️ DASHED ARC LINE WITH WAVY ZIG-ZAG AIRPLANE PAINTER
class DashedZigZagAirplanePathPainter extends CustomPainter {
  final double progress;
  final bool isPaused;

  DashedZigZagAirplanePathPainter(this.progress, {this.isPaused = false});

  @override
  void paint(Canvas canvas, Size size) {
    final startPoint = Offset(size.width - 10, size.height / 2);
    final endPoint = Offset(10, size.height / 2);
    final controlPoint = Offset(size.width / 2, size.height * 0.05);

    final Path mainPath = Path()
      ..moveTo(startPoint.dx, startPoint.dy)
      ..quadraticBezierTo(controlPoint.dx, controlPoint.dy, endPoint.dx, endPoint.dy);

    final Paint dashPaint = Paint()
      ..color = isPaused ? Colors.amber.withOpacity(0.4) : const Color(0xFF38BDF8).withOpacity(0.4)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final metrics = mainPath.computeMetrics().first;
    final double pathLength = metrics.length;
    const double dashWidth = 6.0;
    const double dashSpace = 4.0;
    double distance = 0.0;

    while (distance < pathLength) {
      final double end = math.min(distance + dashWidth, pathLength);
      canvas.drawPath(metrics.extractPath(distance, end), dashPaint);
      distance += dashWidth + dashSpace;
    }

    final double t = progress;
    final double u = 1 - t;

    final double baseX = (u * u * startPoint.dx) + (2 * u * t * controlPoint.dx) + (t * t * endPoint.dx);
    final double baseY = (u * u * startPoint.dy) + (2 * u * t * controlPoint.dy) + (t * t * endPoint.dy);

    final double dx = 2 * (1 - t) * (controlPoint.dx - startPoint.dx) + 2 * t * (endPoint.dx - controlPoint.dx);
    final double dy = 2 * (1 - t) * (controlPoint.dy - startPoint.dy) + 2 * t * (endPoint.dy - controlPoint.dy);

    final double zigZagAmplitude = 12.0;
    final double zigZagFrequency = 4.0 * math.pi;
    final double waveOffset = math.sin(progress * zigZagFrequency) * zigZagAmplitude;

    final double baseAngle = math.atan2(dy, dx);
    final double perpAngle = baseAngle + (math.pi / 2);

    final double currentX = baseX + (math.cos(perpAngle) * waveOffset);
    final double currentY = baseY + (math.sin(perpAngle) * waveOffset);

    final double wobbleAngle = math.cos(progress * zigZagFrequency) * 0.35;
    final double finalAngle = baseAngle + wobbleAngle;

    canvas.save();
    canvas.translate(currentX, currentY);
    canvas.rotate(finalAngle - math.pi);

    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(Icons.send_rounded.codePoint),
        style: TextStyle(
          fontSize: 22,
          fontFamily: Icons.send_rounded.fontFamily,
          color: isPaused ? Colors.amber : const Color(0xFF38BDF8),
          shadows: [
            Shadow(
              color: (isPaused ? Colors.amber : const Color(0xFF38BDF8)).withOpacity(0.9),
              blurRadius: 12,
            )
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(canvas, Offset(-textPainter.width / 2, -textPainter.height / 2));
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant DashedZigZagAirplanePathPainter oldDelegate) => true;
}
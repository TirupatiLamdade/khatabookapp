import 'dart:async';
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
  late AnimationController _signalLineController;

  late Animation<double> _floatAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _signalLineAnimation;

  // 🔄 Processing States for 5-Second Professional Loading Flow
  bool _isScreenLoading = false;
  double _loadingProgress = 0.0;
  Timer? _progressTimer;

  // 🏪 Live Dynamic Shop Operations Simulation Stream Data
  final List<Map<String, String>> _shopLiveActivities = [
    {
      "type": "payment",
      "userName": "Rajesh Sharma",
      "userAvatar": "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200",
      "message": "Sent ₹1,500 via UPI for Bill #802",
      "ownerResponse": "Received! Ledger balance sheet updated automatically."
    },
    {
      "type": "credit",
      "userName": "Pooja Deshmukh",
      "userAvatar": "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200",
      "message": "Requested ₹3,500 credit limit approval",
      "ownerResponse": "Approved. Credit entry logged securely on control desk."
    },
    {
      "type": "clearance",
      "userName": "Vikram Malhotra",
      "userAvatar": "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200",
      "message": "Cleared old pending balance of ₹5,000",
      "ownerResponse": "Transaction Closed! Your current balance is ₹0.00"
    }
  ];

  int _currentActivityIndex = 0;
  Timer? _ecosystemTimer;

  // Merchant Avatar Reference
  final String _shopOwnerAvatar = "https://images.unsplash.com/photo-1560250097-0b93528c311a?w=200";

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
    _floatAnimation = Tween<double>(begin: -8.0, end: 8.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _signalLineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat();
    _signalLineAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _signalLineController, curve: Curves.linear),
    );

    _ecosystemTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (mounted && !_isScreenLoading) {
        setState(() {
          _currentActivityIndex = (_currentActivityIndex + 1) % _shopLiveActivities.length;
          _signalLineController.forward(from: 0.0);
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
    _signalLineController.dispose();
    super.dispose();
  }

  // ⚡ Professional 5-Second Sequential Action Gate Loader
  void _triggerProfessionalOnboardingFlow() {
    if (_isScreenLoading) return;

    setState(() {
      _isScreenLoading = true;
      _loadingProgress = 0.0;
    });

    const int totalSteps = 50; // Updates every 100ms for high-precision progress updates
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
        // Fully complete, redirect smoothly to authentication space routing parameters
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
      body: Stack(
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
                          // 🏪 A. LIVE ECOSYSTEM HUB
                          Container(
                            width: isDesktop ? size.width * 0.52 : double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 12.0),
                            child: _buildSeamlessShopEcosystem(isDesktop),
                          ),
                          
                          if (isDesktop) const SizedBox(width: 64) else const SizedBox(height: 48),

                          // 🎴 B. WELCOME CONFIGURATION TERMINAL FLOW INTERACTIVE CARD
                          Container(
                            width: isDesktop ? 400 : double.infinity,
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
    );
  }

  // 🏪 SEAMLESS LIVE SHOP ECOSYSTEM Layout
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
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF0066CC).withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF0066CC).withOpacity(0.3)),
              ),
              child: const Icon(Icons.storefront_rounded, size: 32, color: Color(0xFF38BDF8)),
            ),
            const SizedBox(width: 16),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Khatabook',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.5),
                ),
                Text(
                  'Live Business Matrix Hub',
                  style: TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.bold),
                ),
              ],
            )
          ],
        ),
        const SizedBox(height: 40),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'LIVE LEDGER COMMUNICATOR',
              style: TextStyle(color: Colors.white60, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1),
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
                      _isScreenLoading ? 'HOLD SYSTEM' : 'SYNCING LIVE', 
                      style: TextStyle(color: _isScreenLoading ? Colors.amber : const Color(0xFF10B981), fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
        const SizedBox(height: 24),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSeamlessProfileNode(
              title: 'Shop Owner',
              subtitle: 'Balaji Stores',
              imgUrl: _shopOwnerAvatar,
              borderColor: const Color(0xFF0066CC),
            ),

            Expanded(
              child: AnimatedBuilder(
                animation: _signalLineController,
                builder: (context, child) {
                  return CustomPaint(
                    size: const Size(double.infinity, 30),
                    painter: MicroSignalLinePainter(_signalLineAnimation.value, isPaused: _isScreenLoading),
                  );
                },
              ),
            ),

            AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: _buildSeamlessProfileNode(
                key: ValueKey<String>(currentActivity["userName"]!),
                title: currentActivity["userName"]!,
                subtitle: 'Active User',
                imgUrl: currentActivity["userAvatar"]!,
                borderColor: const Color(0xFF10B981),
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),

        AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          transitionBuilder: (child, anim) => FadeTransition(opacity: anim, child: SlideTransition(position: Tween<Offset>(begin: const Offset(0.0, 0.04), end: Offset.zero).animate(anim), child: child)),
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
                sender: "Shop Owner Response",
                msg: currentActivity["ownerResponse"]!,
                isOwner: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSeamlessProfileNode({Key? key, required String title, required String subtitle, required String imgUrl, required Color borderColor}) {
    return Column(
      key: key,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: _isScreenLoading ? Colors.amber.withOpacity(0.6) : borderColor, width: 2.5),
            boxShadow: [
              BoxShadow(color: (_isScreenLoading ? Colors.amber : borderColor).withOpacity(0.3), blurRadius: 16, spreadRadius: 2)
            ],
          ),
          child: CircleAvatar(
            radius: 38,
            backgroundColor: const Color(0xFF1E293B),
            backgroundImage: NetworkImage(imgUrl),
          ),
        ),
        const SizedBox(height: 10),
        Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
        const SizedBox(height: 2),
        Text(subtitle, style: const TextStyle(color: Color(0xFF64748B), fontSize: 11, fontWeight: FontWeight.bold)),
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
              style: TextStyle(color: isOwner ? const Color(0xFF38BDF8) : const Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 13),
              children: [
                TextSpan(text: msg, style: const TextStyle(color: Color(0xFFCBD5E1), fontWeight: FontWeight.normal)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // 🎴 WELCOME ACTIONS MODULE WITH TIMED PROGRESS HUD MATRIX INDICATOR
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

        // ⚡ DYNAMIC CONDITIONAL ELEVATED LOADER INITIATOR BUTTON GATE INTERFACE
        if (_isScreenLoading) ...[
          // Professional Linear Loading Progress Block
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: _loadingProgress,
                  minHeight: 8,
                  backgroundColor: Colors.white12,
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF10B981)), // Green Fill Bar
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
          // Action Gate Core Click Trigger
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _triggerProfessionalOnboardingFlow,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      elevation: 6,
                      shadowColor: const Color(0xFF10B981).withOpacity(0.35),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                    ),
                    child: const Text(
                      'Get Started',
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 0.3),
                    ),
                  ),
                ),
              );
            },
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
        colors: [
          const Color(0xFF262C36),
          const Color(0xFF11151C),
          const Color(0xFF080B10),
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

// 🎨 ANIMATED SIGNAL DATA FLOW BEAM PAINTER
class MicroSignalLinePainter extends CustomPainter {
  final double animationProgress;
  final bool isPaused;
  MicroSignalLinePainter(this.animationProgress, {this.isPaused = false});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint linePaint = Paint()
      ..color = isPaused ? Colors.amber.withOpacity(0.2) : const Color(0xFF334155)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final Offset startPoint = Offset(10, size.height / 2);
    final Offset endPoint = Offset(size.width - 10, size.height / 2);

    canvas.drawLine(startPoint, endPoint, linePaint);

    final Paint signalPaint = Paint()
      ..color = isPaused ? Colors.amber : const Color(0xFF38BDF8)
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    final double totalDistance = size.width - 20;

    for (int i = 0; i < 3; i++) {
      double currentPosOffset = (animationProgress * totalDistance) - (i * 15);
      if (currentPosOffset < 0) currentPosOffset += totalDistance;
      if (currentPosOffset > totalDistance) currentPosOffset -= totalDistance;

      canvas.drawCircle(
        Offset(startPoint.dx + currentPosOffset, size.height / 2),
        4.0,
        signalPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant MicroSignalLinePainter oldDelegate) => true;
}
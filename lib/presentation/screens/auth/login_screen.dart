import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  
  // Input Controllers
  final _identityController = TextEditingController(); 
  final _passwordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Screen View States
  bool _isSignUpMode = false;
  bool _isPhoneAuthMode = false; 
  bool _isForgotPasswordMode = false;
  bool _isResetPhoneVerified = false;
  bool _isNewPhoneUser = false;
  bool _obscurePassword = true; 
  
  // Loading Flags
  bool _isFormLoading = false;
  bool _isGoogleLoading = false;
  bool _isOtpLoading = false;
  
  bool _showOtpVerificationField = false;
  ConfirmationResult? _webConfirmationResult;
  
  // ⏱️ Timer Variables for 1-Min OTP Expiry
  Timer? _otpTimer;
  int _otpSecondsRemaining = 60;
  bool _isOtpExpired = false;

  // 🎨 Animation Controllers
  late AnimationController _ambientController;
  late AnimationController _pulseController;
  
  // 📊 Live Desktop Mock Activity Feed
  final List<String> _liveActivityFeed = [
    "Rajesh Sharma added ₹500 credit",
    "Suresh Patil paid ₹1,200 balance",
    "New transaction linked to Shop Ledger",
    "Vijay Kumar requested digital receipt",
    "Aniket Deshmukh cleared pending bill"
  ];
  int _currentFeedIndex = 0;
  Timer? _feedTimer;

  @override
  void initState() {
    super.initState();
    _ambientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    // Live Feed Cycle for Left Desktop Panel
    _feedTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        setState(() {
          _currentFeedIndex = (_currentFeedIndex + 1) % _liveActivityFeed.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _otpTimer?.cancel();
    _feedTimer?.cancel();
    _ambientController.dispose();
    _pulseController.dispose();
    _identityController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // ⏱️ Starts 60-Second OTP Countdown Timer
  void _startOtpCountdownTimer() {
    _otpTimer?.cancel();
    setState(() {
      _otpSecondsRemaining = 60;
      _isOtpExpired = false;
    });

    _otpTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_otpSecondsRemaining > 0) {
        setState(() => _otpSecondsRemaining--);
      } else {
        _otpTimer?.cancel();
        setState(() => _isOtpExpired = true);
        _showTopNotification(context, 'OTP expired! Auto-reloading gateway...', isError: true);
        
        // Auto Reload screen after expiration
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) _resetToDefaultCredentialsMode();
        });
      }
    });
  }

  // 🔔 Universal Top Overlay Notification Engine
  void _showTopNotification(BuildContext context, String message, {bool isError = false}) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 30,
        left: 24,
        right: 24,
        child: Material(
          color: Colors.transparent,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: isError ? const Color(0xFFDC2626) : const Color(0xFF16A34A),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3), 
                  blurRadius: 12, 
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Row(
              children: [
                Icon(
                  isError ? Icons.report_problem_rounded : Icons.check_circle_rounded, 
                  color: Colors.white,
                  size: 22,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    message, 
                    style: const TextStyle(
                      color: Colors.white, 
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    overlay.insert(overlayEntry);
    Future.delayed(const Duration(seconds: 4), () => overlayEntry.remove());
  }

  // 👥 INSTAGRAM-STYLE MULTI-ACCOUNT SELECTOR BOTTOM SHEET
  void _showMultiAccountSelector(List<QueryDocumentSnapshot<Map<String, dynamic>>> accounts) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E293B),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select Linked Account',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const Text(
                'Multiple accounts are linked with this phone number. Choose one to log in or create a new one:',
                style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
              ),
              const SizedBox(height: 16),
              Divider(color: Colors.white.withOpacity(0.1)),
              
              ...accounts.map((doc) {
                final data = doc.data();
                final username = data['username'] ?? 'User';
                final email = data['email'] ?? '';
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 4),
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFF0066CC),
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  title: Text(
                    username, 
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                  ),
                  subtitle: Text(
                    email, 
                    style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12)
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white54, size: 16),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _isPhoneAuthMode = false;
                      _identityController.text = username;
                    });
                    _showTopNotification(context, 'Account selected: $username. Enter your password.');
                  },
                );
              }).toList(),

              const SizedBox(height: 8),
              Divider(color: Colors.white.withOpacity(0.1)),
              const SizedBox(height: 8),

              // 🆕 "+ Create New Account" Option
              ListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFF10B981),
                  child: Icon(Icons.add_rounded, color: Colors.white, size: 24),
                ),
                title: const Text(
                  'Create New Account',
                  style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 15),
                ),
                subtitle: const Text(
                  'Link a brand new account to this mobile number',
                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                ),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFF10B981), size: 16),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _isNewPhoneUser = true;
                  });
                  _showTopNotification(context, 'Enter Email, Username and Password to register new account.');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // 1️⃣ SIGNUP ROUTINE
  Future<void> _executeSecureSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isFormLoading = true);
    final db = FirebaseFirestore.instance;

    try {
      final usernameInput = _usernameController.text.trim().toLowerCase();
      final checkUsername = await db.collection('users').where('username', isEqualTo: usernameInput).get();

      if (checkUsername.docs.isNotEmpty) {
        _showTopNotification(context, 'Username is already taken. Please choose another.', isError: true);
        setState(() => _isFormLoading = false);
        return;
      }

      UserCredential credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim().toLowerCase(),
        password: _passwordController.text.trim(),
      );

      await credential.user!.sendEmailVerification();

      await db.collection('users').doc(credential.user!.uid).set({
        'uid': credential.user!.uid,
        'fullName': _fullNameController.text.trim(),
        'username': usernameInput,
        'email': _emailController.text.trim().toLowerCase(),
        'phone': _phoneController.text.trim(),
        'authProvider': 'credentials',
        'createdAt': FieldValue.serverTimestamp(),
      });

      _showTopNotification(context, 'Registration successful! Verification email sent.');
      _resetToDefaultCredentialsMode();
    } on FirebaseAuthException catch (e) {
      _showTopNotification(context, e.message ?? 'Registration failed.', isError: true);
    } finally {
      setState(() => _isFormLoading = false);
    }
  }

  // 2️⃣ UNIFIED LOGIN LOGIC
  Future<void> _executeUnifiedLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isFormLoading = true);
    final db = FirebaseFirestore.instance;
    final input = _identityController.text.trim().toLowerCase();
    String? resolvedEmail;

    try {
      if (input.contains('@')) {
        resolvedEmail = input;
      } else {
        final queryUsername = await db.collection('users').where('username', isEqualTo: input).get();

        if (queryUsername.docs.isNotEmpty) {
          resolvedEmail = queryUsername.docs.first.data()['email'];
        } else {
          final queryPhone = await db.collection('users').where('phone', isEqualTo: input).get();

          if (queryPhone.docs.length > 1) {
            setState(() => _isFormLoading = false);
            _showMultiAccountSelector(queryPhone.docs);
            return;
          } else if (queryPhone.docs.length == 1) {
            resolvedEmail = queryPhone.docs.first.data()['email'];
          }
        }
      }

      if (resolvedEmail == null || resolvedEmail.isEmpty) {
        _showTopNotification(context, 'Invalid credentials entered. Auto-reloading fields...', isError: true);
        
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) _resetToDefaultCredentialsMode();
        });
        return;
      }

      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: resolvedEmail,
        password: _passwordController.text.trim(),
      );

      await userCredential.user!.reload();
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null && !currentUser.emailVerified) {
        _showTopNotification(context, 'Please verify your email address before log in.', isError: true);
        await FirebaseAuth.instance.signOut();
        setState(() => _isFormLoading = false);
        return;
      }

      _showTopNotification(context, 'Login verified successfully!');
      context.go('/processing', extra: {'email': resolvedEmail});
    } on FirebaseAuthException catch (e) {
      _showTopNotification(context, 'Invalid password or user record. Auto-reloading...', isError: true);
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) _resetToDefaultCredentialsMode();
      });
    } finally {
      setState(() => _isFormLoading = false);
    }
  }

  // 3️⃣ GOOGLE AUTHENTICATION
  Future<void> _executeGoogleAuthentication() async {
    setState(() => _isGoogleLoading = true);
    final db = FirebaseFirestore.instance;

    try {
      GoogleAuthProvider googleProvider = GoogleAuthProvider();
      googleProvider.addScope('email');
      googleProvider.addScope('profile');
      
      UserCredential userCredential = await FirebaseAuth.instance.signInWithPopup(googleProvider);
      User? user = userCredential.user;

      if (user != null) {
        final docRef = db.collection('users').doc(user.uid);
        final docSnapshot = await docRef.get();

        if (!docSnapshot.exists) {
          await docRef.set({
            'uid': user.uid,
            'fullName': user.displayName ?? 'Google Identity',
            'username': user.email!.split('@')[0].toLowerCase(),
            'email': user.email!.toLowerCase(),
            'phone': user.phoneNumber ?? '',
            'authProvider': 'google',
            'createdAt': FieldValue.serverTimestamp(),
          });
        }

        _showTopNotification(context, 'Google Sign-In completed successfully!');
        context.go('/processing', extra: {'email': user.email!});
      }
    } catch (e) {
      _showTopNotification(context, 'Google Sign-In failed.', isError: true);
    } finally {
      setState(() => _isGoogleLoading = false);
    }
  }

  // 4️⃣ PHONE OTP ENGINE WITH 1-MIN TIMER
  Future<void> _executePhoneVerification() async {
    if (_phoneController.text.length != 10) {
      _showTopNotification(context, 'Please enter a valid 10-digit phone number.', isError: true);
      return;
    }

    final db = FirebaseFirestore.instance;

    try {
      if (kIsWeb) {
        if (!_showOtpVerificationField) {
          setState(() => _isOtpLoading = true);
          _webConfirmationResult = await FirebaseAuth.instance.signInWithPhoneNumber(
            '+91${_phoneController.text.trim()}',
          );
          setState(() {
            _showOtpVerificationField = true;
            _isOtpLoading = false;
          });
          _startOtpCountdownTimer();
          _showTopNotification(context, 'SMS OTP sent! Valid for 60 seconds.');
        } else {
          if (_isOtpExpired) {
            _showTopNotification(context, 'OTP Expired! Reloading screen...', isError: true);
            _resetToDefaultCredentialsMode();
            return;
          }

          if (_otpController.text.trim().isEmpty) {
            _showTopNotification(context, 'Please enter the 6-digit SMS OTP.', isError: true);
            return;
          }

          setState(() => _isOtpLoading = true);
          await _webConfirmationResult!.confirm(_otpController.text.trim());
          _otpTimer?.cancel();
          
          if (_isForgotPasswordMode) {
            setState(() {
              _isResetPhoneVerified = true;
              _isOtpLoading = false;
            });
            return;
          }

          final query = await db.collection('users').where('phone', isEqualTo: _phoneController.text.trim()).get();

          if (query.docs.isNotEmpty) {
            setState(() => _isOtpLoading = false);
            _showMultiAccountSelector(query.docs);
          } else {
            _showTopNotification(context, 'No account linked to this number. Complete your profile setup.');
            setState(() {
              _isNewPhoneUser = true;
              _isOtpLoading = false;
            });
          }
        }
      }
    } catch (e) {
      _showTopNotification(context, 'Invalid OTP or network timeout. Auto-reloading...', isError: true);
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) _resetToDefaultCredentialsMode();
      });
    } finally {
      setState(() => _isOtpLoading = false);
    }
  }

  // 5️⃣ FORGOT PASSWORD & UPDATE ENGINE
  Future<void> _executeSaveNewPassword() async {
    final p1 = _newPasswordController.text.trim();
    final p2 = _confirmPasswordController.text.trim();

    if (p1.isEmpty || p1.length < 6) {
      _showTopNotification(context, 'Password must be at least 6 characters long.', isError: true);
      return;
    }

    if (p1 != p2) {
      _showTopNotification(context, 'Passwords do not match.', isError: true);
      return;
    }

    setState(() => _isFormLoading = true);

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.updatePassword(p1);
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'passwordUpdatedAt': FieldValue.serverTimestamp(),
        });

        _showTopNotification(context, 'New password updated successfully!');
        _resetToDefaultCredentialsMode();
      }
    } catch (e) {
      _showTopNotification(context, 'Failed to update password: $e', isError: true);
    } finally {
      setState(() => _isFormLoading = false);
    }
  }

  void _resetToDefaultCredentialsMode() {
    _otpTimer?.cancel();
    setState(() {
      _isPhoneAuthMode = false;
      _isForgotPasswordMode = false;
      _isResetPhoneVerified = false;
      _isNewPhoneUser = false;
      _isSignUpMode = false;
      _showOtpVerificationField = false;
      _otpSecondsRemaining = 60;
      _isOtpExpired = false;
      _phoneController.clear();
      _otpController.clear();
      _identityController.clear();
      _passwordController.clear();
      _formKey.currentState?.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 1024;
    final isTablet = size.width > 600 && size.width <= 1024;

    final bool staticAnyActiveLoad = _isFormLoading || _isGoogleLoading || _isOtpLoading;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Row(
        children: [
          // 💻 DESKTOP LIVE ANIMATED SIDE PANEL (Shop Profile & Customers Feed)
          if (isDesktop)
            Expanded(
              child: AnimatedBuilder(
                animation: _ambientController,
                builder: (context, child) {
                  return Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          colorScheme.primary,
                          Color.lerp(colorScheme.primary, Colors.deepPurple.shade900, _ambientController.value)!,
                          const Color(0xFF0F172A),
                        ],
                      ),
                    ),
                    padding: const EdgeInsets.all(48.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.storefront_rounded, color: Colors.amber, size: 38),
                            SizedBox(width: 12),
                            Text('Khatabook Smart Engine', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 24),
                        
                        // Shop & Phone Live Status Card
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const CircleAvatar(
                                    backgroundColor: Color(0xFF0066CC),
                                    child: Icon(Icons.business_center, color: Colors.white, size: 20),
                                  ),
                                  const SizedBox(width: 14),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Shree Ganesh Traders', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                                      Text('Linked Phone: +91 9579680911', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13)),
                                    ],
                                  ),
                                  const Spacer(),
                                  FadeTransition(
                                    opacity: _pulseController,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF10B981).withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: const Color(0xFF10B981)),
                                      ),
                                      child: const Row(
                                        children: [
                                          CircleAvatar(radius: 4, backgroundColor: Color(0xFF10B981)),
                                          SizedBox(width: 6),
                                          Text('LIVE SYNC', style: TextStyle(color: Color(0xFF10B981), fontSize: 11, fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              const SizedBox(height: 16),
                              const Divider(color: Colors.white12),
                              const SizedBox(height: 12),

                              // Real-time Scrolling Activity Feed
                              const Text('Live Ledger Activity:', style: TextStyle(color: Colors.amber, fontSize: 12, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 500),
                                child: Row(
                                  key: ValueKey<int>(_currentFeedIndex),
                                  children: [
                                    const Icon(Icons.notifications_active_outlined, color: Colors.white70, size: 16),
                                    const SizedBox(width: 8),
                                    Text(_liveActivityFeed[_currentFeedIndex], style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          
          // 📱 MAIN FORM INTERACTIVE PANEL
          Expanded(
            flex: isDesktop ? 0 : 1,
            child: Container(
              width: isDesktop ? 480 : (isTablet ? size.width * 0.65 : size.width),
              margin: isTablet ? EdgeInsets.symmetric(horizontal: size.width * 0.175, vertical: 32) : EdgeInsets.zero,
              padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 24),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: isTablet ? BorderRadius.circular(16) : BorderRadius.zero,
              ),
              child: Center(
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Top Header Title
                        Text(
                          _isForgotPasswordMode 
                              ? 'Reset Password' 
                              : (_isPhoneAuthMode 
                                  ? (_isNewPhoneUser ? 'Create New Account Setup' : 'Phone Gateway Login') 
                                  : (_isSignUpMode ? 'Register New Account' : 'Smart Ledger Login')), 
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white), 
                          textAlign: TextAlign.center
                        ),
                        const SizedBox(height: 24),

                        // VIEW 1: FORGOT PASSWORD FLOW
                        if (_isForgotPasswordMode) ...[
                          if (!_isResetPhoneVerified) ...[
                            TextFormField(
                              controller: _phoneController,
                              enabled: !staticAnyActiveLoad,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: 'Registered Phone Number',
                                prefixText: '+91 ',
                                prefixStyle: const TextStyle(color: Colors.white),
                                filled: true,
                                fillColor: const Color(0xFF0F172A),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                              ),
                            ),
                            const SizedBox(height: 12),
                            if (_showOtpVerificationField) ...[
                              TextFormField(
                                controller: _otpController,
                                enabled: !staticAnyActiveLoad,
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  labelText: '6-Digit OTP ($_otpSecondsRemaining s remaining)',
                                  filled: true,
                                  fillColor: const Color(0xFF0F172A),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                                ),
                              ),
                              const SizedBox(height: 12),
                            ],
                            SizedBox(
                              height: 48,
                              child: ElevatedButton(
                                onPressed: staticAnyActiveLoad ? null : _executePhoneVerification,
                                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0066CC), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                                child: Text(_showOtpVerificationField ? 'Verify OTP Code' : 'Send Security OTP'),
                              ),
                            ),
                          ] else ...[
                            TextFormField(
                              controller: _newPasswordController,
                              obscureText: true,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: 'Enter New Password',
                                filled: true,
                                fillColor: const Color(0xFF0F172A),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _confirmPasswordController,
                              obscureText: true,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: 'Confirm New Password',
                                filled: true,
                                fillColor: const Color(0xFF0F172A),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 48,
                              child: ElevatedButton(
                                onPressed: staticAnyActiveLoad ? null : _executeSaveNewPassword,
                                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                                child: const Text('Save & Update Password'),
                              ),
                            ),
                          ],
                          const SizedBox(height: 12),
                          
                          // 🏠 Direct "Back to Home" Button
                          OutlinedButton.icon(
                            onPressed: _resetToDefaultCredentialsMode,
                            icon: const Icon(Icons.home_rounded, color: Color(0xFF38BDF8), size: 18),
                            label: const Text('Back to Home / Main Login', style: TextStyle(color: Color(0xFF38BDF8))),
                            style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.white24), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                          ),
                        ]

                        // VIEW 2: PHONE OTP GATEWAY (INCLUDES NEW USER SETUP)
                        else if (_isPhoneAuthMode) ...[
                          if (!_isNewPhoneUser) ...[
                            TextFormField(
                              controller: _phoneController,
                              enabled: !staticAnyActiveLoad,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: 'Mobile Phone Number',
                                prefixText: '+91 ',
                                prefixStyle: const TextStyle(color: Colors.white),
                                filled: true,
                                fillColor: const Color(0xFF0F172A),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                              ),
                            ),
                            const SizedBox(height: 12),
                            if (_showOtpVerificationField) ...[
                              TextFormField(
                                controller: _otpController,
                                enabled: !staticAnyActiveLoad,
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  labelText: '6-Digit SMS OTP ($_otpSecondsRemaining s remaining)',
                                  filled: true,
                                  fillColor: const Color(0xFF0F172A),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                                ),
                              ),
                              const SizedBox(height: 12),
                            ],
                            SizedBox(
                              height: 48,
                              child: ElevatedButton(
                                onPressed: staticAnyActiveLoad ? null : _executePhoneVerification,
                                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0066CC), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                                child: Text(_showOtpVerificationField ? 'Verify OTP Code' : 'Send Verification OTP'),
                              ),
                            ),
                          ] else ...[
                            // New Phone User Setup Form
                            TextFormField(
                              controller: _fullNameController,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: 'Full Legal Name',
                                filled: true,
                                fillColor: const Color(0xFF0F172A),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _usernameController,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: 'Unique Username',
                                filled: true,
                                fillColor: const Color(0xFF0F172A),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _emailController,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: 'Email Address',
                                filled: true,
                                fillColor: const Color(0xFF0F172A),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: 'Set Account Password',
                                filled: true,
                                fillColor: const Color(0xFF0F172A),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 48,
                              child: ElevatedButton(
                                onPressed: staticAnyActiveLoad ? null : _executeSecureSignUp,
                                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                                child: const Text('Create & Link Account'),
                              ),
                            ),
                          ],
                          const SizedBox(height: 12),

                          // 🏠 Direct "Back to Home" Button
                          OutlinedButton.icon(
                            onPressed: _resetToDefaultCredentialsMode,
                            icon: const Icon(Icons.home_rounded, color: Color(0xFF38BDF8), size: 18),
                            label: const Text('Back to Home / Main Login', style: TextStyle(color: Color(0xFF38BDF8))),
                            style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.white24), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                          ),
                        ]
                        
                        // VIEW 3: STANDARD LOGIN & SIGNUP FORM
                        else ...[
                          if (!_isSignUpMode) ...[
                            TextFormField(
                              controller: _identityController,
                              enabled: !staticAnyActiveLoad,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: 'Mobile number, username, or email',
                                labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
                                filled: true,
                                fillColor: const Color(0xFF0F172A),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                              ),
                              validator: (v) => v!.isEmpty ? 'Please enter username, email or mobile number.' : null,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _passwordController,
                              enabled: !staticAnyActiveLoad,
                              obscureText: _obscurePassword,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: 'Access Password',
                                labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
                                filled: true,
                                fillColor: const Color(0xFF0F172A),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                                suffixIcon: IconButton(
                                  icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: const Color(0xFF94A3B8)),
                                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                ),
                              ),
                              validator: (v) => v!.isEmpty ? 'Password is required.' : null,
                            ),
                          ] else ...[
                            TextFormField(
                              controller: _emailController,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: 'Email Address',
                                filled: true,
                                fillColor: const Color(0xFF0F172A),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _fullNameController,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: 'Full Legal Name',
                                filled: true,
                                fillColor: const Color(0xFF0F172A),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _usernameController,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: 'Unique Username',
                                filled: true,
                                fillColor: const Color(0xFF0F172A),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _phoneController,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: '10-Digit Mobile Number',
                                prefixText: '+91 ',
                                prefixStyle: const TextStyle(color: Colors.white),
                                filled: true,
                                fillColor: const Color(0xFF0F172A),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: 'Set Password',
                                filled: true,
                                fillColor: const Color(0xFF0F172A),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                              ),
                            ),
                          ],
                          const SizedBox(height: 24),

                          SizedBox(
                            height: 48,
                            child: ElevatedButton(
                              onPressed: staticAnyActiveLoad ? null : (_isSignUpMode ? _executeSecureSignUp : _executeUnifiedLogin),
                              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0066CC), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                              child: Text(_isSignUpMode ? 'Register New Space' : 'Log In'),
                            ),
                          ),
                          const SizedBox(height: 16),

                          if (!_isSignUpMode) ...[
                            TextButton(
                              onPressed: () => setState(() => _isForgotPasswordMode = true),
                              child: const Text('Forgot Password?', style: TextStyle(color: Colors.white70)),
                            ),
                            const Row(
                              children: [
                                Expanded(child: Divider(color: Colors.white12)),
                                Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('OR', style: TextStyle(color: Color(0xFF64748B), fontSize: 13))),
                                Expanded(child: Divider(color: Colors.white12)),
                              ],
                            ),
                            const SizedBox(height: 16),

                            SizedBox(
                              height: 44,
                              child: OutlinedButton.icon(
                                onPressed: () => setState(() => _isPhoneAuthMode = true),
                                icon: const Icon(Icons.phone_android_rounded, color: Colors.white, size: 18),
                                label: const Text('Continue with Mobile Phone OTP', style: TextStyle(color: Colors.white, fontSize: 13)),
                                style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.white24), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],

                          SizedBox(
                            height: 48,
                            child: OutlinedButton(
                              onPressed: staticAnyActiveLoad ? null : _executeGoogleAuthentication,
                              style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.white24), backgroundColor: const Color(0xFF0F172A), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.g_mobiledata_rounded, color: Colors.amber, size: 30),
                                  SizedBox(width: 8),
                                  Text('Continue with Google Workspace', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                                ],
                              ),
                            ),
                          )
                        ],
                        const SizedBox(height: 24),

                        SizedBox(
                          height: 52,
                          child: OutlinedButton(
                            onPressed: () {
                              setState(() {
                                _isSignUpMode = !_isSignUpMode;
                                _isPhoneAuthMode = false;
                                _isForgotPasswordMode = false;
                              });
                            },
                            style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFF0066CC)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                            child: Text(
                              _isSignUpMode ? 'Existing Account? Log In' : 'Create New Account', 
                              style: const TextStyle(color: Color(0xFF38BDF8), fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
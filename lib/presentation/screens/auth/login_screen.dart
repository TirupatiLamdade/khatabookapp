import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

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
  bool _isWaitingEmailVerification = false;
  bool _obscurePassword = true; 
  
  // Dropdown items for Forgot Password
  List<String> _linkedUsernamesList = [];
  String? _selectedResetUsername;

  // Loading Flags
  bool _isFormLoading = false;
  bool _isGoogleLoading = false;
  bool _isOtpLoading = false;
  
  bool _showOtpVerificationField = false;
  ConfirmationResult? _webConfirmationResult;
  
  Timer? _otpTimer;
  int _otpSecondsRemaining = 60;
  bool _isOtpExpired = false;

  Timer? _emailVerificationTimer;

  late AnimationController _ambientController;
  late AnimationController _pulseController;
  
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
    _emailVerificationTimer?.cancel();
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
        _showTopNotification(context, 'OTP expired! Reloading...', isError: true);
        
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) _resetToDefaultCredentialsMode();
        });
      }
    });
  }

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

  Future<void> _openEmailApp() async {
    final Uri emailLaunchUri = Uri(scheme: 'mailto');
    try {
      if (await canLaunchUrl(emailLaunchUri)) {
        await launchUrl(emailLaunchUri);
      } else {
        _showTopNotification(context, 'Please open your inbox manually.', isError: true);
      }
    } catch (e) {
      _showTopNotification(context, 'Could not launch email app.', isError: true);
    }
  }

  // 🔀 Processing Navigation Logic
  Future<void> _processUserPostLogin(String uid, String email) async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    bool isFirstTime = true;

    if (doc.exists && doc.data()!.containsKey('isFirstTime')) {
      isFirstTime = doc.data()!['isFirstTime'] ?? false;
    }

    if (mounted) {
      context.go('/processing', extra: {
        'next': isFirstTime ? '/shop-setup' : '/home',
        'email': email,
      });
    }
  }

  // 👥 Multi-Account Selection Sheet
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
                'Select an account to proceed:',
                style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
              ),
              const SizedBox(height: 16),
              Divider(color: Colors.white.withOpacity(0.1)),
              
              ...accounts.map((doc) {
                final data = doc.data();
                final username = data['username'] ?? 'User';
                final email = data['email'] ?? '';
                final uid = data['uid'] ?? doc.id;

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
                    _showTopNotification(context, 'Logging in as $username...');
                    _processUserPostLogin(uid, email);
                  },
                );
              }).toList(),

              const SizedBox(height: 8),
              Divider(color: Colors.white.withOpacity(0.1)),
              const SizedBox(height: 8),

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
                    _isPhoneAuthMode = true;
                    _isNewPhoneUser = true;
                  });
                  _showTopNotification(context, 'Fill form below to create account.');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // 1️⃣ Registration Logic
  Future<void> _executeSecureSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isFormLoading = true);
    final db = FirebaseFirestore.instance;

    try {
      final usernameInput = _usernameController.text.trim().toLowerCase();
      final emailInput = _emailController.text.trim().toLowerCase();

      final checkUsername = await db.collection('users').where('username', isEqualTo: usernameInput).get();
      if (checkUsername.docs.isNotEmpty) {
        _showTopNotification(context, 'Username already taken.', isError: true);
        setState(() => _isFormLoading = false);
        return;
      }

      UserCredential credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailInput,
        password: _passwordController.text.trim(),
      );

      await credential.user!.sendEmailVerification();

      await db.collection('users').doc(credential.user!.uid).set({
        'uid': credential.user!.uid,
        'fullName': _fullNameController.text.trim(),
        'username': usernameInput,
        'email': emailInput,
        'phone': _phoneController.text.trim(),
        'isFirstTime': true,
        'createdAt': FieldValue.serverTimestamp(),
      });

      _showTopNotification(context, 'Verification link sent to email!');

      setState(() {
        _isWaitingEmailVerification = true;
        _isFormLoading = false;
      });

      _startEmailVerificationCheck(credential.user!, credential.user!.uid, emailInput);

    } on FirebaseAuthException catch (e) {
      _showTopNotification(context, e.message ?? 'Registration failed.', isError: true);
      setState(() => _isFormLoading = false);
    }
  }

  void _startEmailVerificationCheck(User user, String uid, String email) {
    _emailVerificationTimer?.cancel();
    _emailVerificationTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      await user.reload();
      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null && currentUser.emailVerified) {
        timer.cancel();
        _showTopNotification(context, 'Email verified! Redirecting...');
        _processUserPostLogin(uid, email);
      }
    });
  }

  // 2️⃣ Standard Credentials Login
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
        _showTopNotification(context, 'Invalid user details.', isError: true);
        setState(() => _isFormLoading = false);
        return;
      }

      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: resolvedEmail,
        password: _passwordController.text.trim(),
      );

      await userCredential.user!.reload();
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null && !currentUser.emailVerified) {
        _showTopNotification(context, 'Please verify email before logging in.', isError: true);
        await FirebaseAuth.instance.signOut();
        setState(() => _isFormLoading = false);
        return;
      }

      _showTopNotification(context, 'Login successful!');
      _processUserPostLogin(currentUser!.uid, resolvedEmail);

    } on FirebaseAuthException catch (e) {
      _showTopNotification(context, 'Invalid password or user record.', isError: true);
    } finally {
      setState(() => _isFormLoading = false);
    }
  }

  // 3️⃣ Phone Verification (Fixes Auto-Redirect Bug)
  Future<void> _executePhoneVerification() async {
    if (_phoneController.text.length != 10) {
      _showTopNotification(context, 'Enter a valid 10-digit phone number.', isError: true);
      return;
    }

    final db = FirebaseFirestore.instance;

    try {
      if (kIsWeb) {
        if (!_showOtpVerificationField) {
          setState(() => _isOtpLoading = true);

          if (_isForgotPasswordMode) {
            final query = await db.collection('users').where('phone', isEqualTo: _phoneController.text.trim()).get();
            if (query.docs.isEmpty) {
              _showTopNotification(context, 'No account found with this phone.', isError: true);
              setState(() => _isOtpLoading = false);
              return;
            }
            _linkedUsernamesList = query.docs.map((e) => e.data()['username'].toString()).toList();
            _selectedResetUsername = _linkedUsernamesList.first;
          }

          _webConfirmationResult = await FirebaseAuth.instance.signInWithPhoneNumber(
            '+91${_phoneController.text.trim()}',
          );

          setState(() {
            _showOtpVerificationField = true;
            _isOtpLoading = false;
          });
          _startOtpCountdownTimer();
          _showTopNotification(context, 'OTP sent on SMS.');
        } else {
          if (_isOtpExpired) {
            _showTopNotification(context, 'OTP Expired!', isError: true);
            _resetToDefaultCredentialsMode();
            return;
          }

          if (_otpController.text.trim().isEmpty) {
            _showTopNotification(context, 'Enter 6-digit OTP.', isError: true);
            return;
          }

          setState(() => _isOtpLoading = true);
          await _webConfirmationResult!.confirm(_otpController.text.trim());
          _otpTimer?.cancel();

          // 🛑 Key Fix: Log out immediately so GoRouter stays on this screen
          await FirebaseAuth.instance.signOut();

          if (_isForgotPasswordMode) {
            setState(() {
              _isResetPhoneVerified = true;
              _isOtpLoading = false;
            });
            _showTopNotification(context, 'OTP Verified! Enter new password.');
            return;
          }

          final query = await db.collection('users').where('phone', isEqualTo: _phoneController.text.trim()).get();

          if (query.docs.isNotEmpty) {
            setState(() => _isOtpLoading = false);
            _showMultiAccountSelector(query.docs);
          } else {
            _showTopNotification(context, 'No account linked. Create new account.');
            setState(() {
              _isNewPhoneUser = true;
              _isOtpLoading = false;
            });
          }
        }
      }
    } catch (e) {
      _showTopNotification(context, 'Invalid OTP Code.', isError: true);
    } finally {
      setState(() => _isOtpLoading = false);
    }
  }

  // 4️⃣ Forgot Password New Password Save
  Future<void> _executeSaveNewPassword() async {
    final p1 = _newPasswordController.text.trim();
    final p2 = _confirmPasswordController.text.trim();

    if (p1.isEmpty || p1.length < 6) {
      _showTopNotification(context, 'Password must be min 6 characters.', isError: true);
      return;
    }

    if (p1 != p2) {
      _showTopNotification(context, 'Passwords do not match.', isError: true);
      return;
    }

    setState(() => _isFormLoading = true);

    try {
      final db = FirebaseFirestore.instance;
      final query = await db.collection('users').where('username', isEqualTo: _selectedResetUsername).get();

      if (query.docs.isNotEmpty) {
        final email = query.docs.first.data()['email'];
        await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

        _showTopNotification(context, 'Password reset link sent to $email.');
        _resetToDefaultCredentialsMode();
      }
    } catch (e) {
      _showTopNotification(context, 'Failed to update password.', isError: true);
    } finally {
      setState(() => _isFormLoading = false);
    }
  }

  void _resetToDefaultCredentialsMode() {
    _otpTimer?.cancel();
    _emailVerificationTimer?.cancel();
    setState(() {
      _isPhoneAuthMode = false;
      _isForgotPasswordMode = false;
      _isResetPhoneVerified = false;
      _isNewPhoneUser = false;
      _isSignUpMode = false;
      _isWaitingEmailVerification = false;
      _showOtpVerificationField = false;
      _otpSecondsRemaining = 60;
      _isOtpExpired = false;
      _phoneController.clear();
      _otpController.clear();
      _identityController.clear();
      _passwordController.clear();
      _fullNameController.clear();
      _usernameController.clear();
      _emailController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
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
                        Text(
                          _isWaitingEmailVerification
                              ? 'Verify Your Email'
                              : (_isForgotPasswordMode 
                                  ? 'Reset Password' 
                                  : (_isPhoneAuthMode 
                                      ? (_isNewPhoneUser ? 'Create New Account Setup' : 'Phone Gateway Login') 
                                      : (_isSignUpMode ? 'Register New Account' : 'Smart Ledger Login'))), 
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white), 
                          textAlign: TextAlign.center
                        ),
                        const SizedBox(height: 24),

                        // EMAIL VERIFICATION VIEW
                        if (_isWaitingEmailVerification) ...[
                          const Icon(Icons.mark_email_unread_rounded, color: Color(0xFF38BDF8), size: 60),
                          const SizedBox(height: 16),
                          Text(
                            'Verification link sent to:\n${_emailController.text.trim()}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.5),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Click the verification link in your email to proceed.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            height: 48,
                            child: ElevatedButton.icon(
                              onPressed: _openEmailApp,
                              icon: const Icon(Icons.mail_rounded, color: Colors.white),
                              label: const Text('Open Email App'),
                              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0066CC), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                            ),
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton(
                            onPressed: _resetToDefaultCredentialsMode,
                            style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.white24)),
                            child: const Text('Back to Login', style: TextStyle(color: Colors.white70)),
                          ),
                        ]

                        // FORGOT PASSWORD VIEW
                        else if (_isForgotPasswordMode) ...[
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
                            if (_linkedUsernamesList.isNotEmpty) ...[
                              DropdownButtonFormField<String>(
                                value: _selectedResetUsername,
                                dropdownColor: const Color(0xFF0F172A),
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  labelText: 'Select Account Username',
                                  filled: true,
                                  fillColor: const Color(0xFF0F172A),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                                ),
                                items: _linkedUsernamesList.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                                onChanged: (v) => setState(() => _selectedResetUsername = v),
                              ),
                              const SizedBox(height: 12),
                            ],
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
                          OutlinedButton.icon(
                            onPressed: _resetToDefaultCredentialsMode,
                            icon: const Icon(Icons.home_rounded, color: Color(0xFF38BDF8), size: 18),
                            label: const Text('Back to Home / Main Login', style: TextStyle(color: Color(0xFF38BDF8))),
                            style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.white24), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                          ),
                        ]

                        // PHONE LOGIN VIEW
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
                            TextFormField(
                              controller: _fullNameController,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: 'Full Legal Name',
                                filled: true,
                                fillColor: const Color(0xFF0F172A),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                              ),
                              validator: (v) => v!.isEmpty ? 'Required field' : null,
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
                              validator: (v) => v!.isEmpty ? 'Required field' : null,
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
                              validator: (v) => v!.isEmpty ? 'Required field' : null,
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
                              validator: (v) => v!.length < 6 ? 'Min 6 characters' : null,
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
                          OutlinedButton.icon(
                            onPressed: _resetToDefaultCredentialsMode,
                            icon: const Icon(Icons.home_rounded, color: Color(0xFF38BDF8), size: 18),
                            label: const Text('Back to Home / Main Login', style: TextStyle(color: Color(0xFF38BDF8))),
                            style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.white24), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                          ),
                        ]
                        
                        // MAIN LOGIN VIEW
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
                              validator: (v) => v!.isEmpty ? 'Enter username, email or phone.' : null,
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
                          ],
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
                                _isWaitingEmailVerification = false;
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
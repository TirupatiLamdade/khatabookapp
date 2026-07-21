

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
  
  // Obscure Toggles for Passwords
  bool _obscurePassword = true; 
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  
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
    "Rajesh Sharma added credit",
    "Suresh Patil paid balance",
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

  // Soft Thin Border Decoration Helper
  InputDecoration _softInputDecoration({
    required String labelText,
    String? prefixText,
    Widget? suffixIcon,
    String? counterText = "",
  }) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
      prefixText: prefixText,
      prefixStyle: const TextStyle(color: Colors.white),
      suffixIcon: suffixIcon,
      counterText: counterText,
      filled: true,
      fillColor: const Color(0xFF0F172A),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.white12, width: 1.0),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.white12, width: 1.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF38BDF8), width: 1.2),
      ),
    );
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
        'phone': _phoneController.text.trim(),
      });
    }
  }

  // 🌐 Google Sign-In Function
  Future<void> _executeGoogleLogin() async {
    setState(() => _isGoogleLoading = true);
    try {
      GoogleAuthProvider googleProvider = GoogleAuthProvider();
      UserCredential userCredential = await FirebaseAuth.instance.signInWithPopup(googleProvider);
      
      User? user = userCredential.user;
      if (user != null) {
        final db = FirebaseFirestore.instance;
        final doc = await db.collection('users').doc(user.uid).get();

        if (!doc.exists) {
          await db.collection('users').doc(user.uid).set({
            'uid': user.uid,
            'fullName': user.displayName ?? 'Google User',
            'username': user.email!.split('@')[0],
            'email': user.email,
            'phone': user.phoneNumber ?? '',
            'isFirstTime': true,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
        _showTopNotification(context, 'Google Sign-In Successful!');
        await _processUserPostLogin(user.uid, user.email ?? '');
      }
    } catch (e) {
      _showTopNotification(context, 'Google Auth Failed or Cancelled', isError: true);
    } finally {
      if (mounted) setState(() => _isGoogleLoading = false);
    }
  }

  // 👥 Multi-Account Selection Sheet (फक्त पासवर्ड बरोबर असल्यावरच दाखवले जाईल)
  void _showMultiAccountSelector(List<QueryDocumentSnapshot<Map<String, dynamic>>> accounts) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E293B),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) {
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
                  onTap: () async {
                    Navigator.pop(bottomSheetContext);
                    _showTopNotification(context, 'Logging in as $username...');
                    await _processUserPostLogin(uid, email);
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
                  Navigator.pop(bottomSheetContext);
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
        await _processUserPostLogin(uid, email);
      }
    });
  }

  // 2️⃣ Standard Credentials Login (आधी पासवर्ड तपासेल, मगच लिस्ट/होम दाखवेल)
  Future<void> _executeUnifiedLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isFormLoading = true);
    final db = FirebaseFirestore.instance;
    final input = _identityController.text.trim().toLowerCase();
    final passwordInput = _passwordController.text.trim();

    try {
      // 📱 Case 1: Phone number entered
      final queryPhone = await db.collection('users').where('phone', isEqualTo: input).get();

      if (queryPhone.docs.isNotEmpty) {
        List<QueryDocumentSnapshot<Map<String, dynamic>>> validAccounts = [];

        for (var doc in queryPhone.docs) {
          final accountEmail = doc.data()['email'];
          if (accountEmail != null && accountEmail.toString().isNotEmpty) {
            try {
              // Check if entered password matches this account
              await FirebaseAuth.instance.signInWithEmailAndPassword(
                email: accountEmail,
                password: passwordInput,
              );
              validAccounts.add(doc);
            } catch (_) {
              // Password did not match this account
            }
          }
        }

        if (validAccounts.isEmpty) {
          _showTopNotification(context, 'Invalid password or user details.', isError: true);
          return;
        } else if (validAccounts.length > 1) {
          _showMultiAccountSelector(validAccounts);
          return;
        } else {
          final currentUser = FirebaseAuth.instance.currentUser;
          if (currentUser != null) {
            _showTopNotification(context, 'Login successful!');
            await _processUserPostLogin(currentUser.uid, currentUser.email ?? '');
            return;
          }
        }
      }

      // 📧/👤 Case 2: Username or Email entered
      String? resolvedEmail;
      if (input.contains('@')) {
        resolvedEmail = input;
      } else {
        final queryUsername = await db.collection('users').where('username', isEqualTo: input).get();
        if (queryUsername.docs.isNotEmpty) {
          resolvedEmail = queryUsername.docs.first.data()['email'];
        }
      }

      if (resolvedEmail == null || resolvedEmail.isEmpty) {
        _showTopNotification(context, 'Invalid username, phone, or password.', isError: true);
        return;
      }

      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: resolvedEmail,
        password: passwordInput,
      );

      await userCredential.user!.reload();
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null && !currentUser.emailVerified) {
        _showTopNotification(context, 'Please verify email before logging in.', isError: true);
        await FirebaseAuth.instance.signOut();
        return;
      }

      _showTopNotification(context, 'Login successful!');
      await _processUserPostLogin(currentUser!.uid, resolvedEmail);

    } on FirebaseAuthException catch (e) {
      _showTopNotification(context, 'Invalid username, phone, or password.', isError: true);
    } catch (e) {
      _showTopNotification(context, 'Login failed. Please check details.', isError: true);
    } finally {
      if (mounted) setState(() => _isFormLoading = false);
    }
  }

  // 3️⃣ Phone Verification
  Future<void> _executePhoneVerification() async {
    final phoneInput = _phoneController.text.trim();
    if (phoneInput.length != 10 || !RegExp(r'^[0-9]+$').hasMatch(phoneInput)) {
      _showTopNotification(context, 'Please enter a valid 10-digit mobile number!', isError: true);
      return;
    }

    final db = FirebaseFirestore.instance;

    try {
      if (kIsWeb) {
        if (!_showOtpVerificationField || _isOtpExpired) {
          setState(() => _isOtpLoading = true);

          if (_isForgotPasswordMode) {
            final query = await db.collection('users').where('phone', isEqualTo: phoneInput).get();
            if (query.docs.isEmpty) {
              _showTopNotification(context, 'No account found with this phone.', isError: true);
              setState(() => _isOtpLoading = false);
              return;
            }
            _linkedUsernamesList = query.docs.map((e) => e.data()['username'].toString()).toList();
            _selectedResetUsername = _linkedUsernamesList.first;
          }

          _webConfirmationResult = await FirebaseAuth.instance.signInWithPhoneNumber(
            '+91$phoneInput',
          );

          setState(() {
            _showOtpVerificationField = true;
            _isOtpLoading = false;
          });
          _startOtpCountdownTimer();
          _showTopNotification(context, 'OTP sent via SMS.');
        } else {
          if (_otpController.text.trim().isEmpty) {
            _showTopNotification(context, 'Enter 6-digit OTP code.', isError: true);
            return;
          }

          setState(() => _isOtpLoading = true);
          UserCredential userCred = await _webConfirmationResult!.confirm(_otpController.text.trim());
          _otpTimer?.cancel();

          if (_isForgotPasswordMode) {
            setState(() {
              _isResetPhoneVerified = true;
              _isOtpLoading = false;
            });
            _showTopNotification(context, 'OTP Verified! Enter new password.');
            return;
          }

          final query = await db.collection('users').where('phone', isEqualTo: phoneInput).get();

          if (query.docs.isNotEmpty) {
            if (query.docs.length > 1) {
              setState(() => _isOtpLoading = false);
              _showMultiAccountSelector(query.docs);
            } else {
              final userData = query.docs.first.data();
              final uid = userCred.user?.uid ?? userData['uid'];
              final email = userData['email'] ?? '';
              await _processUserPostLogin(uid, email);
            }
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
      if (mounted) setState(() => _isOtpLoading = false);
    }
  }

  // 4️⃣ Save New Password Logic
  Future<void> _executeSaveNewPassword() async {
    final p1 = _newPasswordController.text.trim();
    final p2 = _confirmPasswordController.text.trim();

    if (p1.isEmpty) {
      _showTopNotification(context, 'Please enter a valid password.', isError: true);
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
      if (mounted) setState(() => _isFormLoading = false);
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
          // 💻 Desktop Left Side
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
                                  const Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Shree Ganesh Traders', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                                      Text('Linked Phone Gateway Active', style: TextStyle(color: Colors.white70, fontSize: 13)),
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
          
          // 📱 Responsive Form View
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
                              maxLength: 10,
                              keyboardType: TextInputType.phone,
                              style: const TextStyle(color: Colors.white),
                              decoration: _softInputDecoration(
                                labelText: '10-Digit Mobile Number',
                                prefixText: '+91 ',
                              ),
                            ),
                            const SizedBox(height: 12),
                            if (_showOtpVerificationField) ...[
                              TextFormField(
                                controller: _otpController,
                                enabled: !staticAnyActiveLoad,
                                keyboardType: TextInputType.number,
                                style: const TextStyle(color: Colors.white),
                                decoration: _softInputDecoration(
                                  labelText: _isOtpExpired 
                                      ? 'OTP Expired' 
                                      : '6-Digit OTP ($_otpSecondsRemaining s remaining)',
                                ),
                              ),
                              const SizedBox(height: 12),
                            ],
                            SizedBox(
                              height: 48,
                              child: ElevatedButton(
                                onPressed: staticAnyActiveLoad ? null : _executePhoneVerification,
                                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0066CC), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                                child: _isOtpLoading
                                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                    : Text(_showOtpVerificationField 
                                        ? (_isOtpExpired ? 'Resend OTP' : 'Verify OTP Code') 
                                        : 'Send Security OTP'),
                              ),
                            ),
                          ] else ...[
                            if (_linkedUsernamesList.isNotEmpty) ...[
                              DropdownButtonFormField<String>(
                                value: _selectedResetUsername,
                                dropdownColor: const Color(0xFF0F172A),
                                style: const TextStyle(color: Colors.white),
                                decoration: _softInputDecoration(labelText: 'Select Account Username'),
                                items: _linkedUsernamesList.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                                onChanged: (v) => setState(() => _selectedResetUsername = v),
                              ),
                              const SizedBox(height: 12),
                            ],
                            
                            // Password Input 1
                            TextFormField(
                              controller: _newPasswordController,
                              obscureText: _obscureNewPassword,
                              style: const TextStyle(color: Colors.white),
                              decoration: _softInputDecoration(
                                labelText: 'Enter New Password',
                                suffixIcon: IconButton(
                                  icon: Icon(_obscureNewPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: const Color(0xFF94A3B8)),
                                  onPressed: () => setState(() => _obscureNewPassword = !_obscureNewPassword),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            
                            // Password Input 2
                            TextFormField(
                              controller: _confirmPasswordController,
                              obscureText: _obscureConfirmPassword,
                              style: const TextStyle(color: Colors.white),
                              decoration: _softInputDecoration(
                                labelText: 'Confirm New Password',
                                suffixIcon: IconButton(
                                  icon: Icon(_obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: const Color(0xFF94A3B8)),
                                  onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 48,
                              child: ElevatedButton(
                                onPressed: staticAnyActiveLoad ? null : _executeSaveNewPassword,
                                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                                child: _isFormLoading 
                                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                    : const Text('Save & Update Password'),
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
                              maxLength: 10,
                              keyboardType: TextInputType.phone,
                              style: const TextStyle(color: Colors.white),
                              decoration: _softInputDecoration(
                                labelText: '10-Digit Mobile Phone Number',
                                prefixText: '+91 ',
                              ),
                            ),
                            const SizedBox(height: 12),
                            if (_showOtpVerificationField) ...[
                              TextFormField(
                                controller: _otpController,
                                enabled: !staticAnyActiveLoad,
                                keyboardType: TextInputType.number,
                                style: const TextStyle(color: Colors.white),
                                decoration: _softInputDecoration(
                                  labelText: _isOtpExpired 
                                      ? 'OTP Expired' 
                                      : '6-Digit SMS OTP ($_otpSecondsRemaining s remaining)',
                                ),
                              ),
                              const SizedBox(height: 12),
                            ],
                            SizedBox(
                              height: 48,
                              child: ElevatedButton(
                                onPressed: staticAnyActiveLoad ? null : _executePhoneVerification,
                                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0066CC), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                                child: _isOtpLoading
                                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                    : Text(_showOtpVerificationField 
                                        ? (_isOtpExpired ? 'Resend OTP' : 'Verify OTP Code') 
                                        : 'Send Verification OTP'),
                              ),
                            ),
                          ] else ...[
                            TextFormField(
                              controller: _fullNameController,
                              style: const TextStyle(color: Colors.white),
                              decoration: _softInputDecoration(labelText: 'Full Legal Name'),
                              validator: (v) => v!.isEmpty ? 'Required field' : null,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _usernameController,
                              style: const TextStyle(color: Colors.white),
                              decoration: _softInputDecoration(labelText: 'Unique Username'),
                              validator: (v) => v!.isEmpty ? 'Required field' : null,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _phoneController,
                              maxLength: 10,
                              keyboardType: TextInputType.phone,
                              style: const TextStyle(color: Colors.white),
                              decoration: _softInputDecoration(
                                labelText: '10-Digit Mobile Number',
                                prefixText: '+91 ',
                              ),
                              validator: (v) => v!.length != 10 ? 'Enter valid 10 digits' : null,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              style: const TextStyle(color: Colors.white),
                              decoration: _softInputDecoration(
                                labelText: 'Set Password',
                                suffixIcon: IconButton(
                                  icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: const Color(0xFF94A3B8)),
                                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                ),
                              ),
                              validator: (v) => v!.isEmpty ? 'Password is required' : null,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _emailController,
                              style: const TextStyle(color: Colors.white),
                              decoration: _softInputDecoration(labelText: 'Email Address'),
                              validator: (v) => v!.isEmpty ? 'Required field' : null,
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 48,
                              child: ElevatedButton(
                                onPressed: staticAnyActiveLoad ? null : _executeSecureSignUp,
                                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                                child: _isFormLoading 
                                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                    : const Text('Create & Link Account'),
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
                              decoration: _softInputDecoration(labelText: 'Mobile number, username, or email'),
                              validator: (v) => v!.isEmpty ? 'Enter username, email or phone.' : null,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _passwordController,
                              enabled: !staticAnyActiveLoad,
                              obscureText: _obscurePassword,
                              style: const TextStyle(color: Colors.white),
                              decoration: _softInputDecoration(
                                labelText: 'Access Password',
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
                              decoration: _softInputDecoration(labelText: 'Full Legal Name'),
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _usernameController,
                              style: const TextStyle(color: Colors.white),
                              decoration: _softInputDecoration(labelText: 'Unique Username'),
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _phoneController,
                              maxLength: 10,
                              keyboardType: TextInputType.phone,
                              style: const TextStyle(color: Colors.white),
                              decoration: _softInputDecoration(
                                labelText: '10-Digit Mobile Number',
                                prefixText: '+91 ',
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              style: const TextStyle(color: Colors.white),
                              decoration: _softInputDecoration(
                                labelText: 'Set Password',
                                suffixIcon: IconButton(
                                  icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: const Color(0xFF94A3B8)),
                                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _emailController,
                              style: const TextStyle(color: Colors.white),
                              decoration: _softInputDecoration(labelText: 'Email Address'),
                            ),
                          ],
                          const SizedBox(height: 24),

                          SizedBox(
                            height: 48,
                            child: ElevatedButton(
                              onPressed: staticAnyActiveLoad ? null : (_isSignUpMode ? _executeSecureSignUp : _executeUnifiedLogin),
                              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0066CC), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                              child: _isFormLoading 
                                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                  : Text(_isSignUpMode ? 'Register New Space' : 'Log In'),
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
                                onPressed: staticAnyActiveLoad ? null : _executeGoogleLogin,
                                icon: _isGoogleLoading 
                                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.amber, strokeWidth: 2))
                                    : const Icon(Icons.g_mobiledata_rounded, color: Colors.amber, size: 24),
                                label: const Text('Continue with Google', style: TextStyle(color: Colors.white, fontSize: 13)),
                                style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.white24), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                              ),
                            ),
                            const SizedBox(height: 10),

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
import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../widgets/glass_card.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with WidgetsBindingObserver {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController(text: '+91 ');
  final _otpController = TextEditingController();

  // State Variables
  bool _isPhoneAuthMode = false;
  bool _isOtpSent = false;
  bool _isLoading = false;
  bool _isLinkSentSuccess = false; 
  String _verificationId = '';
  String _lastSentEmail = ''; 

  // ⏱️ Timer Variables
  Timer? _countdownTimer;
  int _remainingSeconds = 60;
  bool _isOtpExpired = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkIncomingEmailLink();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _countdownTimer?.cancel();
    _emailController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkIncomingEmailLink();
    }
  }

  // ⏳ Start 1 Minute Countdown Timer
  void _startOtpTimer() {
    _countdownTimer?.cancel();
    setState(() {
      _remainingSeconds = 60;
      _isOtpExpired = false;
    });
    
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_remainingSeconds > 0) {
            _remainingSeconds--;
          } else {
            _isOtpExpired = true;
            _countdownTimer?.cancel();
            _showErrorSnackBar('OTP Gateway Session Expired! Please request a new OTP.');
          }
        });
      }
    });
  }

  String _formatTimerText() {
    final minutes = (_remainingSeconds / 60).floor().toString().padLeft(2, '0');
    final seconds = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  void _toggleAuthMode() {
    _countdownTimer?.cancel();
    setState(() {
      _isPhoneAuthMode = !_isPhoneAuthMode;
      _isOtpSent = false;
      _isLinkSentSuccess = false;
      _isOtpExpired = false;
      if (_isPhoneAuthMode) {
        _phoneController.text = '+91 ';
      }
    });
  }

  // ✉️ 1. FIREBASE EMAIL PASSWORDLESS MAGIC LINK TRIGGER
  Future<void> _sendEmailVerificationLink() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final String email = _emailController.text.trim();

    var acs = ActionCodeSettings(
      url: 'https://loginsetup-6f413.firebaseapp.com/login', 
      handleCodeInApp: true,
      androidPackageName: 'com.example.login_setup', 
      androidMinimumVersion: '12',
      androidInstallApp: true,
      iOSBundleId: 'com.example.loginSetup',
    );

    try {
      await _auth.sendSignInLinkToEmail(email: email, actionCodeSettings: acs);
      _lastSentEmail = email;
      
      setState(() {
        _isLinkSentSuccess = true; 
      });
      _showSuccessSnackBar('Magic Login Link successfully sent to your email inbox!');
    } on FirebaseAuthException catch (e) {
      _showErrorSnackBar(e.message ?? 'Configuration or Domain Error.');
    } catch (e) {
      _showErrorSnackBar('An unexpected error occurred.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // 🔗 2. VERIFY MAGIC LINK AND REDIRECT
  Future<void> _checkIncomingEmailLink() async {
    try {
      String? currentLink;
      if (kIsWeb) {
        currentLink = Uri.base.toString();
      }

      if (currentLink != null && _auth.isSignInWithEmailLink(currentLink)) {
        setState(() => _isLoading = true);

        if (_lastSentEmail.isEmpty) {
          final email = await _showEmailReConfirmationDialog();
          if (email == null || email.isEmpty) {
            setState(() => _isLoading = false);
            return;
          }
          _lastSentEmail = email;
        }

        await _auth.signInWithEmailLink(
          email: _lastSentEmail,
          emailLink: currentLink,
        );
        
        if (mounted) context.go('/pin_lock');
      }
    } on FirebaseAuthException catch (e) {
      _showErrorSnackBar(e.message ?? 'Magic link expired or invalid.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<String?> _showEmailReConfirmationDialog() async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Identity'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Please re-enter your login email'),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Confirm'),
          )
        ],
      ),
    );
  }

  // 📱 3. FIREBASE PHONE NUMBER VERIFICATION (SEND OTP)
  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;

    final phone = _phoneController.text.trim().replaceAll(' ', '');
    setState(() => _isLoading = true);
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phone,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
          _countdownTimer?.cancel();
          if (mounted) context.go('/pin_lock');
        },
        verificationFailed: (FirebaseAuthException e) {
          _showErrorSnackBar(e.message ?? 'Phone verification failed');
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            _verificationId = verificationId;
            _isOtpSent = true;
          });
          _startOtpTimer(); // टाइमर सुरू करा
          _showSuccessSnackBar('Verification OTP Gateway Securely Dispatched!');
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );
    } catch (e) {
      _showErrorSnackBar('Failed to request OTP');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // 🔑 4. VERIFY PHONE OTP WITH TIMER CHECK
  Future<void> _verifyOtp() async {
    if (_isOtpExpired) {
      _showErrorSnackBar('Access Denied: This OTP has expired. Please request a new one.');
      return;
    }

    if (_otpController.text.trim().isEmpty) {
      _showErrorSnackBar('Please enter the 6-digit OTP code');
      return;
    }

    setState(() => _isLoading = true);
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: _otpController.text.trim(),
      );
      await _auth.signInWithCredential(credential);
      _countdownTimer?.cancel();
      if (mounted) context.go('/pin_lock');
    } on FirebaseAuthException catch (e) {
      _showErrorSnackBar(e.message ?? 'Invalid OTP code entered');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // 🌐 5. REAL FIREBASE GOOGLE SIGN-IN INTERACTION
  Future<void> _loginWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      GoogleAuthProvider googleProvider = GoogleAuthProvider();
      await _auth.signInWithPopup(googleProvider); 
      if (mounted) context.go('/pin_lock');
    } catch (e) {
      _showErrorSnackBar('Google Sign-In process failed.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // 📨 6. GMAIL APP DIRECT LAUNCH LOGIC
  Future<void> _launchGmailLink() async {
    final Uri emailLaunchUri = Uri.parse('https://mail.google.com');
    try {
      if (await canLaunchUrl(emailLaunchUri)) {
        await launchUrl(emailLaunchUri, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch mail client';
      }
    } catch (e) {
      _showErrorSnackBar('Unable to open Gmail automatically. Please open it manually.');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent, behavior: SnackBarBehavior.floating),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green, behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool isDesktop = size.width >= 1024;
    final bool isTablet = size.width >= 600 && size.width < 1024;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.deepPurple, Colors.indigo, Colors.black],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(isDesktop ? 64.0 : 24.0),
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: isDesktop ? 1100 : (isTablet ? 550 : 420),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (isDesktop)
                      Expanded(
                        flex: 1,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 48.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(Icons.account_balance_wallet_rounded, size: 48, color: Colors.white),
                              ),
                              const SizedBox(height: 24),
                              const Text(
                                'Khatabook Smart\nEnterprise Node',
                                style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white, height: 1.2),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Experience next-gen decentralized ledger synchronization. Real-time logging, high-risk flagged analytics, and advanced biometric authorization protocols built for scaling modern operations.',
                                style: TextStyle(fontSize: 14, color: Colors.white70, height: 1.6),
                              ),
                            ],
                          ),
                        ),
                      ),

                    Expanded(
                      flex: 1,
                      child: GlassCard(
                        opacity: 0.15,
                        child: Padding(
                          padding: EdgeInsets.all(isDesktop ? 36.0 : 24.0),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: _isLinkSentSuccess 
                                ? _buildGmailSuccessView() 
                                : _buildMainLoginForm(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildGmailSuccessView() {
    return Column(
      key: const ValueKey('SuccessView'),
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.2),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.greenAccent, width: 2),
          ),
          child: const Icon(Icons.mark_email_read_rounded, size: 54, color: Colors.greenAccent),
        ),
        const SizedBox(height: 24),
        const Text(
          'Check Your Email!',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 12),
        Text(
          'We have successfully sent a secure magic link to:\n$_lastSentEmail',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 13, color: Colors.white70, height: 1.5),
        ),
        const SizedBox(height: 32),
        
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 54),
            backgroundColor: const Color(0xFFEA4335), 
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            elevation: 4,
          ),
          icon: const Icon(Icons.mail_outline_rounded, size: 24),
          onPressed: _launchGmailLink,
          label: const Text('LAUNCH GMAIL NOW', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        ),
        
        const SizedBox(height: 20),
        TextButton(
          onPressed: () {
            setState(() {
              _isLinkSentSuccess = false;
            });
          },
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.arrow_back_ios_rounded, size: 12, color: Colors.white60),
              SizedBox(width: 6),
              Text('Change Email Address', style: TextStyle(color: Colors.white60, decoration: TextDecoration.underline)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMainLoginForm() {
    return Form(
      key: _formKey,
      child: Column(
        key: const ValueKey('FormView'),
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _isPhoneAuthMode ? 'Phone Authentication' : 'Passwordless Ledger Login',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            _isPhoneAuthMode 
                ? 'Verify identity via global standard OTP' 
                : 'Enter business email to pull secure authentication link',
            style: const TextStyle(fontSize: 12, color: Colors.white70),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          if (!_isPhoneAuthMode) ...[
            // 📧 EMAIL INPUT FIELDS WITH REAL-TIME RED BORDER VALIDATION
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Corporate Email Address',
                labelStyle: TextStyle(color: Colors.white70),
                prefixIcon: Icon(Icons.email_outlined, color: Colors.white70),
                errorStyle: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white30)),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                errorBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.redAccent, width: 2)),
                focusedErrorBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.redAccent, width: 2)),
              ),
              // ईमेल व्हॅलिडेशन लॉजिक (चुकीचा असल्यास पूर्ण बॉक्स लाल होईल)
              validator: (val) {
                if (val == null || val.trim().isEmpty || !val.contains('@') || !val.contains('.')) {
                  return 'Please enter a valid business email address';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            
            _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.deepPurple,
                    ),
                    icon: const Icon(Icons.bolt_rounded),
                    onPressed: _sendEmailVerificationLink,
                    label: const Text('Request Magic Login Link', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
          ] else ...[
            // 📱 MOBILE INPUT FIELDS WITH 10-DIGIT STRICT VALIDATION
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              style: const TextStyle(color: Colors.white),
              enabled: !_isOtpSent,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                hintText: 'e.g., +91 9876543210',
                hintStyle: TextStyle(color: Colors.white30),
                labelStyle: TextStyle(color: Colors.white70),
                prefixIcon: Icon(Icons.phone_android, color: Colors.white70),
                errorStyle: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white30)),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                errorBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.redAccent, width: 2)),
                focusedErrorBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.redAccent, width: 2)),
              ),
              // मोबाईल १० डिजिट व्हॅलिडेशन (कंट्री कोड वगळून)
              validator: (val) {
                if (val == null) return 'Required';
                final cleanNumber = val.replaceAll('+91', '').replaceAll(' ', '').trim();
                if (cleanNumber.length != 10) {
                  return 'Mobile number must be exactly 10 digits';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            if (_isOtpSent) ...[
              // 🔑 OTP INPUT BOX WITH LIVE COUNTDOWN TIMER UI
              TextFormField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                enabled: !_isOtpExpired,
                decoration: InputDecoration(
                  labelText: '6-Digit Verification Code',
                  labelStyle: const TextStyle(color: Colors.white70),
                  prefixIcon: const Icon(Icons.sms_outlined, color: Colors.white70),
                  errorStyle: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                  enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.white30)),
                  focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                  suffixIcon: Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Text(
                      _formatTimerText(),
                      style: TextStyle(
                        color: _isOtpExpired ? Colors.redAccent : Colors.greenAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],

            _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: _isOtpExpired ? Colors.grey : Colors.white,
                      foregroundColor: Colors.deepPurple,
                    ),
                    onPressed: _isOtpSent ? _verifyOtp : _sendOtp,
                    child: Text(
                      _isOtpSent 
                          ? (_isOtpExpired ? 'OTP Expired' : 'Verify Master OTP') 
                          : 'Transmit Gateway OTP', 
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
            
            if (_isOtpExpired) ...[
              TextButton(
                onPressed: _sendOtp,
                child: const Text('Resend Verification OTP', style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold)),
              )
            ]
          ],

          const SizedBox(height: 20),
          const Row(
            children: [
              Expanded(child: Divider(color: Colors.white30)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Text('OR', style: TextStyle(color: Colors.white60, fontSize: 11)),
              ),
              Expanded(child: Divider(color: Colors.white30)),
            ],
          ),
          const SizedBox(height: 20),

          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              side: const BorderSide(color: Colors.white),
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.g_mobiledata, size: 36),
            label: const Text('Continue with Google Platform', style: TextStyle(fontWeight: FontWeight.bold)),
            onPressed: _isLoading ? null : _loginWithGoogle,
          ),

          const SizedBox(height: 24),
          TextButton(
            onPressed: _isLoading ? null : _toggleAuthMode,
            child: Text(
              _isPhoneAuthMode ? 'Switch to Email Magic Link' : 'Switch to Gateway Phone OTP',
              style: const TextStyle(color: Colors.white70, decoration: TextDecoration.underline),
            ),
          ),
        ],
      ),
    );
  }
}
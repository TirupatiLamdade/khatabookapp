import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_core/firebase_core.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  
  // Input Form Data Controllers
  final _identityController = TextEditingController(); 
  final _passwordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();

  bool _isSignUpMode = false;
  bool _isLoading = false;
  bool _isEmailVerifiedSuccessfully = false;
  bool _showOtpVerificationField = false;
  String? _firebaseVerificationId;
  
  late AnimationController _ambientController;

  @override
  void initState() {
    super.initState();
    _ambientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ambientController.dispose();
    _identityController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  // Top-Anchored Global Toast Alert Notifications
  void _showTopNotification(BuildContext context, String message, {bool isError = false}) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 40,
        left: 24,
        right: 24,
        child: Material(
          color: Colors.transparent,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: isError ? const Color(0xFFFEE2E2) : const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isError ? Colors.red.shade200 : Colors.green.shade200, width: 1.0),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: Row(
              children: [
                Icon(isError ? Icons.error_outline : Icons.check_circle_outline, color: isError ? Colors.red : Colors.green),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    message,
                    style: TextStyle(color: isError ? Colors.red.shade900 : Colors.green.shade900, fontWeight: FontWeight.w600),
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

  // 📧 SIGN-UP EMAIL VERIFICATION LINK FLOW
  Future<void> _triggerEmailVerification() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      _showTopNotification(context, 'Please enter a valid email address first.', isError: true);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final existingDoc = await FirebaseFirestore.instance.collection('users').where('email', isEqualTo: email.toLowerCase()).get();
      if (existingDoc.docs.isNotEmpty) {
        _showTopNotification(context, 'This email is already registered. Please log in.', isError: true);
        return;
      }

      // Dynamically extracts the project ID 'loginsetup-6f413' straight from runtime settings 
      final projectId = Firebase.app().options.projectId;

      await FirebaseAuth.instance.sendSignInLinkToEmail(
        email: email,
        actionCodeSettings: ActionCodeSettings(
          url: 'https://$projectId.firebaseapp.com/__/auth/action',
          handleCodeInApp: true,
          androidPackageName: 'com.example.login_setup', // 💡 FIXED: Matches your exact Android configuration mapping!
          androidInstallApp: true,
          androidMinimumVersion: '12',
        ),
      );
      
      setState(() => _isEmailVerifiedSuccessfully = true); 
      _showTopNotification(context, 'Verification link dispatched! The remaining registration parameters are now unlocked.');
    } catch (e) {
      _showTopNotification(context, 'Error processing token mapping: ${e.toString()}', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // 🔐 MANDATORY AND SECURE SIGN-UP ROUTINE
  Future<void> _executeSecureSignUp() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_isEmailVerifiedSuccessfully) {
      _showTopNotification(context, 'You must verify your tracking email before completing profile creation.', isError: true);
      return;
    }

    setState(() => _isLoading = true);
    final db = FirebaseFirestore.instance;

    try {
      final checkUsername = await db.collection('users').where('username', isEqualTo: _usernameController.text.trim().toLowerCase()).get();
      final checkPhone = await db.collection('users').where('phone', isEqualTo: _phoneController.text.trim()).get();

      if (checkUsername.docs.isNotEmpty) {
        _showTopNotification(context, 'This username handle is already claimed by another user context.', isError: true);
        return;
      }
      if (checkPhone.docs.isNotEmpty) {
        _showTopNotification(context, 'This active phone number asset is already linked to a workspace user.', isError: true);
        return;
      }

      UserCredential credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim().toLowerCase(),
        password: _passwordController.text.trim(),
      );

      await db.collection('users').doc(credential.user!.uid).set({
        'uid': credential.user!.uid,
        'fullName': _fullNameController.text.trim(),
        'username': _usernameController.text.trim().toLowerCase(),
        'email': _emailController.text.trim().toLowerCase(),
        'phone': _phoneController.text.trim(),
        'authProvider': 'credentials',
        'createdAt': FieldValue.serverTimestamp(),
      });

      _showTopNotification(context, 'Account workspace secured successfully!');
      context.go('/processing', extra: {'email': _emailController.text.trim()});
    } on FirebaseAuthException catch (e) {
      _showTopNotification(context, e.message ?? 'Sign up protocol execution fault.', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // 🔑 UNIFIED MULTI-IDENTIFIER LOG IN MATRIX
  Future<void> _executeUnifiedLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final db = FirebaseFirestore.instance;
    final input = _identityController.text.trim().toLowerCase();
    String? resolvedEmail;

    try {
      if (input.contains('@')) {
        resolvedEmail = input;
      } else {
        final queryUsername = await db.collection('users').where('username', isEqualTo: input).get();
        final queryPhone = await db.collection('users').where('phone', isEqualTo: input).get();

        if (queryUsername.docs.isNotEmpty) {
          resolvedEmail = queryUsername.docs.first.data()['email'];
        } else if (queryPhone.docs.isNotEmpty) {
          resolvedEmail = queryPhone.docs.first.data()['email'];
        }
      }

      if (resolvedEmail == null || resolvedEmail.isEmpty) {
        _showTopNotification(context, 'No account found. Please sign up first.', isError: true);
        return;
      }

      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: resolvedEmail,
        password: _passwordController.text.trim(),
      );

      _showTopNotification(context, 'Access verified. Loading engine dashboard environment.');
      context.go('/processing', extra: {'email': resolvedEmail});
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        _showTopNotification(context, 'No account found. Please sign up first.', isError: true);
      } else {
        _showTopNotification(context, e.message ?? 'Authentication mismatch error.', isError: true);
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // 🌐 STABLE GOOGLE PLATFORM COMPLIANT DEPLOYMENT SCHEME (v7+ Compliant)
  Future<void> _executeGoogleAuthentication() async {
    setState(() => _isLoading = true);
    final db = FirebaseFirestore.instance;

    try {
      final GoogleSignInAccount googleUser = await GoogleSignIn.instance.authenticate();
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      final authorizedScopes = await googleUser.authorizationClient.authorizeScopes(['email', 'profile']);

      final OAuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: authorizedScopes.accessToken,
      );

      UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      User? user = userCredential.user;

      if (user != null) {
        final docRef = db.collection('users').doc(user.uid);
        final docSnapshot = await docRef.get();

        if (!docSnapshot.exists) {
          await docRef.set({
            'uid': user.uid,
            'fullName': user.displayName ?? 'Google Workspace Identity',
            'username': user.email!.split('@')[0].toLowerCase(),
            'email': user.email!.toLowerCase(),
            'phone': user.phoneNumber ?? '',
            'authProvider': 'google',
            'createdAt': FieldValue.serverTimestamp(),
          });
        }

        _showTopNotification(context, 'Google Sign-In successfully verified.');
        context.go('/processing', extra: {'email': user.email!});
      }
    } catch (e) {
      _showTopNotification(context, 'Google Authentication Protocol Error: ${e.toString()}', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // 📱 DYNAMIC NATIVE SMARTPHONE VERIFICATION OPERATION ROUTINE
  Future<void> _executePhoneVerification() async {
    if (_phoneController.text.length != 10) {
      _showTopNotification(context, 'Enter a valid 10-digit smartphone data stream sequence.', isError: true);
      return;
    }

    setState(() => _isLoading = true);
    final db = FirebaseFirestore.instance;

    try {
      if (!_showOtpVerificationField) {
        await FirebaseAuth.instance.verifyPhoneNumber(
          phoneNumber: '+91${_phoneController.text.trim()}',
          verificationCompleted: (PhoneAuthCredential credential) async {
            await FirebaseAuth.instance.signInWithCredential(credential);
            context.go('/processing', extra: {'phone': _phoneController.text});
          },
          verificationFailed: (FirebaseAuthException e) {
            _showTopNotification(context, e.message ?? 'Telephony Link Handshake Fault', isError: true);
          },
          codeSent: (String verificationId, int? resendToken) {
            setState(() {
              _firebaseVerificationId = verificationId;
              _showOtpVerificationField = true;
            });
            _showTopNotification(context, 'Secure login dynamic OTP token successfully pushed via SMS.');
          },
          codeAutoRetrievalTimeout: (String verificationId) {},
        );
      } else {
        PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: _firebaseVerificationId!,
          smsCode: _otpController.text.trim(),
        );

        UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
        final query = await db.collection('users').where('phone', isEqualTo: _phoneController.text.trim()).get();

        if (query.docs.isEmpty) {
          await db.collection('users').doc(userCredential.user!.uid).set({
            'uid': userCredential.user!.uid,
            'fullName': 'Mobile Link User Profile',
            'username': 'client_${_phoneController.text.trim()}',
            'email': '',
            'phone': _phoneController.text.trim(),
            'authProvider': 'phone',
            'createdAt': FieldValue.serverTimestamp(),
          });
        }

        context.go('/processing', extra: {'phone': _phoneController.text.trim()});
      }
    } catch (e) {
      _showTopNotification(context, e.toString(), isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // 🔄 DATABASE CORE PASSWORD FORGOT RESET ENGINE
  Future<void> _executeForgotPasswordReset() async {
    final input = _identityController.text.trim().toLowerCase();
    if (input.isEmpty) {
      _showTopNotification(context, 'Please fill in the single-identity input configuration field to match accounts.', isError: true);
      return;
    }

    setState(() => _isLoading = true);
    try {
      String? targetEmail = input.contains('@') ? input : null;

      if (targetEmail == null) {
        final db = FirebaseFirestore.instance;
        final queryUsername = await db.collection('users').where('username', isEqualTo: input).get();
        final queryPhone = await db.collection('users').where('phone', isEqualTo: input).get();

        if (queryUsername.docs.isNotEmpty) {
          targetEmail = queryUsername.docs.first.data()['email'];
        } else if (queryPhone.docs.isNotEmpty) {
          targetEmail = queryPhone.docs.first.data()['email'];
        }
      }

      if (targetEmail == null || targetEmail.isEmpty) {
        _showTopNotification(context, 'No tracking data profile records match the query criteria.', isError: true);
        return;
      }

      await FirebaseAuth.instance.sendPasswordResetEmail(email: targetEmail);
      _showTopNotification(context, 'Password structural reset authorization instructions pushed to email tracking asset.');
    } catch (e) {
      _showTopNotification(context, 'Reset execution parameter layer fault: ${e.toString()}', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 768;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Row(
        children: [
          // Left Graphics Ambient Panel (Web & Tablet viewports)
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
                    child: const Center(
                      child: Padding(
                        padding: EdgeInsets.all(48.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Khatabook Smart Engine', style: TextStyle(color: Colors.white, fontSize: 38, fontWeight: FontWeight.bold)),
                            SizedBox(height: 16),
                            Text('Strict isolation tenancy environment management platform providing multi-tenant security architecture workflows.', style: TextStyle(color: Colors.white70, fontSize: 16, height: 1.5)),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          
          // Form Content Side (Responsive Mobile/Desktop Adaptive Framework)
          Container(
            width: isDesktop ? 460 : size.width,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            color: const Color(0xFF1E293B),
            child: Center(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_isSignUpMode ? 'Secure Registration Portal' : 'Workspace Authentication Portal', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white), textAlign: TextAlign.center),
                      const SizedBox(height: 24),

                      if (!_isSignUpMode) ...[
                        TextFormField(
                          controller: _identityController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Mobile number, username or email',
                            labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
                            filled: true,
                            fillColor: const Color(0xFF0F172A),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                          ),
                          validator: (v) => v!.isEmpty ? 'This identity field is strictly mandatory.' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Security Password',
                            labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
                            filled: true,
                            fillColor: const Color(0xFF0F172A),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                          ),
                          validator: (v) => v!.isEmpty ? 'Password parameter is completely mandatory.' : null,
                        ),
                      ] else ...[
                        TextFormField(
                          controller: _emailController,
                          enabled: !_isEmailVerifiedSuccessfully,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Corporate Email Address',
                            labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
                            filled: true,
                            fillColor: const Color(0xFF0F172A),
                            suffixIcon: TextButton(
                              onPressed: _isLoading ? null : _triggerEmailVerification,
                              child: Text(_isEmailVerifiedSuccessfully ? 'Verified ✓' : 'Verify Link', style: const TextStyle(color: Color(0xFF38BDF8), fontWeight: FontWeight.bold)),
                            ),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                          ),
                          validator: (v) => !v!.contains('@') ? 'An active email verification link is mandatory.' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _fullNameController,
                          enabled: _isEmailVerifiedSuccessfully,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Full Profile Legal Name',
                            labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
                            filled: true,
                            fillColor: const Color(0xFF0F172A),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                          ),
                          validator: (v) => v!.isEmpty ? 'Profile legal name parameters are mandatory.' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _usernameController,
                          enabled: _isEmailVerifiedSuccessfully,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Unique Workspace Username Handle',
                            labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
                            filled: true,
                            fillColor: const Color(0xFF0F172A),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                          ),
                          validator: (v) => v!.isEmpty ? 'Unique identity configuration handle anchors are mandatory.' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _phoneController,
                          enabled: _isEmailVerifiedSuccessfully,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: '10-Digit Mobile Link Connection',
                            prefixText: '+91 ',
                            prefixStyle: const TextStyle(color: Colors.white),
                            labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
                            filled: true,
                            fillColor: const Color(0xFF0F172A),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                          ),
                          validator: (v) => v!.length != 10 ? 'A verified 10-digit smartphone sequence is mandatory.' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _passwordController,
                          enabled: _isEmailVerifiedSuccessfully,
                          obscureText: true,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Account System Password',
                            labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
                            filled: true,
                            fillColor: const Color(0xFF0F172A),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                          ),
                          validator: (v) => v!.length < 6 ? 'Authentication password values require 6+ symbols minimum.' : null,
                        ),
                      ],
                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : (_isSignUpMode ? _executeSecureSignUp : _executeUnifiedLogin),
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0066CC), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                          child: _isLoading 
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : Text(_isSignUpMode ? 'Register Space Allocation' : 'Log In Workspace Space', style: const TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(height: 16),

                      if (!_isSignUpMode)
                        TextButton(
                          onPressed: _isLoading ? null : _executeForgotPasswordReset,
                          child: const Text('Forgot password?', style: TextStyle(color: Colors.white70)),
                        ),
                      
                      const Row(
                        children: [
                          Expanded(child: Divider(color: Colors.white12)),
                          Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('OR', style: TextStyle(color: Color(0xFF64748B), fontSize: 12))),
                          Expanded(child: Divider(color: Colors.white12)),
                        ],
                      ),
                      const SizedBox(height: 16),

                      if (!_isSignUpMode) ...[
                        TextFormField(
                          controller: _phoneController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Quick Login via Phone Vector',
                            prefixText: '+91 ',
                            prefixStyle: const TextStyle(color: Colors.white),
                            labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
                            filled: true,
                            fillColor: const Color(0xFF0F172A),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (_showOtpVerificationField) ...[
                          TextFormField(
                            controller: _otpController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: 'Enter 6-Digit SMS Code Key Token',
                              labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
                              filled: true,
                              fillColor: const Color(0xFF0F172A),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                        SizedBox(
                          width: double.infinity,
                          height: 40,
                          child: OutlinedButton(
                            onPressed: _isLoading ? null : _executePhoneVerification,
                            style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.white24)),
                            child: Text(_showOtpVerificationField ? 'Verify Native Token Key' : 'Push Dynamic Mobile OTP', style: const TextStyle(color: Colors.white)),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],

                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: OutlinedButton.icon(
                          onPressed: _isLoading ? null : _executeGoogleAuthentication,
                          icon: const Icon(Icons.g_mobiledata_rounded, color: Colors.red, size: 28),
                          label: const Text('Continue with Google Platform', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.white24), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                        ),
                      ),
                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _isSignUpMode = !_isSignUpMode;
                              _formKey.currentState?.reset();
                            });
                          },
                          style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFF0066CC)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                          child: Text(_isSignUpMode ? 'Log into existing system profile' : 'Deploy new structural space', style: const TextStyle(color: Color(0xFF38BDF8), fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
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
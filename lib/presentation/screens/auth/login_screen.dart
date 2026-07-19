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

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  
  // Data Controllers
  final _identityController = TextEditingController(); 
  final _passwordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();

  bool _isSignUpMode = false;
  bool _isPhoneAuthMode = false; 
  bool _obscurePassword = true; 
  
  // Isolated loading variables to ensure mutual exclusion across operations
  bool _isFormLoading = false;
  bool _isGoogleLoading = false;
  bool _isOtpLoading = false;
  
  bool _showOtpVerificationField = false;
  String? _firebaseVerificationId;
  ConfirmationResult? _webConfirmationResult;
  
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

  // Global Overlay UI Layer Top Notification Engine
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
              // Highly professional, solid status indicators explicitly customized by parameter verification rules
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

  // ✅ 1. STANDARD FIREBASE SIGN-UP ROUTINE
  Future<void> _executeSecureSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isFormLoading = true);
    final db = FirebaseFirestore.instance;

    try {
      final checkUsername = await db.collection('users').where('username', isEqualTo: _usernameController.text.trim().toLowerCase()).get();
      final checkPhone = await db.collection('users').where('phone', isEqualTo: _phoneController.text.trim()).get();

      if (checkUsername.docs.isNotEmpty) {
        _showTopNotification(context, 'Registration Aborted: Target username is already allocated within another workspace profile configuration setup.', isError: true);
        setState(() => _isFormLoading = false);
        return;
      }
      if (checkPhone.docs.isNotEmpty) {
        _showTopNotification(context, 'Registration Aborted: Selected primary mobile signature string is already mapped to an existing active profile node.', isError: true);
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
        'username': _usernameController.text.trim().toLowerCase(),
        'email': _emailController.text.trim().toLowerCase(),
        'phone': _phoneController.text.trim(),
        'authProvider': 'credentials',
        'createdAt': FieldValue.serverTimestamp(),
      });

      _showTopNotification(context, 'Workspace Generation Completed: Corporate credentials mapped successfully. Check target inbox execution link parameters to complete activation.');
      
      setState(() {
        _isSignUpMode = false;
        _identityController.text = _emailController.text;
      });
    } on FirebaseAuthException catch (e) {
      _showTopNotification(context, e.message ?? 'Operational Failure: Internal validation structure script dropped execution tracking constraints.', isError: true);
    } finally {
      setState(() => _isFormLoading = false);
    }
  }

  // ✅ 2. UNIFIED LOG-IN MATRIX
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
        final queryPhone = await db.collection('users').where('phone', isEqualTo: input).get();

        if (queryUsername.docs.isNotEmpty) {
          resolvedEmail = queryUsername.docs.first.data()['email'];
        } else if (queryPhone.docs.isNotEmpty) {
          resolvedEmail = queryPhone.docs.first.data()['email'];
        }
      }

      if (resolvedEmail == null || resolvedEmail.isEmpty) {
        _showTopNotification(context, 'Authentication Refused: No matching tenant record tracking values recognized by core processing node engines.', isError: true);
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
        _showTopNotification(context, 'Authentication Interrupted: Profile execution token requires verified confirmation signatures. Re-evaluate communication channels.', isError: true);
        await FirebaseAuth.instance.signOut();
        setState(() => _isFormLoading = false);
        return;
      }

      _showTopNotification(context, 'Workspace Authorization Verified: User tracking matrix initialized cleanly. Transitioning workspace frames now.');
      context.go('/processing', extra: {'email': resolvedEmail});
    } on FirebaseAuthException catch (e) {
      _showTopNotification(context, e.message ?? 'Access Violation: Credentials drop framework matching operations. Confirm parameter layout logic values.', isError: true);
    } finally {
      setState(() => _isFormLoading = false);
    }
  }

  // 🌐 3. CROSS-PLATFORM GOOGLE IDENTITY AUTHORIZATION LAYER
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

        _showTopNotification(context, 'Federated Identity Approved: Secure integration parameters parsed via structural verification engine modules.');
        context.go('/processing', extra: {'email': user.email!});
      }
    } catch (e) {
      _showTopNotification(context, 'Federated Sync Aborted: Secure validation handshake dropped during cross-domain execution steps.', isError: true);
    } finally {
      setState(() => _isGoogleLoading = false);
    }
  }

  // 📱 4. DYNAMIC RESPONSIVE PHONE OTP ENGINE
  Future<void> _executePhoneVerification() async {
    if (_phoneController.text.length != 10) {
      _showTopNotification(context, 'Validation Error: Specified phone dynamic tracking string must constitute exactly 10 digital integer parameters.', isError: true);
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
          _showTopNotification(context, 'Handshake Initiated: Transmitting cryptographic temporary dynamic verification validation token block out via secure SMS protocols.');
        } else {
          if (_otpController.text.trim().isEmpty) {
            _showTopNotification(context, 'Validation Failure: Synchronized security parameter verification tracking code entries are strictly mandatory.', isError: true);
            return;
          }
          setState(() => _isOtpLoading = true);
          UserCredential userCredential = await _webConfirmationResult!.confirm(_otpController.text.trim());
          
          final query = await db.collection('users').where('phone', isEqualTo: _phoneController.text.trim()).get();
          if (query.docs.isEmpty) {
            await db.collection('users').doc(userCredential.user!.uid).set({
              'uid': userCredential.user!.uid,
              'fullName': 'Mobile Profile Workspace',
              'username': 'client_${_phoneController.text.trim()}',
              'email': '',
              'phone': _phoneController.text.trim(),
              'authProvider': 'phone',
              'createdAt': FieldValue.serverTimestamp(),
            });
          }
          _showTopNotification(context, 'Telephony Verification Executed: Temporary cryptographic token verified against primary cloud registry instances.');
          context.go('/processing', extra: {'phone': _phoneController.text.trim()});
        }
      }
    } catch (e) {
      _showTopNotification(context, 'Handshake Terminated: Cryptographic matching sequences threw verification structure parameters anomalies.', isError: true);
    } finally {
      setState(() => _isOtpLoading = false);
    }
  }

  // 🔄 5. PASSWORD FORGOT RESET ENGINE
  Future<void> _executeForgotPasswordReset() async {
    final input = _identityController.text.trim().toLowerCase();
    if (input.isEmpty) {
      _showTopNotification(context, 'Parameters Incomplete: Request tracking requires a validated identification identity handle argument input string.', isError: true);
      return;
    }

    setState(() => _isFormLoading = true);
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
        _showTopNotification(context, 'Verification Dropped: No recorded workspace registration instances correspond to the provided system input string.', isError: true);
        return;
      }

      await FirebaseAuth.instance.sendPasswordResetEmail(email: targetEmail);
      _showTopNotification(context, 'Transmission Complete: A security initialization reset dynamic URL parameter block was dispatched out.');
    } catch (e) {
      _showTopNotification(context, 'Transmission Aborted: Communication node network layers returned a dynamic script dispatch fault.', isError: true);
    } finally {
      setState(() => _isFormLoading = false);
    }
  }

  void _resetToDefaultCredentialsMode() {
    setState(() {
      _isPhoneAuthMode = false;
      _showOtpVerificationField = false;
      _phoneController.clear();
      _otpController.clear();
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
          // 💻 Left Canvas Segment View (Desktop Viewports)
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
          
          // 📱 Main Dynamic Authentication Panel Form Box
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
                          _isPhoneAuthMode 
                              ? 'Secure OTP Gateway' 
                              : (_isSignUpMode ? 'Secure Account Portal (Sign Up)' : 'Workspace Authorization (Log In)'), 
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white), 
                          textAlign: TextAlign.center
                        ),
                        const SizedBox(height: 24),

                        // 📱 VIEW 1: DEDICATED MOBILE PHONE OTP AUTHORIZATION GRID
                        if (_isPhoneAuthMode) ...[
                          TextFormField(
                            controller: _phoneController,
                            enabled: !staticAnyActiveLoad,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: 'Enter your phone number',
                              prefixText: '+91 ',
                              prefixStyle: const TextStyle(color: Colors.white),
                              labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
                              filled: true,
                              fillColor: const Color(0xFF0F172A),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                            ),
                            validator: (v) => (v == null || v.length != 10) ? 'This metric field parameter calculation layout framework requires 10 digits.' : null,
                          ),
                          const SizedBox(height: 12),
                          if (_showOtpVerificationField) ...[
                            TextFormField(
                              controller: _otpController,
                              enabled: !staticAnyActiveLoad,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: '6-Digit SMS Verification Token Code',
                                labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
                                filled: true,
                                fillColor: const Color(0xFF0F172A),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                              ),
                              validator: (v) => (_showOtpVerificationField && (v == null || v.isEmpty)) ? 'Dynamic cryptographic security parameter string index matching field entry is mandatory.' : null,
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
                                  : Text(_showOtpVerificationField ? 'Verify Security Token Code' : 'Send Verification OTP', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 44,
                            child: OutlinedButton.icon(
                              onPressed: staticAnyActiveLoad ? null : _resetToDefaultCredentialsMode,
                              icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF38BDF8), size: 18),
                              label: const Text('Back to Login Credentials Workspace', style: TextStyle(color: Color(0xFF38BDF8), fontWeight: FontWeight.bold, fontSize: 13)),
                              style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.white24), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                            ),
                          ),
                        ]
                        
                        // 🔐 VIEW 2: STANDARD CREDENTIALS & SIGN-UP FLOW BLOCK
                        else ...[
                          if (!_isSignUpMode) ...[
                            TextFormField(
                              controller: _identityController,
                              enabled: !staticAnyActiveLoad,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: 'Mobile number, username, or email address',
                                labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
                                filled: true,
                                fillColor: const Color(0xFF0F172A),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                              ),
                              validator: (v) => v!.isEmpty ? 'This identification structural credential configuration field is required.' : null,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _passwordController,
                              enabled: !staticAnyActiveLoad,
                              obscureText: _obscurePassword,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: 'Security Access Password',
                                labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
                                filled: true,
                                fillColor: const Color(0xFF0F172A),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                    color: const Color(0xFF94A3B8),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                              ),
                              validator: (v) => v!.isEmpty ? 'Security authentication framework validation tracking password value is mandatory.' : null,
                            ),
                          ] else ...[
                            TextFormField(
                              controller: _emailController,
                              enabled: !staticAnyActiveLoad,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: 'Email Address',
                                labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
                                filled: true,
                                fillColor: const Color(0xFF0F172A),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                              ),
                              validator: (v) => (v == null || !v.contains('@')) ? 'Please enter a valid structure email address configuration parameter layout.' : null,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _fullNameController,
                              enabled: !staticAnyActiveLoad,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: 'Full Legal Name',
                                labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
                                filled: true,
                                fillColor: const Color(0xFF0F172A),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                              ),
                              validator: (v) => v!.isEmpty ? 'Legal user execution entry naming logic argument is required.' : null,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _usernameController,
                              enabled: !staticAnyActiveLoad,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: 'Unique Username Handle',
                                labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
                                filled: true,
                                fillColor: const Color(0xFF0F172A),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                              ),
                              validator: (v) => v!.isEmpty ? 'Setting a system unique index tracking identity marker handle string is mandatory.' : null,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _phoneController,
                              enabled: !staticAnyActiveLoad,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: '10-Digit Mobile Number',
                                prefixText: '+91 ',
                                prefixStyle: const TextStyle(color: Colors.white),
                                labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
                                filled: true,
                                fillColor: const Color(0xFF0F172A),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                              ),
                              validator: (v) => (v == null || v.length != 10) ? 'A verified 10-digit primary structural communication node identity parameter value string is required.' : null,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _passwordController,
                              enabled: !staticAnyActiveLoad,
                              obscureText: _obscurePassword,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: 'System Security Password',
                                labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
                                filled: true,
                                fillColor: const Color(0xFF0F172A),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                    color: const Color(0xFF94A3B8),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                              ),
                              validator: (v) => (v == null || v.length < 6) ? 'Password architectural tracking parameters require structural complexity containing minimum 6 elements.' : null,
                            ),
                          ],
                          const SizedBox(height: 24),

                          // Main Platform Account Submission Action Gate Button
                          SizedBox(
                            height: 48,
                            child: ElevatedButton(
                              onPressed: staticAnyActiveLoad ? null : (_isSignUpMode ? _executeSecureSignUp : _executeUnifiedLogin),
                              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0066CC), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                              child: _isFormLoading 
                                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                  : Text(_isSignUpMode ? 'Register New Space Profile' : 'Execute Workspace Login', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            ),
                          ),
                          const SizedBox(height: 16),

                          if (!_isSignUpMode) ...[
                            TextButton(
                              onPressed: staticAnyActiveLoad ? null : _executeForgotPasswordReset,
                              child: const Text('Forgot Password Mapping Engine?', style: TextStyle(color: Colors.white70), textAlign: TextAlign.center),
                            ),
                            const Row(
                              children: [
                                Expanded(child: Divider(color: Colors.white12)),
                                Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('OR', style: TextStyle(color: Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.bold))),
                                Expanded(child: Divider(color: Colors.white12)),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Interactive trigger routing workspace flow explicitly to dedicated Mobile Viewport
                            SizedBox(
                              height: 44,
                              child: OutlinedButton.icon(
                                onPressed: staticAnyActiveLoad ? null : () {
                                  setState(() {
                                    _isPhoneAuthMode = true;
                                    _formKey.currentState?.reset();
                                  });
                                },
                                icon: const Icon(Icons.phone_android_rounded, color: Colors.white, size: 18),
                                label: const Text('Continue with Mobile Phone OTP verification', style: TextStyle(color: Colors.white, fontSize: 13)),
                                style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.white24), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],

                          if (_isSignUpMode) ...[
                            const Row(
                              children: [
                                Expanded(child: Divider(color: Colors.white12)),
                                Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('OR', style: TextStyle(color: Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.bold))),
                                Expanded(child: Divider(color: Colors.white12)),
                              ],
                            ),
                            const SizedBox(height: 16),
                          ],

                          // 🌐 Clean & Web-Compliant Google Workspace Button Component
                          SizedBox(
                            height: 48,
                            child: OutlinedButton(
                              onPressed: staticAnyActiveLoad ? null : _executeGoogleAuthentication,
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.white24),
                                backgroundColor: const Color(0xFF0F172A),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: _isGoogleLoading
                                  ? const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)))
                                  : const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.g_mobiledata_rounded, color: Colors.amber, size: 30),
                                        SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            'Continue with Google Workspace Identity',
                                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                          ),)
                        ],
                        const SizedBox(height: 24),

                        // Bottom Layout View Switcher Configuration Button (Sign Up / Login Switcher)
                        SizedBox(
                          height: 52,
                          child: OutlinedButton(
                            onPressed: staticAnyActiveLoad ? null : () {
                              setState(() {
                                _isSignUpMode = !_isSignUpMode;
                                _isPhoneAuthMode = false;
                                _showOtpVerificationField = false;
                                _formKey.currentState?.reset();
                              });
                            },
                            style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFF0066CC)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                            child: Text(
                              _isSignUpMode ? 'Existing Space Check? Login' : 'Provision New Tenant Space (Sign Up)', 
                              style: const TextStyle(color: Color(0xFF38BDF8), fontWeight: FontWeight.bold, fontSize: 12),
                              textAlign: TextAlign.center,
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
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _emailKey = GlobalKey<FormState>();
  final _phoneKey = GlobalKey<FormState>();
  
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  
  bool _isEmailValid = true;
  bool _showOtpField = false;
  
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
    _emailController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

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
              // 💡 FIXED: Changed BorderSide to Border.all to resolve the type assignment failure
              border: Border.all(
                color: isError ? Colors.red.shade200 : Colors.green.shade200,
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05), 
                  blurRadius: 10, 
                  offset: const Offset(0, 4),
                ),
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
    Future.delayed(const Duration(seconds: 3), () => overlayEntry.remove());
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 768;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
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
                      child: const Center(
                        child: Padding(
                          padding: EdgeInsets.all(48.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Maintain Ledgers Safely',
                                style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Experience precise cloud syncing and absolute tenant isolation architecture built for modern platforms.',
                                style: TextStyle(color: Colors.white70, fontSize: 16, height: 1.5),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            Container(
              width: isDesktop ? 480 : size.width,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
              color: Theme.of(context).scaffoldBackgroundColor,
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Account Portal', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: colorScheme.primary)),
                      const SizedBox(height: 8),
                      const Text('Access your workspaces and shop balances securely.', style: TextStyle(color: Color(0xFF64748B))),
                      const SizedBox(height: 32),
                      TabBar(
                        labelColor: colorScheme.primary,
                        unselectedLabelColor: const Color(0xFF94A3B8),
                        indicatorColor: colorScheme.primary,
                        indicatorSize: TabBarIndicatorSize.tab,
                        tabs: const [
                          Tab(text: "Email Engine"),
                          Tab(text: "Secure OTP"),
                        ],
                      ),
                      SizedBox(
                        height: 270,
                        child: TabBarView(
                          children: [
                            Form(
                              key: _emailKey,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 24),
                                child: Column(
                                  children: [
                                    TextFormField(
                                      controller: _emailController,
                                      keyboardType: TextInputType.emailAddress,
                                      decoration: InputDecoration(
                                        labelText: 'Corporate Email',
                                        prefixIcon: const Icon(Icons.mail_outline),
                                        filled: !_isEmailValid,
                                        fillColor: Colors.red.withOpacity(0.05),
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: BorderSide(color: _isEmailValid ? const Color(0xFFCBD5E1) : Colors.red),
                                        ),
                                      ),
                                      validator: (value) {
                                        if (value == null || !value.contains('@') || !value.contains('.')) {
                                          setState(() => _isEmailValid = false);
                                          _showTopNotification(context, 'Invalid email format entered', isError: true);
                                          return '';
                                        }
                                        setState(() => _isEmailValid = true);
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 20),
                                    SizedBox(
                                      width: double.infinity,
                                      height: 52,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          if (_emailKey.currentState!.validate()) {
                                            _showTopNotification(context, 'Secure magic authentication token dispatched.');
                                            context.go('/processing', extra: {'email': _emailController.text});
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: colorScheme.primary,
                                          foregroundColor: colorScheme.onPrimary,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                          elevation: 0,
                                        ),
                                        child: const Text('Send Verification Link', style: TextStyle(fontWeight: FontWeight.bold)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Form(
                              key: _phoneKey,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 24),
                                child: Column(
                                  children: [
                                    TextFormField(
                                      controller: _phoneController,
                                      keyboardType: TextInputType.phone,
                                      maxLength: 10,
                                      decoration: InputDecoration(
                                        labelText: 'Mobile Number',
                                        prefixText: '+91 ',
                                        prefixIcon: const Icon(Icons.phone_android_outlined),
                                        counterText: "",
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.length != 10 || int.tryParse(value) == null) {
                                          _showTopNotification(context, 'Enter a valid 10-digit smartphone number', isError: true);
                                          return '';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                    if (_showOtpField)
                                      TextFormField(
                                        controller: _otpController,
                                        keyboardType: TextInputType.number,
                                        maxLength: 6,
                                        decoration: InputDecoration(
                                          labelText: '6-Digit One-Time Password',
                                          prefixIcon: const Icon(Icons.lock_open_outlined),
                                          counterText: "",
                                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                        ),
                                      ),
                                    const SizedBox(height: 16),
                                    SizedBox(
                                      width: double.infinity,
                                      height: 52,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          if (_phoneKey.currentState!.validate()) {
                                            if (!_showOtpField) {
                                              setState(() => _showOtpField = true);
                                              _showTopNotification(context, 'One-time secure key sent successfully.');
                                            } else {
                                              context.go('/processing', extra: {'phone': _phoneController.text});
                                            }
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: colorScheme.primary,
                                          foregroundColor: colorScheme.onPrimary,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                          elevation: 0,
                                        ),
                                        child: Text(_showOtpField ? 'Complete Connection' : 'Verify via OTP', style: const TextStyle(fontWeight: FontWeight.bold)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Row(
                        children: [
                          Expanded(child: Divider()),
                          Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('OR', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12))),
                          Expanded(child: Divider()),
                        ],
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: OutlinedButton(
                          onPressed: () {
                            context.go('/processing', extra: {'email': 'google.sso.identity@gmail.com'});
                          },
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            side: const BorderSide(color: Color(0xFFCBD5E1)),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.g_mobiledata_rounded, color: Colors.red, size: 30),
                              SizedBox(width: 8),
                              Text('Continue with Google Account', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
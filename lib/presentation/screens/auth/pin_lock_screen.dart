import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/app_config.dart';
import '../../../core/security/biometric_service.dart';
import '../../../core/security/encryption_service.dart';

class PinLockScreen extends ConsumerStatefulWidget {
  final bool isSettingPin; // नवीन पिन सेट करत आहे की पडताळणी करत आहे?

  const PinLockScreen({
    super.key,
    this.isSettingPin = false,
  });

  @override
  ConsumerState<PinLockScreen> createState() => _PinLockScreenState();
}

class _PinLockScreenState extends ConsumerState<PinLockScreen> {
  final BiometricService _biometricService = BiometricService();
  final List<String> _enteredPin = [];
  String? _firstEnteredPinForSetup;
  String _statusMessage = 'Enter Security PIN';

  @override
  void initState() {
    super.initState();
    if (!widget.isSettingPin) {
      _triggerBiometricAuth();
    } else {
      _statusMessage = 'Set 4-Digit Security PIN';
    }
  }

  // 🧬 बायोमेट्रिक ऑथेंटिकेशन ट्रिगर करा (Fingerprint / Face Unlock)
  Future<void> _triggerBiometricAuth() async {
    final isAvailable = await _biometricService.isHardwareAvailable();
    if (isAvailable) {
      final authenticated = await _biometricService.authenticateUser(
        reasonMessage: 'Scan biometric sensor to unlock Khatabook Smart',
      );
      if (authenticated && mounted) {
        context.go('/home');
      }
    }
  }

  // 🔢 कीपॅड इनपुट हाताळणी
  void _onKeyPress(String value) {
    if (_enteredPin.length < AppConfig.pinLength) {
      setState(() {
        _enteredPin.add(value);
      });

      if (_enteredPin.length == AppConfig.pinLength) {
        _verifyPin();
      }
    }
  }

  void _onBackspace() {
    if (_enteredPin.isNotEmpty) {
      setState(() {
        _enteredPin.removeLast();
      });
    }
  }

  // 🛡️ पिन पडताळणी आणि जतन प्रक्रिया
  void _verifyPin() {
    final String currentPinStr = _enteredPin.join();

    if (widget.isSettingPin) {
      if (_firstEnteredPinForSetup == null) {
        // सेटअपचा पहिला टप्पा पूर्ण
        setState(() {
          _firstEnteredPinForSetup = currentPinStr;
          _enteredPin.clear();
          _statusMessage = 'Confirm your PIN';
        });
      } else {
        // सेटअपचा दुसरा टप्पा (Confirm PIN)
        if (_firstEnteredPinForSetup == currentPinStr) {
          // पिन यशस्वीरित्या सेव्ह करा (SHA-256 कूटबद्धीकरणासह)
          final secureHash = EncryptionService.hashPin(currentPinStr);
          // TODO: हा secureHash हाइव्हमध्ये सेव्ह करा

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('PIN configured successfully!'), backgroundColor: Colors.green),
          );
          context.go('/home');
        } else {
          setState(() {
            _enteredPin.clear();
            _firstEnteredPinForSetup = null;
            _statusMessage = 'PIN mismatch! Set 4-Digit PIN again';
          });
        }
      }
    } else {
      // ऑथेंटिकेशन पडताळणी टप्पा
      // मॉक पडताळणी (प्रदर्शनासाठी '1234' पिन वापरला आहे)
      if (currentPinStr == '1234') {
        context.go('/home');
      } else {
        setState(() {
          _enteredPin.clear();
          _statusMessage = 'Incorrect PIN! Try Again';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Verification Failed! Please type correct security PIN.'), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.security, size: 64, color: Colors.deepPurple),
            const SizedBox(height: 16),
            Text(
              _statusMessage,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            // 🟢 पिन इंडिकेटर डॉट्स (PIN Indicator Dots)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(AppConfig.pinLength, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: index < _enteredPin.length ? Colors.deepPurple : Colors.grey[300],
                  ),
                );
              }),
            ),
            const SizedBox(height: 48),

            // ⌨️ युझर कीपॅड ग्रिड (Numeric Keypad Grid)
            Container(
              constraints: const BoxConstraints(maxWidth: 320),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1.2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: 12,
                itemBuilder: (context, index) {
                  if (index == 9) {
                    return widget.isSettingPin
                        ? const SizedBox.shrink()
                        : IconButton(
                            icon: const Icon(Icons.fingerprint, size: 36, color: Colors.deepPurple),
                            onPressed: _triggerBiometricAuth,
                          );
                  }
                  if (index == 11) {
                    return IconButton(
                      icon: const Icon(Icons.backspace_outlined, size: 28),
                      onPressed: _onBackspace,
                    );
                  }
                  final value = index == 10 ? '0' : '${index + 1}';
                  return InkWell(
                    onTap: () => _onKeyPress(value),
                    borderRadius: BorderRadius.circular(30),
                    child: Center(
                      child: Text(
                        value,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
}
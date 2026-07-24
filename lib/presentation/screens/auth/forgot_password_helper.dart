// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class ForgotPasswordHelper {
//   // ⚡ FAST TOP NOTIFICATION BANNER
//   static void _showToast(BuildContext context, String message, {bool isError = false}) {
//     if (!context.mounted) return;
//     ScaffoldMessenger.of(context).clearSnackBars();
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         dismissDirection: DismissDirection.up,
//         behavior: SnackBarBehavior.floating,
//         margin: EdgeInsets.only(
//           bottom: MediaQuery.of(context).size.height - 120,
//           left: 16,
//           right: 16,
//         ),
//         backgroundColor: isError ? const Color(0xFFEF4444) : const Color(0xFF10B981),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//         content: Row(
//           children: [
//             Icon(
//               isError ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded,
//               color: Colors.white,
//               size: 20,
//             ),
//             const SizedBox(width: 10),
//             Expanded(
//               child: Text(
//                 message,
//                 style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
//               ),
//             ),
//           ],
//         ),
//         duration: const Duration(milliseconds: 2500),
//       ),
//     );
//   }

//   // 🔒 SHOW FORGOT PASSWORD DIALOG
//   static void showForgotPasswordDialog(BuildContext context) {
//     final inputController = TextEditingController();
//     final otpController = TextEditingController();
//     final newPasswordController = TextEditingController();

//     int step = 1; // Step 1: Input Mobile/Email, Step 2: Enter OTP & New Password
//     bool isLoading = false;
//     String verificationId = '';
//     bool isPhoneMode = false;

//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext dialogContext) {
//         return StatefulBuilder(
//           builder: (context, setState) {
//             return AlertDialog(
//               backgroundColor: const Color(0xFF121824), // Dark Theme Accent
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(16),
//                 side: const BorderSide(color: Color(0xFF1E293B), width: 1.5),
//               ),
//               title: Row(
//                 children: [
//                   const Icon(Icons.lock_reset_rounded, color: Color(0xFFEF4444), size: 24),
//                   const SizedBox(width: 10),
//                   Text(
//                     step == 1 ? 'Reset Password' : 'Verify & Set Password',
//                     style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
//                   ),
//                 ],
//               ),
//               content: SingleChildScrollView(
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     if (step == 1) ...[
//                       const Text(
//                         'Enter your registered Mobile Number or Email Address to receive verification OTP.',
//                         style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
//                       ),
//                       const SizedBox(height: 16),
//                       TextFormField(
//                         controller: inputController,
//                         style: const TextStyle(color: Colors.white, fontSize: 14),
//                         decoration: InputDecoration(
//                           labelText: 'Mobile (+91...) or Email',
//                           labelStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
//                           prefixIcon: const Icon(Icons.person_outline, color: Color(0xFF64748B), size: 20),
//                           filled: true,
//                           fillColor: const Color(0xFF0B0F17),
//                           border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
//                         ),
//                       ),
//                     ] else ...[
//                       // STEP 2: ENTER OTP & NEW PASSWORD
//                       if (isPhoneMode) ...[
//                         TextFormField(
//                           controller: otpController,
//                           keyboardType: TextInputType.number,
//                           style: const TextStyle(color: Colors.white, fontSize: 14),
//                           decoration: InputDecoration(
//                             labelText: 'Enter 6-Digit SMS OTP',
//                             labelStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
//                             prefixIcon: const Icon(Icons.pin_outlined, color: Color(0xFF64748B), size: 20),
//                             filled: true,
//                             fillColor: const Color(0xFF0B0F17),
//                             border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
//                           ),
//                         ),
//                         const SizedBox(height: 12),
//                       ],
//                       TextFormField(
//                         controller: newPasswordController,
//                         obscureText: true,
//                         style: const TextStyle(color: Colors.white, fontSize: 14),
//                         decoration: InputDecoration(
//                           labelText: 'New Password',
//                           labelStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
//                           prefixIcon: const Icon(Icons.key_outlined, color: Color(0xFF64748B), size: 20),
//                           filled: true,
//                           fillColor: const Color(0xFF0B0F17),
//                           border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
//                         ),
//                       ),
//                     ],
//                   ],
//                 ),
//               ),
//               actions: [
//                 TextButton(
//                   onPressed: isLoading ? null : () => Navigator.of(dialogContext).pop(),
//                   child: const Text('Cancel', style: TextStyle(color: Color(0xFF94A3B8))),
//                 ),
//                 ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xFFEF4444),
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//                   ),
//                   onPressed: isLoading
//                       ? null
//                       : () async {
//                           final input = inputController.text.trim();

//                           if (step == 1) {
//                             if (input.isEmpty) {
//                               _showToast(context, 'Please enter Mobile Number or Email!', isError: true);
//                               return;
//                             }

//                             setState(() => isLoading = true);

//                             // CHECK IF INPUT IS EMAIL OR PHONE
//                             bool isEmail = input.contains('@');

//                             if (isEmail) {
//                               // EMAIL RESET LINK
//                               try {
//                                 await FirebaseAuth.instance.sendPasswordResetEmail(email: input);
//                                 if (dialogContext.mounted) {
//                                   Navigator.of(dialogContext).pop();
//                                   _showToast(context, 'Password reset link sent to your email!');
//                                 }
//                               } catch (e) {
//                                 _showToast(context, 'Failed to send reset email link!', isError: true);
//                               } finally {
//                                 if (dialogContext.mounted) setState(() => isLoading = false);
//                               }
//                             } else {
//                               // PHONE NUMBER OTP FLOW
//                               isPhoneMode = true;
//                               String phoneNumber = input.startsWith('+') ? input : '+91$input';

//                               await FirebaseAuth.instance.verifyPhoneNumber(
//                                 phoneNumber: phoneNumber,
//                                 verificationCompleted: (PhoneAuthCredential credential) {},
//                                 verificationFailed: (FirebaseAuthException e) {
//                                   if (dialogContext.mounted) setState(() => isLoading = false);
//                                   _showToast(context, 'OTP Verification failed: ${e.message}', isError: true);
//                                 },
//                                 codeSent: (String vId, int? resendToken) {
//                                   if (dialogContext.mounted) {
//                                     setState(() {
//                                       verificationId = vId;
//                                       step = 2; // Move to OTP Step
//                                       isLoading = false;
//                                     });
//                                   }
//                                   _showToast(context, 'OTP sent to $phoneNumber');
//                                 },
//                                 codeAutoRetrievalTimeout: (String vId) {
//                                   verificationId = vId;
//                                 },
//                               );
//                             }
//                           } else {
//                             // STEP 2: VERIFY OTP AND UPDATE PASSWORD
//                             final otp = otpController.text.trim();
//                             final newPass = newPasswordController.text.trim();

//                             if (newPass.length < 6) {
//                               _showToast(context, 'Password must be at least 6 characters!', isError: true);
//                               return;
//                             }

//                             setState(() => isLoading = true);

//                             try {
//                               if (isPhoneMode) {
//                                 PhoneAuthCredential credential = PhoneAuthProvider.credential(
//                                   verificationId: verificationId,
//                                   smsCode: otp,
//                                 );

//                                 UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
//                                 await userCredential.user?.updatePassword(newPass);

//                                 if (dialogContext.mounted) {
//                                   Navigator.of(dialogContext).pop();
//                                   _showToast(context, 'Password reset successfully!');
//                                 }
//                               }
//                             } catch (e) {
//                               _showToast(context, 'Invalid OTP or failed to update password!', isError: true);
//                             } finally {
//                               if (dialogContext.mounted) setState(() => isLoading = false);
//                             }
//                           }
//                         },
//                   child: isLoading
//                       ? const SizedBox(
//                           width: 16,
//                           height: 16,
//                           child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
//                         )
//                       : Text(
//                           step == 1 ? 'Send OTP / Link' : 'Update Password',
//                           style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//                         ),
//                 ),
//               ],
//             );
//           },
//         );
//       },
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPasswordHelper {
  // ⚡ TOP NOTIFICATION BANNER
  static void _showToast(BuildContext context, String message, {bool isError = false}) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        dismissDirection: DismissDirection.up,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height - 120,
          left: 16,
          right: 16,
        ),
        backgroundColor: isError ? const Color(0xFFEF4444) : const Color(0xFF10B981),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ],
        ),
        duration: const Duration(milliseconds: 3000),
      ),
    );
  }

  // 🔒 SECURE PASSWORD CHANGE DIALOG (WITH OLD PASSWORD RE-AUTHENTICATION)
  static void showForgotPasswordDialog(BuildContext context) {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    bool isLoading = false;
    bool hideOldPassword = true;
    bool hideNewPassword = true;
    bool hideConfirmPassword = true;
    bool isCheckboxChecked = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final dialogBg = isDark ? const Color(0xFF121824) : Colors.white;
        final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
        final subTextColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
        final inputBg = isDark ? const Color(0xFF0B0F17) : const Color(0xFFF1F5F9);
        final borderColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);

        final currentUser = FirebaseAuth.instance.currentUser;
        final username = currentUser?.email ?? currentUser?.phoneNumber ?? "Current User";

        return StatefulBuilder(
          builder: (context, setState) {
            return LayoutBuilder(
              builder: (context, constraints) {
                return AlertDialog(
                  backgroundColor: dialogBg,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: borderColor, width: 1.5),
                  ),
                  title: Row(
                    children: [
                      const Icon(Icons.lock_reset_rounded, color: Color(0xFFEF4444), size: 24),
                      const SizedBox(width: 10),
                      Text(
                        'Change Password',
                        style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ],
                  ),
                  content: SizedBox(
                    width: constraints.maxWidth > 600 ? 420 : double.infinity,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Enter your current and new password to update account security.',
                            style: TextStyle(color: subTextColor, fontSize: 13),
                          ),
                          const SizedBox(height: 16),

                          // 1. OLD PASSWORD FIELD (🔑 Session Fix साठी आवश्यक)
                          TextFormField(
                            controller: oldPasswordController,
                            obscureText: hideOldPassword,
                            style: TextStyle(color: textColor, fontSize: 14),
                            decoration: InputDecoration(
                              labelText: 'Current (Old) Password',
                              labelStyle: TextStyle(color: subTextColor, fontSize: 13),
                              prefixIcon: Icon(Icons.lock_clock_outlined, color: subTextColor, size: 20),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  hideOldPassword ? Icons.visibility_off : Icons.visibility,
                                  color: subTextColor,
                                  size: 20,
                                ),
                                onPressed: () => setState(() => hideOldPassword = !hideOldPassword),
                              ),
                              filled: true,
                              fillColor: inputBg,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // 2. NEW PASSWORD FIELD
                          TextFormField(
                            controller: newPasswordController,
                            obscureText: hideNewPassword,
                            style: TextStyle(color: textColor, fontSize: 14),
                            decoration: InputDecoration(
                              labelText: 'New Password',
                              labelStyle: TextStyle(color: subTextColor, fontSize: 13),
                              prefixIcon: Icon(Icons.key_outlined, color: subTextColor, size: 20),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  hideNewPassword ? Icons.visibility_off : Icons.visibility,
                                  color: subTextColor,
                                  size: 20,
                                ),
                                onPressed: () => setState(() => hideNewPassword = !hideNewPassword),
                              ),
                              filled: true,
                              fillColor: inputBg,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // 3. CONFIRM PASSWORD FIELD
                          TextFormField(
                            controller: confirmPasswordController,
                            obscureText: hideConfirmPassword,
                            style: TextStyle(color: textColor, fontSize: 14),
                            decoration: InputDecoration(
                              labelText: 'Confirm New Password',
                              labelStyle: TextStyle(color: subTextColor, fontSize: 13),
                              prefixIcon: Icon(Icons.lock_outline_rounded, color: subTextColor, size: 20),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  hideConfirmPassword ? Icons.visibility_off : Icons.visibility,
                                  color: subTextColor,
                                  size: 20,
                                ),
                                onPressed: () => setState(() => hideConfirmPassword = !hideConfirmPassword),
                              ),
                              filled: true,
                              fillColor: inputBg,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),

                          // 4. CHECKBOX FOR CURRENT USER CONFIRMATION
                          InkWell(
                            onTap: () {
                              setState(() {
                                isCheckboxChecked = !isCheckboxChecked;
                              });
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4.0),
                              child: Row(
                                children: [
                                  SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: Checkbox(
                                      value: isCheckboxChecked,
                                      activeColor: const Color(0xFFEF4444),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                      onChanged: (val) {
                                        setState(() {
                                          isCheckboxChecked = val ?? false;
                                        });
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Change password for current user ($username)',
                                      style: TextStyle(
                                        color: textColor,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: isLoading ? null : () => Navigator.of(dialogContext).pop(),
                      child: Text('Cancel', style: TextStyle(color: subTextColor)),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isCheckboxChecked ? const Color(0xFFEF4444) : Colors.grey,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: (isLoading || !isCheckboxChecked)
                          ? null
                          : () async {
                              final oldPass = oldPasswordController.text.trim();
                              final newPass = newPasswordController.text.trim();
                              final confirmPass = confirmPasswordController.text.trim();

                              if (oldPass.isEmpty || newPass.isEmpty || confirmPass.isEmpty) {
                                _showToast(context, 'Please enter all password fields!', isError: true);
                                return;
                              }

                              if (newPass.length < 6) {
                                _showToast(context, 'New Password must be at least 6 characters!', isError: true);
                                return;
                              }

                              if (newPass != confirmPass) {
                                _showToast(context, 'New Password and Confirm Password do not match!', isError: true);
                                return;
                              }

                              if (currentUser == null || currentUser.email == null) {
                                _showToast(context, 'No active email user session found!', isError: true);
                                return;
                              }

                              setState(() => isLoading = true);

                              try {
                                // 🔑 1. RE-AUTHENTICATE USER WITH OLD PASSWORD
                                AuthCredential credential = EmailAuthProvider.credential(
                                  email: currentUser.email!,
                                  password: oldPass,
                                );

                                await currentUser.reauthenticateWithCredential(credential);

                                // 🟢 2. UPDATE TO NEW PASSWORD
                                await currentUser.updatePassword(newPass);

                                if (dialogContext.mounted) {
                                  Navigator.of(dialogContext).pop();
                                  _showToast(context, 'Password changed successfully!');
                                }
                              } on FirebaseAuthException catch (e) {
                                if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
                                  _showToast(context, 'Incorrect Old Password! Please check and try again.', isError: true);
                                } else {
                                  _showToast(context, 'Error: ${e.message}', isError: true);
                                }
                              } catch (e) {
                                _showToast(context, 'Failed to update password. Try again.', isError: true);
                              } finally {
                                if (dialogContext.mounted) setState(() => isLoading = false);
                              }
                            },
                      child: isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Text(
                              'Update Password',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}
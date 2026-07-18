import 'package:flutter/material.dart';

class TrustedDeviceBanner extends StatelessWidget {
  final String deviceName;
  final String loginTime;
  final bool isSuspicious;

  const TrustedDeviceBanner({
    super.key,
    required this.deviceName,
    required this.loginTime,
    required this.isSuspicious,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isSuspicious ? Colors.red.shade50 : Colors.green.shade50,
        border: Border(
          bottom: BorderSide(
            color: isSuspicious ? Colors.red.shade300 : Colors.green.shade300,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isSuspicious ? Icons.gpp_bad_outlined : Icons.verified_user_outlined,
            color: isSuspicious ? Colors.red : Colors.green,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isSuspicious ? 'Suspicious Login Detected' : 'Trusted Device Verified',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isSuspicious ? Colors.red.shade900 : Colors.green.shade900,
                  ),
                ),
                Text(
                  'Connected via $deviceName on $loginTime',
                  style: TextStyle(
                    fontSize: 12,
                    color: isSuspicious ? Colors.red.shade700 : Colors.green.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
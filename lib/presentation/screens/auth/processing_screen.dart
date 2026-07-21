// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';

// class ProcessingScreen extends StatefulWidget {
//   final Map<String, String> prefilledData;
//   const ProcessingScreen({Key? key, required this.prefilledData}) : super(key: key);

//   @override
//   State<ProcessingScreen> createState() => _ProcessingScreenState();
// }

// class _ProcessingScreenState extends State<ProcessingScreen> {
//   double _progressValue = 0.0;
//   late Timer _timer;

//   @override
//   void initState() {
//     super.initState();
    
//     // Strict 15-second tracking window
//     const duration = Duration(seconds: 15);
//     const tick = Duration(milliseconds: 100);
//     int totalTicks = duration.inMilliseconds ~/ tick.inMilliseconds;
//     int currentTick = 0;

//     _timer = Timer.periodic(tick, (timer) {
//       currentTick++;
//       setState(() {
//         _progressValue = currentTick / totalTicks;
//       });

//       if (currentTick >= totalTicks) {
//         _timer.cancel();
//         context.go('/shop-setup', extra: widget.prefilledData);
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _timer.cancel();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF0F172A),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Stack(
//               alignment: Alignment.center,
//               children: [
//                 SizedBox(
//                   width: 140,
//                   height: 140,
//                   child: CircularProgressIndicator(
//                     value: _progressValue,
//                     strokeWidth: 6,
//                     valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
//                     backgroundColor: Colors.white10,
//                   ),
//                 ),
//                 Text(
//                   '${(_progressValue * 100).toStringAsFixed(0)}%',
//                   style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'Courier'),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 48),
//             const Text(
//               'Synchronizing Workspaces',
//               style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 0.5),
//             ),
//             const SizedBox(height: 8),
//             const Text(
//               'Configuring isolated storage space. Please stay connected.',
//               style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//  }

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProcessingScreen extends StatefulWidget {
  final Map<String, String> prefilledData;
  const ProcessingScreen({Key? key, required this.prefilledData}) : super(key: key);

  @override
  State<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends State<ProcessingScreen> {
  double _progressValue = 0.0;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    
    // ⚡ Smooth & Fast 3-Second Processing Window
    const duration = Duration(seconds: 3);
    const tick = Duration(milliseconds: 50);
    int totalTicks = duration.inMilliseconds ~/ tick.inMilliseconds;
    int currentTick = 0;

    _timer = Timer.periodic(tick, (timer) {
      if (!mounted) return;

      currentTick++;
      setState(() {
        _progressValue = currentTick / totalTicks;
      });

      if (currentTick >= totalTicks) {
        _timer.cancel();

        // 🔀 Read Next Destination Dynamically ('/shop-setup' or '/home')
        final String nextRoute = widget.prefilledData['next'] ?? '/home';

        if (mounted) {
          context.go(nextRoute, extra: widget.prefilledData);
        }
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 140,
                  height: 140,
                  child: CircularProgressIndicator(
                    value: _progressValue,
                    strokeWidth: 6,
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
                    backgroundColor: Colors.white10,
                  ),
                ),
                Text(
                  '${(_progressValue * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(
                    color: Colors.white, 
                    fontSize: 22, 
                    fontWeight: FontWeight.bold, 
                    fontFamily: 'Courier',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 48),
            const Text(
              'Synchronizing Workspaces',
              style: TextStyle(
                color: Colors.white, 
                fontSize: 18, 
                fontWeight: FontWeight.bold, 
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Configuring isolated storage space. Please stay connected.',
              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
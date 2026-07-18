import 'dart:async';
import 'package:flutter/material.dart';

class SessionTimeoutManager extends StatefulWidget {
  final Widget child;
  final VoidCallback onTimeout;
  final Duration timeoutDuration;

  const SessionTimeoutManager({
    super.key,
    required this.child,
    required this.onTimeout,
    this.timeoutDuration = const Duration(minutes: 5), // 5 Mins Auto Lock
  });

  @override
  State<SessionTimeoutManager> createState() => _SessionTimeoutManagerState();
}

class _SessionTimeoutManagerState extends State<SessionTimeoutManager> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _resetTimer();
  }

  void _resetTimer() {
    _timer?.cancel();
    _timer = Timer(widget.timeoutDuration, widget.onTimeout);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _resetTimer(),
      onPointerMove: (_) => _resetTimer(),
      child: widget.child,
    );
  }
}
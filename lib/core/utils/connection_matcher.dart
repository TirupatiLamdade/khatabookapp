import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class ConnectionMatcher extends StatefulWidget {
  final Widget child;
  const ConnectionMatcher({super.key, required this.child});

  @override
  State<ConnectionMatcher> createState() => _ConnectionMatcherState();
}

class _ConnectionMatcherState extends State<ConnectionMatcher> {
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  bool _isOnline = true;

  @override
  void initState() {
    super.initState();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) {
      final hasNetwork = !results.contains(ConnectivityResult.none);
      if (_isOnline != hasNetwork) {
        setState(() => _isOnline = hasNetwork);
        _triggerNotificationBanner();
      }
    });
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  void _triggerNotificationBanner() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isOnline ? "Operational State: Back Online! Processing cloud sync queue." : "Operational State: Offline Mode Engaged. Data saving to encrypted local cache."),
        backgroundColor: _isOnline ? Colors.green : Colors.orange,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
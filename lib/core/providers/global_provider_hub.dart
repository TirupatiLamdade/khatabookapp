
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

// Multi-tenancy State
final activeShopIdProvider = StateProvider<String?>((ref) => null);

// Dynamic Theme Mode State (Light, Dark, System Default)
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);
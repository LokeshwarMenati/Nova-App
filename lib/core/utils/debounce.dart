import 'dart:async';
import 'package:flutter/foundation.dart';

/// Lightweight debouncer to throttle rapid user inputs (e.g. search keystrokes).
class Debouncer {
  final Duration delay;
  Timer? _timer;

  Debouncer({required this.delay});

  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  void dispose() {
    _timer?.cancel();
    _timer = null;
  }
}

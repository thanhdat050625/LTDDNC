import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../widgets/app_exit_dialog.dart';

/// Centralized back button and navigation handler for Cineplex mobile apps.
///
/// Features:
/// 1. Pops root navigator (dialogs, bottom sheets, full screen pushes, modals).
/// 2. Pops shell navigator (nested tabs / shell navigation if any).
/// 3. Backwards navigation history for routes navigated via `context.go`.
/// 4. Intercepts back on root destinations to show exit confirmation dialog.
class AppBackHandler with WidgetsBindingObserver {
  final GoRouter router;
  final GlobalKey<NavigatorState> rootNavKey;
  final GlobalKey<NavigatorState>? shellNavKey;
  final String defaultRootPath;
  final Set<String> exitOnPaths;
  final FutureOr<void> Function()? onExitApp;

  final List<String> _history = [];
  bool _isNavigatingBack = false;
  bool _isExitDialogOpen = false;
  bool _isDisposed = false;

  AppBackHandler({
    required this.router,
    required this.rootNavKey,
    this.shellNavKey,
    required this.defaultRootPath,
    Set<String>? exitOnPaths,
    this.onExitApp,
  }) : exitOnPaths = exitOnPaths ?? {defaultRootPath};

  /// Initializes the observer and router listener.
  void init() {
    WidgetsBinding.instance.addObserver(this);
    router.routerDelegate.addListener(_onRouteChanged);
    _recordCurrentRoute();
  }

  /// Disposes the observer and removes listeners.
  void dispose() {
    _isDisposed = true;
    router.routerDelegate.removeListener(_onRouteChanged);
    WidgetsBinding.instance.removeObserver(this);
  }

  void _recordCurrentRoute() {
    final currentUri = router.routerDelegate.currentConfiguration.uri;
    final current = currentUri.toString();
    final path = currentUri.path;
    if (current.isEmpty) return;

    // When navigating to any exitOnPaths screen, reset history so it is the only base
    if (exitOnPaths.contains(path)) {
      _history.clear();
      _history.add(current);
      return;
    }

    final existingIndex = _history.indexOf(current);
    if (existingIndex >= 0) {
      _history.removeRange(existingIndex + 1, _history.length);
    } else {
      _history.add(current);
    }
  }

  void _onRouteChanged() {
    if (_isNavigatingBack || _isDisposed) return;
    _recordCurrentRoute();
  }

  /// Reset history manually (e.g., on auth state change).
  void resetHistory([String? newRootPath]) {
    final root = newRootPath ?? defaultRootPath;
    _history.clear();
    _history.add(root);
  }

  @override
  Future<bool> didPopRoute() async {
    if (_isDisposed) return false;

    // 1. Pop root navigator (dialogs, bottom sheets, full screen pushes, open drawers)
    if (rootNavKey.currentState?.canPop() == true) {
      _isNavigatingBack = true;
      try {
        await rootNavKey.currentState!.maybePop();
        return true;
      } finally {
        _isNavigatingBack = false;
      }
    }

    // 2. Pop shell navigator (if shell route exists and has popped something)
    if (shellNavKey?.currentState?.canPop() == true) {
      _isNavigatingBack = true;
      try {
        await shellNavKey!.currentState!.maybePop();
        return true;
      } finally {
        _isNavigatingBack = false;
      }
    }

    // 3. Check current route
    final currentUri = router.routerDelegate.currentConfiguration.uri;
    final currentPath = currentUri.path;

    // 4. We are at a root screen in exitOnPaths: show exit confirmation dialog!
    if (exitOnPaths.contains(currentPath)) {
      if (_isExitDialogOpen) {
        return true;
      }

      final context = rootNavKey.currentContext;
      if (context == null || !context.mounted) {
        return true;
      }

      _isExitDialogOpen = true;
      unawaited(() async {
        try {
          final shouldExit = await showAppExitDialog(context);
          if (shouldExit) {
            if (onExitApp != null) {
              await onExitApp!();
            } else {
              await SystemNavigator.pop();
            }
          }
        } finally {
          _isExitDialogOpen = false;
        }
      }());

      return true;
    }

    // 5. Navigate back through history if we have history
    while (_history.length > 1) {
      _history.removeLast();
      final target = _history.last;
      if (target != currentUri.toString()) {
        _isNavigatingBack = true;
        try {
          router.go(target);
        } finally {
          _isNavigatingBack = false;
        }
        return true;
      }
    }

    // 6. If history has no previous screen but we are NOT on an exitOnPaths screen,
    // fallback to defaultRootPath
    _isNavigatingBack = true;
    try {
      router.go(defaultRootPath);
      _history.clear();
      _history.add(defaultRootPath);
    } finally {
      _isNavigatingBack = false;
    }
    return true;
  }
}

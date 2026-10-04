import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/storage_service.dart';

/// Cubit managing dynamic ThemeMode across Cineplex applications (Client, Staff, Admin).
/// Defaults to [ThemeMode.dark] per design.md specifications.
/// Persists user preferences seamlessly via [StorageService].
class ThemeCubit extends Cubit<ThemeMode> {
  final StorageService? _storageService;
  bool _isInitialized = false;

  ThemeCubit([this._storageService]) : super(ThemeMode.dark) {
    _loadSavedTheme();
  }

  Future<void> _loadSavedTheme() async {
    if (_storageService == null) {
      _isInitialized = true;
      return;
    }
    try {
      final savedMode = await _storageService.getThemeMode();
      if (!_isInitialized && savedMode != null) {
        emit(_fromString(savedMode));
      }
    } catch (_) {
      // Gracefully fall back to initial mode if storage read fails
    } finally {
      _isInitialized = true;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _isInitialized = true;
    if (state == mode) return;
    emit(mode);
    if (_storageService != null) {
      await _storageService.saveThemeMode(mode.name);
    }
  }

  Future<void> toggleTheme() async {
    final next = (state == ThemeMode.dark) ? ThemeMode.light : ThemeMode.dark;
    await setThemeMode(next);
  }

  bool get isDarkMode => state == ThemeMode.dark;

  static ThemeMode _fromString(String value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
      default:
        return ThemeMode.dark;
    }
  }
}

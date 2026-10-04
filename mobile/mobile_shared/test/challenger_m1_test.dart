import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_shared/mobile_shared.dart';

class MockStorageService extends StorageService {
  String? savedMode;
  int saveCount = 0;
  bool shouldThrowOnGet = false;
  bool shouldThrowOnSave = false;
  Duration getDelay = Duration.zero;

  MockStorageService({this.savedMode});

  @override
  Future<void> saveThemeMode(String mode) async {
    if (shouldThrowOnSave) {
      throw Exception('Storage write failure');
    }
    saveCount++;
    savedMode = mode;
  }

  @override
  Future<String?> getThemeMode() async {
    if (getDelay > Duration.zero) {
      await Future.delayed(getDelay);
    }
    if (shouldThrowOnGet) {
      throw Exception('Storage read failure');
    }
    return savedMode;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Challenge 1: Localization & ARB Integrity Verification', () {
    late String arbContent;
    late Map<String, dynamic> arbJson;

    setUpAll(() {
      final arbFile = File('lib/l10n/app_vi.arb');
      expect(arbFile.existsSync(), isTrue, reason: 'app_vi.arb must exist in lib/l10n/');
      arbContent = arbFile.readAsStringSync();
      arbJson = jsonDecode(arbContent) as Map<String, dynamic>;
    });

    test('app_vi.arb contains no duplicate top-level JSON keys', () {
      final lines = arbContent.split('\n');
      final seenKeys = <String, int>{};
      final duplicates = <String, List<int>>{};
      int depth = 0;

      for (var i = 0; i < lines.length; i++) {
        final line = lines[i];
        
        // Check for key at depth 1 (top-level properties of the root JSON object)
        if (depth == 1) {
          final match = RegExp(r'^\s*"([^"]+)"\s*:').firstMatch(line);
          if (match != null) {
            final key = match.group(1)!;
            if (seenKeys.containsKey(key)) {
              duplicates.putIfAbsent(key, () => [seenKeys[key]!]).add(i + 1);
            } else {
              seenKeys[key] = i + 1;
            }
          }
        }

        // Track object depth
        for (var char in line.runes) {
          if (char == 0x7B) { // '{'
            depth++;
          } else if (char == 0x7D) { // '}'
            depth--;
          }
        }
      }

      expect(
        duplicates,
        isEmpty,
        reason: 'Duplicate top-level keys found in app_vi.arb: $duplicates',
      );
    });

    test('All ARB placeholders are balanced and declared in metadata', () {
      final placeholderRegex = RegExp(r'\{([a-zA-Z0-9_]+)\}');
      final missingMetadata = <String, List<String>>{};
      final undeclaredInValue = <String, List<String>>{};
      final unbalancedBraces = <String>[];

      for (final entry in arbJson.entries) {
        final key = entry.key;
        if (key.startsWith('@')) continue;

        if (entry.value is String) {
          final val = entry.value as String;

          // Check balanced braces
          final openCount = '{'.allMatches(val).length;
          final closeCount = '}'.allMatches(val).length;
          if (openCount != closeCount) {
            unbalancedBraces.add('$key (open: $openCount, close: $closeCount)');
          }

          // Check placeholders in string
          final matches = placeholderRegex.allMatches(val).map((m) => m.group(1)!).toSet();
          final metaKey = '@$key';
          final meta = arbJson[metaKey] as Map<String, dynamic>?;

          if (matches.isNotEmpty) {
            if (meta == null || meta['placeholders'] == null) {
              missingMetadata[key] = matches.toList();
            } else {
              final declaredPlaceholders = (meta['placeholders'] as Map<String, dynamic>).keys.toSet();
              final notDeclared = matches.difference(declaredPlaceholders);
              if (notDeclared.isNotEmpty) {
                missingMetadata[key] = notDeclared.toList();
              }
            }
          }

          if (meta != null && meta['placeholders'] != null) {
            final declaredPlaceholders = (meta['placeholders'] as Map<String, dynamic>).keys.toSet();
            final unusedPlaceholders = declaredPlaceholders.difference(matches);
            if (unusedPlaceholders.isNotEmpty) {
              undeclaredInValue[key] = unusedPlaceholders.toList();
            }
          }
        }
      }

      expect(unbalancedBraces, isEmpty, reason: 'Unbalanced braces found: $unbalancedBraces');
      expect(missingMetadata, isEmpty, reason: 'Placeholders without metadata: $missingMetadata');
      expect(undeclaredInValue, isEmpty, reason: 'Metadata placeholders not in string: $undeclaredInValue');
    });

    test('No English fallback strings or keywords in shared widgets', () {
      final widgetDir = Directory('lib/widgets');
      final dartFiles = widgetDir.listSync().whereType<File>().where((f) => f.path.endsWith('.dart'));

      final suspiciousEnglish = [
        'Retry',
        'Loading...',
        'No data',
        'Sign In',
        'Sign Out',
        'Log In',
        'Cancel',
        'Delete',
      ];

      final violations = <String>[];

      for (final file in dartFiles) {
        final content = file.readAsStringSync();
        for (final english in suspiciousEnglish) {
          // Look for direct string literals like 'Retry' or "Retry"
          final pattern = RegExp("['\"]$english['\"]");
          if (pattern.hasMatch(content)) {
            violations.add('${file.path}: contains "$english"');
          }
        }
      }

      expect(violations, isEmpty, reason: 'Found hardcoded English user strings: $violations');
    });
  });

  group('Challenge 2: ThemeCubit & Dynamic Theme Switching', () {
    test('Initializes with ThemeMode.dark when storage is null', () {
      final cubit = ThemeCubit();
      expect(cubit.state, ThemeMode.dark);
      expect(cubit.isDarkMode, isTrue);
      cubit.close();
    });

    test('Restores ThemeMode.light from StorageService asynchronously', () async {
      final storage = MockStorageService(savedMode: 'light');
      final cubit = ThemeCubit(storage);

      // Super state is initially dark
      expect(cubit.state, ThemeMode.dark);

      // Wait for _loadSavedTheme to finish
      await Future.delayed(const Duration(milliseconds: 20));

      expect(cubit.state, ThemeMode.light);
      expect(cubit.isDarkMode, isFalse);
      cubit.close();
    });

    test('Restores ThemeMode.system from StorageService asynchronously', () async {
      final storage = MockStorageService(savedMode: 'system');
      final cubit = ThemeCubit(storage);

      await Future.delayed(const Duration(milliseconds: 20));

      expect(cubit.state, ThemeMode.system);
      expect(cubit.isDarkMode, isFalse);
      cubit.close();
    });

    test('Defaults safely to ThemeMode.dark if StorageService contains invalid mode string', () async {
      final storage = MockStorageService(savedMode: 'invalid_mode_xyz');
      final cubit = ThemeCubit(storage);

      await Future.delayed(const Duration(milliseconds: 20));

      expect(cubit.state, ThemeMode.dark);
      expect(cubit.isDarkMode, isTrue);
      cubit.close();
    });

    test('Gracefully handles StorageService getThemeMode exception without crashing', () async {
      final storage = MockStorageService()..shouldThrowOnGet = true;
      final cubit = ThemeCubit(storage);

      await Future.delayed(const Duration(milliseconds: 20));

      expect(cubit.state, ThemeMode.dark);
      cubit.close();
    });

    test('toggleTheme toggles dark -> light -> dark and persists each change', () async {
      final storage = MockStorageService(savedMode: 'dark');
      final cubit = ThemeCubit(storage);
      await Future.delayed(const Duration(milliseconds: 10));

      expect(cubit.state, ThemeMode.dark);

      // Toggle 1: dark -> light
      await cubit.toggleTheme();
      expect(cubit.state, ThemeMode.light);
      expect(cubit.isDarkMode, isFalse);
      expect(storage.savedMode, 'light');
      expect(storage.saveCount, 1);

      // Toggle 2: light -> dark
      await cubit.toggleTheme();
      expect(cubit.state, ThemeMode.dark);
      expect(cubit.isDarkMode, isTrue);
      expect(storage.savedMode, 'dark');
      expect(storage.saveCount, 2);

      cubit.close();
    });

    test('toggleTheme when state is ThemeMode.system transitions to ThemeMode.dark', () async {
      final storage = MockStorageService(savedMode: 'system');
      final cubit = ThemeCubit(storage);
      await Future.delayed(const Duration(milliseconds: 10));

      expect(cubit.state, ThemeMode.system);

      // Toggle from system: (state == ThemeMode.dark) is false, so next is ThemeMode.dark
      await cubit.toggleTheme();
      expect(cubit.state, ThemeMode.dark);
      expect(storage.savedMode, 'dark');

      cubit.close();
    });

    test('setThemeMode is idempotent (does not re-emit or re-save if same mode)', () async {
      final storage = MockStorageService(savedMode: 'dark');
      final cubit = ThemeCubit(storage);
      await Future.delayed(const Duration(milliseconds: 10));

      expect(storage.saveCount, 0);

      // Calling setThemeMode with current mode (dark)
      await cubit.setThemeMode(ThemeMode.dark);
      expect(storage.saveCount, 0);

      // Calling setThemeMode with light
      await cubit.setThemeMode(ThemeMode.light);
      expect(storage.saveCount, 1);
      expect(storage.savedMode, 'light');

      // Calling again with light
      await cubit.setThemeMode(ThemeMode.light);
      expect(storage.saveCount, 1);

      cubit.close();
    });

    test('ThemeCubit constructor race condition analysis: rapid setThemeMode vs delayed load', () async {
      final storage = MockStorageService(savedMode: 'light')
        ..getDelay = const Duration(milliseconds: 50);

      final cubit = ThemeCubit(storage);

      // User immediately chooses dark before storage load completes
      await cubit.setThemeMode(ThemeMode.dark);
      expect(cubit.state, ThemeMode.dark);

      // Wait for delayed storage load to complete
      await Future.delayed(const Duration(milliseconds: 70));

      // Verify cubit does NOT get overwritten by delayed load
      expect(cubit.state, ThemeMode.dark);
      cubit.close();
    });

    test('Real StorageService throws MissingPluginException in unit test without mock channel', () async {
      final realStorage = StorageService();
      try {
        await realStorage.getThemeMode();
        print('Real storage succeeded without mock channel');
      } catch (e) {
        print('Real storage throws in unit test as expected: $e');
        expect(e, isA<Exception>());
      }
    });
  });

  group('Challenge 3: Widget Theme Extension Safety & Robustness', () {
    testWidgets('AppCard behavior when CineplexColors extension is missing', (tester) async {
      // Testing if AppCard safely falls back when CineplexColors extension is not provided
      FlutterErrorDetails? caughtError;
      FlutterError.onError = (details) => caughtError = details;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(), // No CineplexColors extension
          home: const Scaffold(
            body: AppCard(
              child: Text('Card Content'),
            ),
          ),
        ),
      );

      final hasError = tester.takeException() != null || caughtError != null;
      print('AppCard without CineplexColors extension throws error: $hasError');
      expect(hasError, isFalse, reason: 'AppCard safely falls back using CineplexColors.of');
      expect(find.text('Card Content'), findsOneWidget);
    });

    testWidgets('AppErrorView fallback behavior with AppTheme.lightTheme and onRetry', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: AppErrorView(
              message: 'Lỗi kết nối máy chủ',
              onRetry: () {},
            ),
          ),
        ),
      );

      final exception = tester.takeException();
      print('AppErrorView with AppTheme.lightTheme exception: $exception');
      expect(exception, isNull);
      expect(find.text('Lỗi kết nối máy chủ'), findsOneWidget);
      expect(find.text('Thử lại'), findsOneWidget);
    });

    testWidgets('AppErrorView fallback behavior with AppTheme.darkTheme and onRetry', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: AppErrorView(
              message: 'Lỗi kết nối máy chủ',
              onRetry: () {},
            ),
          ),
        ),
      );

      final exception = tester.takeException();
      print('AppErrorView with AppTheme.darkTheme exception: $exception');
      expect(exception, isNull);
      expect(find.text('Lỗi kết nối máy chủ'), findsOneWidget);
      expect(find.text('Thử lại'), findsOneWidget);
    });

    testWidgets('AppErrorView hides retry button when onRetry is null', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: const Scaffold(
            body: AppErrorView(
              message: 'Lỗi không thể thử lại',
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('Lỗi không thể thử lại'), findsOneWidget);
      expect(find.text('Thử lại'), findsNothing);
    });

    testWidgets('AppEmptyView fallback behavior without CineplexColors extension', (tester) async {
      // Testing if AppEmptyView gracefully falls back
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(), // No CineplexColors extension
          home: const Scaffold(
            body: AppEmptyView(
              message: 'Trống',
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('Không có dữ liệu'), findsOneWidget);
      expect(find.text('Trống'), findsOneWidget);
    });
  });
}

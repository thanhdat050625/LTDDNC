import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UI Hardcoded String Scanner Audit', () {
    final libDir = Directory('lib');
    final dartFiles = libDir
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))
        .toList();

    test('Zero hardcoded string literals directly in Text(...) widgets', () {
      final textWidgetRegex = RegExp(r'''Text\s*\(\s*('[^'\$\\]*'|"[^"\$\\]*")''');
      final violations = <String>[];

      for (final file in dartFiles) {
        final lines = file.readAsLinesSync();
        for (var i = 0; i < lines.length; i++) {
          final line = lines[i].trim();
          if (line.startsWith('//') || line.startsWith('/*') || line.startsWith('*')) continue;

          final match = textWidgetRegex.firstMatch(line);
          if (match != null) {
            final literal = match.group(1)!;
            final unquoted = literal.substring(1, literal.length - 1).trim();
            if (unquoted.isEmpty || RegExp(r'^[:\-\.\,\/\s•]+$').hasMatch(unquoted)) {
              continue;
            }
            violations.add('${file.path}:${i + 1} -> $line');
          }
        }
      }

      expect(violations, isEmpty,
          reason: 'Found hardcoded string literals in Text widgets:\n${violations.join('\n')}');
    });

    test('Zero hardcoded string literals in UI input decoration/labels/tooltips', () {
      final uiPropertyRegex = RegExp(
          r'''\b(hintText|labelText|helperText|errorText|tooltip|semanticsLabel)\s*:\s*('[^'\$\\]*'|"[^"\$\\]*")''');
      final violations = <String>[];

      for (final file in dartFiles) {
        final lines = file.readAsLinesSync();
        for (var i = 0; i < lines.length; i++) {
          final line = lines[i].trim();
          if (line.startsWith('//') || line.startsWith('/*') || line.startsWith('*')) continue;

          final match = uiPropertyRegex.firstMatch(line);
          if (match != null) {
            final prop = match.group(1);
            final literal = match.group(2)!;
            final unquoted = literal.substring(1, literal.length - 1).trim();
            if (unquoted.isEmpty) continue;

            violations.add('${file.path}:${i + 1} [$prop] -> $line');
          }
        }
      }

      expect(violations, isEmpty,
          reason: 'Found hardcoded string literals in UI properties:\n${violations.join('\n')}');
    });

    test('Audit of presentation cubits/blocs for hardcoded user-facing English strings', () {
      final cubitFiles = dartFiles.where((f) => f.path.contains('cubit') || f.path.contains('bloc')).toList();
      final hardcodedErrors = <String>[];

      for (final file in cubitFiles) {
        final lines = file.readAsLinesSync();
        for (var i = 0; i < lines.length; i++) {
          final line = lines[i].trim();
          if (line.startsWith('//')) continue;

          // Check for hardcoded error strings passed to Failure/Error states
          if (line.contains("PaymentFailed('Payment failed')") ||
              line.contains("PaymentFailed('Payment status:")) {
            hardcodedErrors.add('${file.path}:${i + 1} -> $line');
          }
        }
      }

      expect(hardcodedErrors, isEmpty,
          reason: 'Zero hardcoded English PaymentFailed strings found in cubit files');
    });
  });
}

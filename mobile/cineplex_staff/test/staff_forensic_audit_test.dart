import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_shared/mobile_shared.dart';

void main() {
  group('Forensic Audit: ARB & Single Language Integrity', () {
    test('Only app_vi.arb exists and has valid JSON with zero duplicate top-level keys', () {
      final l10nDir = Directory('../mobile_shared/lib/l10n');
      final arbFiles = l10nDir
          .listSync(recursive: false)
          .whereType<File>()
          .where((f) => f.path.endsWith('.arb'))
          .toList();

      expect(arbFiles.length, equals(1),
          reason: 'Only app_vi.arb must exist in mobile_shared/lib/l10n');
      expect(arbFiles.first.path.replaceAll('\\', '/'), endsWith('app_vi.arb'));

      final content = arbFiles.first.readAsStringSync();
      final decoded = json.decode(content);
      expect(decoded, isA<Map<String, dynamic>>());

      // Check for top-level duplicate keys using regex on lines with exact 2-space indentation
      final lines = arbFiles.first.readAsLinesSync();
      final topKeyRegex = RegExp(r'^  "([a-zA-Z0-9_@]+)":');
      final seenKeys = <String>{};
      final duplicates = <String>[];

      for (final line in lines) {
        final match = topKeyRegex.firstMatch(line);
        if (match != null) {
          final key = match.group(1)!;
          if (seenKeys.contains(key)) {
            duplicates.add(key);
          } else {
            seenKeys.add(key);
          }
        }
      }

      expect(duplicates, isEmpty,
          reason: 'Found duplicate top-level keys in app_vi.arb: $duplicates');
    });
  });

  group('Forensic Audit: Hardcoded Vietnamese Text Detection', () {
    test('Detect hardcoded user-facing strings in staff lib', () {
      final staffDir = Directory('lib');
      final dartFiles = staffDir
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'))
          .toList();

      final vnRegex = RegExp(
        r'''['"][^'"]*[àáạảãâầấậẩẫăằắặẳẵèéẹẻẽêềếệểễìíịỉĩòóọỏõôồốộổỗơờớợởỡùúụủũưừứựửữỳýỵỷỹđÀÁẠẢÃÂẦẤẬẨẪĂẰẮẶẲẴÈÉẸẺẼÊỀẾỆỂỄÌÍỊỈĨÒÓỌỎÕÔỒỐỘỔỖƠỜỚỢỞỠÙÚỤỦŨƯỪỨỰỬỮỲÝỴỶỸĐ][^'"]*['"]''',
      );

      final violations = <String>[];
      for (final f in dartFiles) {
        final lines = f.readAsLinesSync();
        for (var i = 0; i < lines.length; i++) {
          final line = lines[i].trim();
          if (line.startsWith('//') || line.startsWith('/*')) continue;
          if (vnRegex.hasMatch(line)) {
            violations.add('${f.path}:${i + 1} -> $line');
          }
        }
      }

      // Verify zero hardcoded Vietnamese strings in staff lib
      expect(
        violations,
        isEmpty,
        reason: 'Detected ${violations.length} hardcoded Vietnamese occurrences in staff lib:\n${violations.join('\n')}',
      );
    });
  });

  group('Forensic Audit: WCAG AA Color Contrast in Staff Screens', () {
    double calculateLuminance(Color color) {
      return color.computeLuminance();
    }

    double contrastRatio(Color fg, Color bg) {
      final l1 = calculateLuminance(fg);
      final l2 = calculateLuminance(bg);
      final lighter = l1 > l2 ? l1 : l2;
      final darker = l1 > l2 ? l2 : l1;
      return (lighter + 0.05) / (darker + 0.05);
    }

    test('Light theme tokens satisfy WCAG AA contrast', () {
      const colors = CineplexColors.light;
      final crTextSurface = contrastRatio(colors.textPrimary, colors.surface);
      final crTextBg = contrastRatio(colors.textPrimary, colors.background);
      expect(crTextSurface, greaterThanOrEqualTo(4.5));
      expect(crTextBg, greaterThanOrEqualTo(4.5));

      final crButton = contrastRatio(Colors.white, colors.primary);
      expect(crButton, greaterThanOrEqualTo(3.0));

      final crBooked = contrastRatio(colors.seatBookedText, colors.seatBooked);
      expect(crBooked, greaterThanOrEqualTo(3.0));
    });

    test('Dark theme tokens satisfy WCAG AA contrast', () {
      const colors = CineplexColors.dark;
      final crTextSurface = contrastRatio(colors.textPrimary, colors.surface);
      final crTextBg = contrastRatio(colors.textPrimary, colors.background);
      expect(crTextSurface, greaterThanOrEqualTo(4.5));
      expect(crTextBg, greaterThanOrEqualTo(4.5));

      final crButton = contrastRatio(Colors.white, colors.primary);
      expect(crButton, greaterThanOrEqualTo(3.0));

      final crBooked = contrastRatio(colors.seatBookedText, colors.seatBooked);
      expect(crBooked, greaterThanOrEqualTo(3.0));
    });
  });
}

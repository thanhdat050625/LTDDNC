import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_shared/mobile_shared.dart';
import 'package:cineplex_staff/features/scanner/presentation/widgets/scan_result_overlay.dart';

void main() {
  group('ScanResultOverlay Widget Tests', () {
    testWidgets('Renders success state with correct colors and message', (
      tester,
    ) async {
      bool dismissed = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: ScanResultOverlay(
              isSuccess: true,
              message: 'Vé hợp lệ: Ghế A1 • Mã: TKT-12345',
              onDismiss: () => dismissed = true,
            ),
          ),
        ),
      );

      expect(find.text('Vé hợp lệ: Ghế A1 • Mã: TKT-12345'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close));
      expect(dismissed, isTrue);
    });

    testWidgets('Renders warning state in Dark Theme', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: const Scaffold(
            body: ScanResultOverlay(
              isSuccess: false,
              isWarning: true,
              message: 'Vé này đã được soát trước đó!',
            ),
          ),
        ),
      );

      expect(find.text('Vé này đã được soát trước đó!'), findsOneWidget);
      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
    });

    testWidgets(
      'Renders error state without ParentDataWidget crash when inside Stack and Positioned',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.darkTheme,
            home: const Scaffold(
              body: Stack(
                fit: StackFit.expand,
                children: [
                  Positioned(
                    bottom: 110,
                    left: 16,
                    right: 16,
                    child: ScanResultOverlay(
                      isSuccess: false,
                      isWarning: false,
                      message: 'Không tìm thấy vé trong hệ thống!',
                    ),
                  ),
                ],
              ),
            ),
          ),
        );

        expect(find.text('Không tìm thấy vé trong hệ thống!'), findsOneWidget);
        expect(find.byIcon(Icons.cancel_rounded), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  });

  group('Scanner Screen Layout Sizing Tests', () {
    testWidgets(
      'Expanded Column in Stack(fit: StackFit.expand) fills screen without collapsing to 0x0',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.darkTheme,
            home: Scaffold(
              body: Stack(
                fit: StackFit.expand,
                children: [
                  Column(
                    children: [
                      Expanded(
                        child: Container(
                          key: const Key('camera_area'),
                          color: Colors.black,
                        ),
                      ),
                      Container(
                        key: const Key('manual_input_area'),
                        height: 100,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                  const Positioned(
                    bottom: 110,
                    left: 16,
                    right: 16,
                    child: SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),
        );

        final cameraArea = tester.getSize(find.byKey(const Key('camera_area')));
        final manualArea = tester.getSize(
          find.byKey(const Key('manual_input_area')),
        );

        // In a 540x1200 logical screen, camera area must be > 0 and take remaining height
        expect(cameraArea.width, equals(540));
        expect(cameraArea.height, equals(1100)); // 1200 - 100
        expect(manualArea.width, equals(540));
        expect(manualArea.height, equals(100));
      },
    );
  });
}

import 'package:flutter/material.dart';
import 'package:cineplex_mobile/core/widgets/app_scaffold.dart';
// Note: Requires webview_flutter in pubspec.yaml

class PaymentWebviewScreen extends StatelessWidget {
  final String url;
  final String bookingId;

  const PaymentWebviewScreen({Key? key, required this.url, required this.bookingId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Payment',
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('WebView Placeholder'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Simulate success callback
                Navigator.pushReplacementNamed(context, '/payment/result', arguments: bookingId);
              },
              child: const Text('Simulate Success Return'),
            )
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_shared/mobile_shared.dart';

class PaymentWebviewScreen extends StatelessWidget {
  final String url;
  final String bookingId;

  const PaymentWebviewScreen({super.key, required this.url, required this.bookingId});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = CineplexColors.of(context);

    return AppScaffold(
      title: l10n.checkout,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.language, size: 40, color: colors.primary),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.webviewPlaceholder,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              if (url.isNotEmpty)
                Text(
                  url,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, color: colors.textSecondary),
                ),
              const SizedBox(height: 28),
              AppButton(
                text: l10n.simulateSuccess,
                onPressed: () {
                  context.go('/payment-result/$bookingId');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}


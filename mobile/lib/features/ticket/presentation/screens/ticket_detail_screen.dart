import 'package:flutter/material.dart';
import 'package:cineplex_mobile/core/widgets/app_scaffold.dart';
import 'package:cineplex_mobile/features/ticket/data/models/ticket_model.dart';
import 'package:cineplex_mobile/core/utils/format_utils.dart';
// Note: Requires qr_flutter package in real app for QR rendering

class TicketDetailScreen extends StatelessWidget {
  final BookingDetailModel booking;
  const TicketDetailScreen({Key? key, required this.booking}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Ticket Detail',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('Booking Code: ${booking.bookingCode}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            if (booking.tickets.isNotEmpty) ...[
              const Text('QR Code Placeholder (Use qr_flutter)', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 16),
              const Icon(Icons.qr_code_2, size: 150), // Mock QR
              Text('Ticket ID: ${booking.tickets.first.qrCode}'),
            ],
            const SizedBox(height: 24),
            Text('Status: ${booking.status}'),
            Text('Total: ${FormatUtils.formatCurrency(((booking.totalAmount).toInt()).toInt())}'),
          ],
        ),
      ),
    );
  }
}

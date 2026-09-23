import 'package:flutter/material.dart';
import 'package:cineplex_mobile/features/ticket/data/models/ticket_model.dart';
import 'package:cineplex_mobile/core/utils/format_utils.dart';

class TicketCard extends StatelessWidget {
  final BookingDetailModel booking;

  const TicketCard({Key? key, required this.booking}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        title: Text('Booking: ${booking.bookingCode}'),
        subtitle: Text('Status: ${booking.status}\nTotal: ${FormatUtils.formatCurrency(((booking.totalAmount).toInt()).toInt())}'),
        trailing: const Icon(Icons.chevron_right),
        isThreeLine: true,
        onTap: () {
          Navigator.pushNamed(context, '/ticket/detail', arguments: booking);
        },
      ),
    );
  }
}

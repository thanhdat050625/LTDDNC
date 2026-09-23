import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cineplex_mobile/core/widgets/app_scaffold.dart';
import '../cubit/staff_cubit.dart';
import '../widgets/scan_result_overlay.dart';
// Note: Requires mobile_scanner package

class StaffScannerScreen extends StatelessWidget {
  const StaffScannerScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Scan Ticket',
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Scanner Placeholder (mobile_scanner)'),
                ElevatedButton(
                  onPressed: () {
                    context.read<StaffCubit>().checkin('TKT-12345');
                  },
                  child: const Text('Simulate Scan'),
                )
              ],
            ),
          ),
          BlocBuilder<StaffCubit, StaffState>(
            builder: (context, state) {
              if (state is StaffCheckinSuccess) {
                return ScanResultOverlay(isSuccess: true, message: 'Ticket Checked In: ${state.ticket.qrCode}');
              }
              if (state is StaffCheckinError) {
                return ScanResultOverlay(isSuccess: false, message: state.message);
              }
              if (state is StaffScanning) {
                return const Center(child: CircularProgressIndicator());
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }
}

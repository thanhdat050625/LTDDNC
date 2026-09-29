import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cineplex_client/core/theme/app_colors.dart';
import 'package:cineplex_client/core/widgets/app_button.dart';
import 'package:cineplex_client/core/widgets/app_scaffold.dart';
import 'package:cineplex_client/core/widgets/app_loading.dart';
import '../cubit/payment_cubit.dart';

class PaymentResultScreen extends StatefulWidget {
  final String bookingId;
  const PaymentResultScreen({Key? key, required this.bookingId}) : super(key: key);

  @override
  State<PaymentResultScreen> createState() => _PaymentResultScreenState();
}

class _PaymentResultScreenState extends State<PaymentResultScreen> {
  @override
  void initState() {
    super.initState();
    context.read<PaymentCubit>().checkStatus(widget.bookingId);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Payment Result',
      body: BlocBuilder<PaymentCubit, PaymentState>(
        builder: (context, state) {
          if (state is PaymentPolling || state is PaymentLoading) return const AppLoading();
          if (state is PaymentSuccess) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 80),
                  const SizedBox(height: 16),
                  const Text('Payment Successful!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('Booking Code: ${state.status.bookingCode}'),
                  const SizedBox(height: 24),
                  AppButton(
                    text: 'View Tickets',
                    onPressed: () => Navigator.pushReplacementNamed(context, '/tickets'),
                  ),
                ],
              ),
            );
          }
          if (state is PaymentFailed) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, color: AppColors.error, size: 80),
                  const SizedBox(height: 16),
                  const Text('Payment Failed', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(state.message),
                  const SizedBox(height: 24),
                  AppButton(
                    text: 'Retry',
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cineplex_client/core/theme/app_colors.dart';
import 'package:cineplex_client/core/utils/format_utils.dart';
import 'package:cineplex_client/core/widgets/app_button.dart';
import 'package:cineplex_client/core/widgets/app_scaffold.dart';
import 'package:cineplex_client/core/widgets/app_loading.dart';
import '../cubit/payment_cubit.dart';

class CheckoutScreen extends StatefulWidget {
  final String bookingId;
  const CheckoutScreen({Key? key, required this.bookingId}) : super(key: key);

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _selectedMethod = 'MOMO';

  @override
  void initState() {
    super.initState();
    context.read<PaymentCubit>().prepareCheckout(widget.bookingId);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Checkout', // Use L10n in real app
      body: BlocConsumer<PaymentCubit, PaymentState>(
        listener: (context, state) {
          if (state is PaymentUrlReady) {
            Navigator.pushNamed(context, '/payment/webview', arguments: {
              'url': state.payUrl,
              'bookingId': widget.bookingId,
            });
          }
        },
        builder: (context, state) {
          if (state is PaymentLoading) return const AppLoading();
          if (state is CheckoutPrepared) {
            final data = state.data;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Booking Code: ${data.bookingCode}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Text('Total: ${FormatUtils.formatCurrency(((data.totalAmount).toInt()).toInt())}'),
                  if (data.discountAmount > 0) Text('Discount: -${FormatUtils.formatCurrency(((data.discountAmount).toInt()).toInt())}', style: const TextStyle(color: Colors.green)),
                  const SizedBox(height: 24),
                  const Text('Payment Method', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  RadioListTile<String>(
                    title: const Text('MoMo'),
                    value: 'MOMO',
                    groupValue: _selectedMethod,
                    onChanged: (val) => setState(() => _selectedMethod = val!),
                  ),
                  RadioListTile<String>(
                    title: const Text('VNPay'),
                    value: 'VNPAY',
                    groupValue: _selectedMethod,
                    onChanged: (val) => setState(() => _selectedMethod = val!),
                  ),
                  const SizedBox(height: 24),
                  AppButton(
                    text: 'Pay Now',
                    onPressed: () {
                      context.read<PaymentCubit>().checkout(widget.bookingId, _selectedMethod);
                    },
                  ),
                ],
              ),
            );
          }
          if (state is PaymentFailed) {
            return Center(child: Text(state.message, style: TextStyle(color: AppColors.error)));
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

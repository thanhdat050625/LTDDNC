import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cineplex_mobile/l10n/app_localizations.dart';
import 'package:cineplex_mobile/core/theme/app_colors.dart';
import 'package:cineplex_mobile/core/widgets/app_button.dart';
import 'package:cineplex_mobile/core/widgets/app_loading.dart';
import 'package:cineplex_mobile/features/concession/presentation/cubit/concession_cubit.dart';
import 'package:cineplex_mobile/features/concession/presentation/widgets/concession_item_card.dart';

class ConcessionScreen extends StatefulWidget {
  final int bookingId;

  const ConcessionScreen({super.key, required this.bookingId});

  @override
  State<ConcessionScreen> createState() => _ConcessionScreenState();
}

class _ConcessionScreenState extends State<ConcessionScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ConcessionCubit>().loadConcessions();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.concessions),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, '/payment', arguments: widget.bookingId);
            },
            child: Text(l10n.skipConcession, style: const TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
      body: BlocBuilder<ConcessionCubit, ConcessionState>(
        builder: (context, state) {
          if (state is ConcessionLoading) {
            return const Center(child: AppLoading());
          }

          if (state is ConcessionLoaded) {
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.products.length,
                    itemBuilder: (context, index) {
                      final product = state.products[index];
                      final quantity = state.selectedItems[product.id] ?? 0;
                      
                      return ConcessionItemCard(
                        product: product,
                        quantity: quantity,
                        onQuantityChanged: (newQuantity) {
                          context.read<ConcessionCubit>().updateQuantity(product.id, newQuantity);
                        },
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(l10n.totalPrice('${state.totalPrice} \u20ab'), 
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        AppButton(
                          text: l10n.checkout,
                          onPressed: () {
                            // Normally call API to update booking concessions then go to payment
                            Navigator.pushNamed(context, '/payment', arguments: widget.bookingId);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }
          
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

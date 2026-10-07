import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_shared/mobile_shared.dart';
import 'package:cineplex_client/features/concession/presentation/cubit/concession_cubit.dart';
import 'package:cineplex_client/features/concession/presentation/widgets/concession_item_card.dart';

class ConcessionScreen extends StatefulWidget {
  final int bookingId;

  const ConcessionScreen({super.key, required this.bookingId});

  @override
  State<ConcessionScreen> createState() => _ConcessionScreenState();
}

class _ConcessionScreenState extends State<ConcessionScreen> {
  int _selectedCategoryIndex = 0;

  @override
  void initState() {
    super.initState();
    context.read<ConcessionCubit>().loadConcessions();
  }

  List<ConcessionProductModel> _filterProducts(List<ConcessionProductModel> products) {
    if (_selectedCategoryIndex == 1) {
      // Combos
      return products.where((p) => p.name.toLowerCase().contains('combo')).toList();
    } else if (_selectedCategoryIndex == 2) {
      // Popcorn
      return products.where((p) =>
        p.name.toLowerCase().contains('bắp') ||
        p.name.toLowerCase().contains('popcorn') ||
        (p.description?.toLowerCase().contains('bắp') ?? false)
      ).toList();
    } else if (_selectedCategoryIndex == 3) {
      // Drinks
      return products.where((p) =>
        p.name.toLowerCase().contains('nước') ||
        p.name.toLowerCase().contains('coke') ||
        p.name.toLowerCase().contains('pepsi') ||
        p.name.toLowerCase().contains('drink') ||
        (p.description?.toLowerCase().contains('nước') ?? false)
      ).toList();
    }
    return products;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = CineplexColors.of(context);

    final categories = [
      l10n.posCategoryAll,
      l10n.posCategoryCombo,
      l10n.posCategoryPopcorn,
      l10n.posCategoryDrink,
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.concessions),
        actions: [
          TextButton(
            onPressed: () {
              context.read<ConcessionCubit>().submitConcessions(widget.bookingId);
            },
            child: Text(
              l10n.skipConcession,
              style: TextStyle(
                color: colors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: BlocConsumer<ConcessionCubit, ConcessionState>(
        listener: (context, state) {
          if (state is ConcessionSubmitSuccess) {
            context.push('/checkout/${state.bookingId}');
          } else if (state is ConcessionError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is ConcessionLoading) {
            return const Center(child: AppLoading());
          }

          if (state is ConcessionError) {
            return AppErrorView(
              message: state.message,
              onRetry: () => context.read<ConcessionCubit>().loadConcessions(),
            );
          }

          if (state is ConcessionLoaded) {
            final filteredProducts = _filterProducts(state.products);

            return Column(
              children: [
                // Category Filter Tabs
                Container(
                  height: 48,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemBuilder: (context, index) {
                      final isSelected = _selectedCategoryIndex == index;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(categories[index]),
                          selected: isSelected,
                          onSelected: (_) => setState(() => _selectedCategoryIndex = index),
                          selectedColor: colors.primary,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : colors.textSecondary,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      );
                    },
                  ),
                ),

                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () => context.read<ConcessionCubit>().loadConcessions(),
                    child: filteredProducts.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              SizedBox(height: MediaQuery.of(context).size.height * 0.15),
                              AppEmptyView(
                                icon: Icons.fastfood_outlined,
                                title: l10n.noData,
                              ),
                            ],
                          )
                        : ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                            itemCount: filteredProducts.length,
                            itemBuilder: (context, index) {
                              final product = filteredProducts[index];
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
                ),

                // Floating Cart Summary Bar
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 10,
                        offset: const Offset(0, -4),
                      ),
                    ],
                    border: Border(
                      top: BorderSide(color: colors.textSecondary.withValues(alpha: 0.1)),
                    ),
                  ),
                  child: SafeArea(
                    top: false,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              l10n.subtotal,
                              style: TextStyle(
                                fontSize: 12,
                                color: colors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              FormatUtils.formatCurrency(state.totalPrice),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: colors.primary,
                              ),
                            ),
                          ],
                        ),
                        AppButton(
                          text: l10n.checkout,
                          width: 150,
                          isLoading: state.isSubmitting,
                          onPressed: state.isSubmitting
                              ? null
                              : () {
                                  context.read<ConcessionCubit>().submitConcessions(widget.bookingId);
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


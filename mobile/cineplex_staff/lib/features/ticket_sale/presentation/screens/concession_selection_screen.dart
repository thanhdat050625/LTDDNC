import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mobile_shared/mobile_shared.dart';

import '../../data/models/checkout_args.dart';

class ConcessionSelectionScreen extends StatefulWidget {
  final CheckoutArgs? args;

  const ConcessionSelectionScreen({super.key, this.args});

  @override
  State<ConcessionSelectionScreen> createState() => _ConcessionSelectionScreenState();
}

class _ConcessionSelectionScreenState extends State<ConcessionSelectionScreen> {
  final Map<int, int> _quantities = {};
  List<ConcessionProductModel> _products = [];
  bool _isLoading = true;
  int _selectedCategoryIndex = 0;

  static const List<Map<String, dynamic>> _fallbackCatalog = [
    {'id': 1, 'name': 'Popcorn', 'price': 55000, 'type': 'POPCORN'},
    {'id': 2, 'name': 'Drink', 'price': 45000, 'type': 'DRINK'},
    {'id': 3, 'name': 'Combo', 'price': 115000, 'type': 'COMBO'},
  ];

  @override
  void initState() {
    super.initState();
    for (final c in widget.args?.concessions ?? <SelectedConcession>[]) {
      _quantities[c.productId] = c.quantity;
    }
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      final dio = context.read<DioClient>();
      final repo = ConcessionManagementRepository(dio);
      final products = await repo.getAllConcessions();
      if (mounted) {
        setState(() {
          _products = products.isNotEmpty
              ? products
              : _fallbackCatalog
                  .map((e) => ConcessionProductModel(
                        id: e['id'] as int,
                        name: e['name'] as String,
                        price: (e['price'] as int).toDouble(),
                        stockQuantity: 999,
                      ))
                  .toList();
          for (final p in _products) {
            _quantities.putIfAbsent(p.id, () => 0);
          }
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _products = _fallbackCatalog
              .map((e) => ConcessionProductModel(
                    id: e['id'] as int,
                    name: e['name'] as String,
                    price: (e['price'] as int).toDouble(),
                    stockQuantity: 999,
                  ))
              .toList();
          for (final p in _products) {
            _quantities.putIfAbsent(p.id, () => 0);
          }
          _isLoading = false;
        });
      }
    }
  }

  int get _ticketTotal => widget.args?.ticketTotal ?? 0;

  int get _concessionTotal {
    int sum = 0;
    _quantities.forEach((id, qty) {
      if (qty > 0) {
        final prod = _products.where((p) => p.id == id).firstOrNull;
        if (prod != null) {
          sum += prod.price.toInt() * qty;
        }
      }
    });
    return sum;
  }

  int get _grandTotal => _ticketTotal + _concessionTotal;

  String _resolveProductName(ConcessionProductModel p, AppLocalizations l10n) {
    if (p.id == 1 && p.name == 'Popcorn') return l10n.posCategoryPopcorn;
    if (p.id == 2 && p.name == 'Drink') return l10n.defaultDrink;
    if (p.id == 3 && p.name == 'Combo') return l10n.defaultCombo;
    return p.name.isNotEmpty ? p.name : '${l10n.concessions} ${p.id}';
  }

  IconData _resolveProductIcon(ConcessionProductModel product, AppLocalizations l10n) {
    final name = product.name.toLowerCase();
    if (name.contains('combo') || name.contains(l10n.posCategoryCombo.toLowerCase())) {
      return LucideIcons.utensils;
    }
    if (name.contains('drink') ||
        name.contains('coke') ||
        name.contains('pepsi') ||
        name.contains(l10n.posCategoryDrink.toLowerCase())) {
      return LucideIcons.cupSoda;
    }
    return LucideIcons.popcorn;
  }

  List<ConcessionProductModel> _getFilteredProducts(AppLocalizations l10n) {
    if (_selectedCategoryIndex == 1) {
      // Combo
      final kw = l10n.posCategoryCombo.toLowerCase();
      return _products
          .where((p) => p.name.toLowerCase().contains(kw) || p.name.toLowerCase().contains('combo'))
          .toList();
    } else if (_selectedCategoryIndex == 2) {
      // Popcorn
      final kw = l10n.posCategoryPopcorn.toLowerCase();
      return _products
          .where((p) =>
              p.name.toLowerCase().contains(kw) ||
              p.name.toLowerCase().contains('popcorn') ||
              (p.description?.toLowerCase().contains(kw) ?? false))
          .toList();
    } else if (_selectedCategoryIndex == 3) {
      // Drink
      final kw = l10n.posCategoryDrink.toLowerCase();
      return _products
          .where((p) =>
              p.name.toLowerCase().contains(kw) ||
              p.name.toLowerCase().contains('drink') ||
              p.name.toLowerCase().contains('coke') ||
              p.name.toLowerCase().contains('pepsi') ||
              (p.description?.toLowerCase().contains(kw) ?? false))
          .toList();
    }
    return _products;
  }

  @override
  Widget build(BuildContext context) {
    final theme = CineplexColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final categories = [
      l10n.posCategoryAll,
      l10n.posCategoryCombo,
      l10n.posCategoryPopcorn,
      l10n.posCategoryDrink,
    ];

    final filteredProducts = _getFilteredProducts(l10n);

    return AppScaffold(
      title: l10n.concessions,
      actions: [
        TextButton(
          onPressed: () => _proceedToCheckout(context, l10n),
          child: Text(
            l10n.skipConcession,
            style: TextStyle(
              color: theme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
      body: _isLoading
          ? const Center(child: AppLoading())
          : Column(
              children: [
                // Category Filter Tabs
                Container(
                  height: 44,
                  margin: EdgeInsets.symmetric(vertical: theme.spacingSm),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: theme.spacingMd),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final isSelected = _selectedCategoryIndex == index;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(categories[index]),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() => _selectedCategoryIndex = index);
                            }
                          },
                          selectedColor: theme.primary,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : theme.textPrimary,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            fontSize: 13,
                          ),
                          backgroundColor: theme.surface,
                          side: BorderSide(
                            color: isSelected ? theme.primary : theme.borderSubtle,
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Concession List
                Expanded(
                  child: filteredProducts.isEmpty
                      ? Center(
                          child: Text(
                            l10n.noData,
                            style: TextStyle(color: theme.textSecondary),
                          ),
                        )
                      : ListView.separated(
                          padding: EdgeInsets.symmetric(
                            horizontal: theme.spacingMd,
                            vertical: theme.spacingSm,
                          ),
                          itemCount: filteredProducts.length,
                          separatorBuilder: (_, __) => SizedBox(height: theme.spacingSm),
                          itemBuilder: (context, index) {
                            final product = filteredProducts[index];
                            final qty = _quantities[product.id] ?? 0;
                            return _buildProductCard(theme, l10n, product, qty);
                          },
                        ),
                ),

                // Sticky Bottom Bar: Subtotal breakdown & Continue button
                _buildBottomBar(theme, l10n, isDark),
              ],
            ),
    );
  }

  Widget _buildProductCard(
    CineplexColors theme,
    AppLocalizations l10n,
    ConcessionProductModel product,
    int quantity,
  ) {
    final displayName = _resolveProductName(product, l10n);
    final iconData = _resolveProductIcon(product, l10n);

    return AppCard(
      backgroundColor: theme.surface,
      child: Row(
        children: [
          // Concession Icon / Image
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: theme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(theme.radiusSm),
            ),
            child: Icon(
              iconData,
              color: theme.primary,
              size: 26,
            ),
          ),
          SizedBox(width: theme.spacingMd),

          // Title & Price
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: TextStyle(
                    color: theme.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  FormatUtils.formatCurrency(product.price.toInt()),
                  style: TextStyle(
                    color: theme.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          // Quantity controls
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(
                  LucideIcons.minusCircle,
                  color: quantity > 0 ? theme.primary : theme.textSecondary.withValues(alpha: 0.4),
                  size: 24,
                ),
                onPressed: quantity > 0
                    ? () => setState(() => _quantities[product.id] = quantity - 1)
                    : null,
                visualDensity: VisualDensity.compact,
              ),
              Container(
                constraints: const BoxConstraints(minWidth: 26),
                alignment: Alignment.center,
                child: Text(
                  '$quantity',
                  style: TextStyle(
                    color: theme.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  LucideIcons.plusCircle,
                  color: theme.primary,
                  size: 24,
                ),
                onPressed: () => setState(() => _quantities[product.id] = quantity + 1),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(CineplexColors theme, AppLocalizations l10n, bool isDark) {
    return Container(
      padding: EdgeInsets.all(theme.spacingMd),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
            blurRadius: 14,
            offset: const Offset(0, -4),
          ),
        ],
        border: Border(
          top: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.06),
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_concessionTotal > 0) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.concessions,
                    style: TextStyle(color: theme.textSecondary, fontSize: 13),
                  ),
                  Text(
                    FormatUtils.formatCurrency(_concessionTotal),
                    style: TextStyle(
                      color: theme.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.totalAmount,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: theme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        FormatUtils.formatCurrency(_grandTotal),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: theme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                AppButton(
                  text: l10n.continueBtn,
                  width: 135,
                  onPressed: () => _proceedToCheckout(context, l10n),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _proceedToCheckout(BuildContext context, AppLocalizations l10n) {
    final selected = <SelectedConcession>[];
    _quantities.forEach((id, qty) {
      if (qty > 0) {
        final prod = _products.where((p) => p.id == id).firstOrNull;
        if (prod != null) {
          selected.add(SelectedConcession(
            name: _resolveProductName(prod, l10n),
            productId: prod.id,
            price: prod.price.toInt(),
            quantity: qty,
          ));
        }
      }
    });

    final args = widget.args;
    final checkoutArgs = CheckoutArgs(
      showtime: args?.showtime ??
          ShowtimeModel(
            id: 0,
            movieId: 0,
            roomId: 0,
            format: '2D',
            publicStartTime: DateTime.now(),
            status: 'ACTIVE',
          ),
      selectedSeats: args?.selectedSeats ?? const [],
      concessions: selected,
      customer: args?.customer,
      pointsToUse: args?.pointsToUse ?? 0,
    );

    context.push('/ticket-sale/checkout', extra: checkoutArgs);
  }
}

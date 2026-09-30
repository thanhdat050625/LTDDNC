import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mobile_shared/mobile_shared.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _selectedMethod = 'CASH';

  late final List<Map<String, dynamic>> _methods;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context).extension<CineplexColors>()!;
    _methods = [
      {
        'id': 'CASH',
        'label': l10n.cash,
        'desc': l10n.cash,
        'icon': LucideIcons.banknote,
        'color': theme.success,
      },
      {
        'id': 'MOMO',
        'label': l10n.momo,
        'desc': l10n.momo,
        'icon': LucideIcons.wallet,
        'color': theme.accent, // Use accent or primary instead of hardcoded MoMo color
      },
      {
        'id': 'VNPAY',
        'label': l10n.vnpay,
        'desc': l10n.vnpay,
        'icon': LucideIcons.creditCard,
        'color': theme.primary,
      },
    ];
  }
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<CineplexColors>()!;
    final l10n = AppLocalizations.of(context)!;

    return AppScaffold(
      title: l10n.checkout,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left: Payment Methods
          Expanded(
            flex: 3,
            child: SingleChildScrollView(
              padding: EdgeInsets.all(theme.spacingLg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.paymentMethod, style: AppTextStyles.title.copyWith(color: theme.textPrimary)),
                  SizedBox(height: theme.spacingMd),
                  ..._methods.map((m) => _buildMethodCard(theme, m)).toList(),
                  SizedBox(height: theme.spacingLg),
                  
                  // Loyalty Points Option
                  _buildLoyaltyCard(theme, l10n),
                ],
              ),
            ),
          ),
          
          // Right: Summary & Pay
          Expanded(
            flex: 2,
            child: Container(
              color: theme.surface,
              padding: EdgeInsets.all(theme.spacingLg),
              child: Column(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.orderSummary, style: AppTextStyles.title.copyWith(color: theme.textPrimary)),
                        SizedBox(height: theme.spacingLg),
                        
                        // Movie info
                        Row(
                          children: [
                            Container(
                              width: 60,
                              height: 80,
                              decoration: BoxDecoration(
                                color: theme.textSecondary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(theme.radiusSm),
                              ),
                              child: Icon(LucideIcons.film, color: theme.textSecondary),
                            ),
                            SizedBox(width: theme.spacingMd),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Mai", style: TextStyle(color: theme.textPrimary, fontWeight: FontWeight.bold, fontSize: 18)),
                                  Text("${l10n.roomPrefix('1')} • 15:15 ${l10n.today}", style: TextStyle(color: theme.textSecondary)),
                                  SizedBox(height: 4),
                                  Wrap(
                                    spacing: 4,
                                    children: [
                                      _buildSeatChip(theme, "G5"),
                                      _buildSeatChip(theme, "G6"),
                                    ],
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                        
                        SizedBox(height: theme.spacingLg),
                        Divider(color: theme.textSecondary.withValues(alpha: 0.2)),
                        SizedBox(height: theme.spacingLg),
                        
                        // Breakdown
                        _buildBreakdownRow(theme, l10n.movieTicket(2), 150000),
                        _buildBreakdownRow(theme, l10n.concessions, 115000),
                        _buildBreakdownRow(theme, l10n.discountPointsTitle, -20000, isDiscount: true),
                        
                        SizedBox(height: theme.spacingLg),
                        Divider(color: theme.textSecondary.withValues(alpha: 0.2)),
                        SizedBox(height: theme.spacingMd),
                        
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(l10n.totalAmount.toUpperCase(), style: TextStyle(color: theme.textPrimary, fontWeight: FontWeight.bold)),
                            Text(FormatUtils.formatCurrency(245000), style: TextStyle(color: theme.accent, fontSize: 24, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(
                    width: double.infinity,
                    child: AppButton(
                      text: l10n.payNow,
                      onPressed: () {
                        // Show success dialog
                        showDialog(
                          context: context,
                          builder: (c) => AlertDialog(
                            backgroundColor: theme.surface,
                            title: Text(l10n.paymentSuccess, style: TextStyle(color: theme.success)),
                            content: Text(l10n.paymentSuccessPrompt('BK-12345'), style: TextStyle(color: theme.textPrimary)),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(c);
                                  // Go back to POS home
                                  Navigator.of(context).popUntil((route) => route.isFirst);
                                },
                                child: Text(l10n.ok, style: TextStyle(color: theme.primary)),
                              )
                            ],
                          )
                        );
                      },
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMethodCard(CineplexColors theme, Map<String, dynamic> method) {
    final isSelected = _selectedMethod == method['id'];
    return AppCard(
      onTap: () => setState(() => _selectedMethod = method['id']),
      backgroundColor: isSelected ? method['color'].withValues(alpha: 0.1) : theme.surface,
      margin: EdgeInsets.only(bottom: theme.spacingMd),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: method['color'].withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(method['icon'], color: method['color'], size: 28),
          ),
          SizedBox(width: theme.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(method['label'], style: TextStyle(color: theme.textPrimary, fontWeight: FontWeight.bold, fontSize: 16)),
                Text(method['desc'], style: TextStyle(color: theme.textSecondary, fontSize: 13)),
              ],
            ),
          ),
          if (isSelected)
            Icon(LucideIcons.checkCircle2, color: method['color']),
        ],
      ),
    );
  }

  Widget _buildLoyaltyCard(CineplexColors theme, AppLocalizations l10n) {
    return AppCard(
      backgroundColor: theme.accent.withValues(alpha: 0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.star, color: theme.accent),
              SizedBox(width: 8),
              Text(l10n.loyaltyPoints, style: TextStyle(color: theme.textPrimary, fontWeight: FontWeight.bold)),
            ],
          ),
          SizedBox(height: 8),
          Text(l10n.loyaltyPrompt('20,000'), style: TextStyle(color: theme.textSecondary)),
          SizedBox(height: theme.spacingMd),
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  hintText: l10n.enterPoints,
                  keyboardType: TextInputType.number,
                ),
              ),
              SizedBox(width: theme.spacingMd),
              AppButton(
                text: l10n.usePoints,
                backgroundColor: theme.accent,
                textColor: Colors.white,
                onPressed: () {},
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildSeatChip(CineplexColors theme, String seat) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: theme.primary.withValues(alpha: 0.3)),
      ),
      child: Text(seat, style: TextStyle(color: theme.primary, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }

  Widget _buildBreakdownRow(CineplexColors theme, String title, int amount, {bool isDiscount = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(color: isDiscount ? theme.success : theme.textSecondary)),
          Text(
            isDiscount ? FormatUtils.formatCurrency(amount) : FormatUtils.formatCurrency(amount),
            style: TextStyle(color: isDiscount ? theme.success : theme.textPrimary, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

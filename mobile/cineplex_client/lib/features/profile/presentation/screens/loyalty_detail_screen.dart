import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mobile_shared/mobile_shared.dart';
import '../../data/repositories/profile_repository.dart';

class LoyaltyDetailScreen extends StatefulWidget {
  final Map<String, dynamic>? initialUser;
  final Map<String, dynamic>? initialLoyalty;

  const LoyaltyDetailScreen({
    super.key,
    this.initialUser,
    this.initialLoyalty,
  });

  @override
  State<LoyaltyDetailScreen> createState() => _LoyaltyDetailScreenState();
}

class _LoyaltyDetailScreenState extends State<LoyaltyDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  String? _errorMessage;
  int _currentPoints = 0;
  List<Map<String, dynamic>> _historyItems = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _currentPoints = (widget.initialLoyalty?['loyaltyPoints'] as num?)?.toInt() ??
        (widget.initialUser?['loyaltyPoints'] as num?)?.toInt() ??
        0;
    _loadHistory();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final repo = context.read<ProfileRepository>();
      final data = await repo.getLoyaltyHistory();

      if (mounted) {
        final pts = (data['loyaltyPoints'] as num?)?.toInt();
        final rawList = data['items'];
        final List<Map<String, dynamic>> list = [];
        if (rawList is List) {
          for (final item in rawList) {
            if (item is Map<String, dynamic>) {
              list.add(item);
            }
          }
        }

        setState(() {
          if (pts != null) _currentPoints = pts;
          _historyItems = list;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  String _formatDateTime(dynamic dateValue) {
    if (dateValue == null) return '';
    try {
      final dt = dateValue is DateTime
          ? dateValue
          : DateTime.parse(dateValue.toString()).toLocal();
      return DateFormat('dd/MM/yyyy HH:mm').format(dt);
    } catch (_) {
      return dateValue.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = CineplexColors.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final userName = widget.initialUser?['fullName'] ??
        widget.initialUser?['name'] ??
        l10n.loyaltyCardSubtitle;
    final userEmail = widget.initialUser?['email'] ?? '';

    return AppScaffold(
      title: l10n.loyaltyInfo,
      body: Column(
        children: [
          // Top membership card banner
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFE50914),
                    Color(0xFF8B0000),
                    Color(0xFF4A0000),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFE50914).withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.stars_rounded,
                            color: Color(0xFFFFD700),
                            size: 20,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            l10n.appTitle,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFFFFD700).withValues(alpha: 0.5),
                            ),
                          ),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              l10n.loyaltyCardSubtitle,
                              style: const TextStyle(
                                color: Color(0xFFFFD700),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.loyaltyTotalPoints,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          FormatUtils.formatNumber(_currentPoints),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          l10n.pointsSuffix,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          userName.toString(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (userEmail.isNotEmpty)
                        Flexible(
                          child: Text(
                            userEmail.toString(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Tab Bar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: isDark ? colors.card : colors.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              labelPadding: const EdgeInsets.symmetric(horizontal: 4),
              labelColor: Colors.white,
              unselectedLabelColor: colors.textSecondary,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                color: colors.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              dividerColor: Colors.transparent,
              tabs: [
                Tab(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.history_rounded, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          l10n.loyaltyTabHistory,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
                Tab(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.menu_book_rounded, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          l10n.loyaltyTabPolicy,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildHistoryTab(colors, l10n, isDark),
                _buildPolicyTab(colors, l10n, isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTab(
    CineplexColors colors,
    AppLocalizations l10n,
    bool isDark,
  ) {
    if (_isLoading) {
      return const Center(child: AppLoading());
    }

    if (_errorMessage != null) {
      return Center(
        child: AppErrorView(
          message: l10n.errorOccurred,
          onRetry: _loadHistory,
        ),
      );
    }

    if (_historyItems.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadHistory,
        color: colors.primary,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
          children: [
            Center(
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
                    child: Icon(
                      Icons.receipt_long_rounded,
                      size: 36,
                      color: colors.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.loyaltyNoHistory,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l10n.loyaltyNoHistorySubtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadHistory,
      color: colors.primary,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
        itemCount: _historyItems.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final item = _historyItems[index];
          final type = (item['type'] ?? '').toString().toUpperCase();
          final points = (item['points'] as num?)?.toInt() ?? 0;
          final title = item['title'] ?? (points > 0 ? l10n.loyaltyPolicyEarn : l10n.loyaltyPolicyDiscount);
          final description = item['description'] ?? '';
          final createdAt = item['createdAt'];

          final isPositive = points > 0;
          final pointColor = isPositive ? colors.success : colors.warning;
          final iconData = type == 'EARN'
              ? Icons.arrow_upward_rounded
              : (type == 'REFUND'
                  ? Icons.replay_rounded
                  : Icons.arrow_downward_rounded);

          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _showTransactionDetail(context, item, colors, l10n, isDark),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? colors.card : colors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: colors.borderSubtle,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: pointColor.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        iconData,
                        color: pointColor,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title.toString(),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: colors.textPrimary,
                            ),
                          ),
                          if (description.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              description.toString(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                color: colors.textSecondary,
                              ),
                            ),
                          ],
                          const SizedBox(height: 4),
                          Text(
                            _formatDateTime(createdAt),
                            style: TextStyle(
                              fontSize: 11,
                              color: colors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${isPositive ? '+' : '-'}${FormatUtils.formatNumber(points.abs())}',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: pointColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Icon(
                          Icons.chevron_right_rounded,
                          size: 16,
                          color: colors.textMuted,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showTransactionDetail(
    BuildContext context,
    Map<String, dynamic> item,
    CineplexColors colors,
    AppLocalizations l10n,
    bool isDark,
  ) {
    final points = (item['points'] as num?)?.toInt() ?? 0;
    final isPositive = points > 0;
    final pointColor = isPositive ? colors.success : colors.warning;
    final title = item['title'] ?? (isPositive ? l10n.loyaltyPolicyEarn : l10n.loyaltyPolicyDiscount);
    final createdAt = item['createdAt'];
    final bookingId = item['bookingId'];
    final bookingCode = item['bookingCode']?.toString();
    final movieTitle = item['movieTitle']?.toString();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? colors.card : colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.loyaltyTransactionDetail,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: colors.textPrimary,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        color: colors.textSecondary,
                        splashRadius: 20,
                        onPressed: () => Navigator.of(sheetContext).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                    decoration: BoxDecoration(
                      color: pointColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: pointColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '${isPositive ? '+' : '-'}${FormatUtils.formatNumber(points.abs())} ${l10n.pointsSuffix}',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: pointColor,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          title.toString(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: colors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark
                          ? colors.surfaceVariant.withValues(alpha: 0.5)
                          : colors.surfaceVariant.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: colors.borderSubtle),
                    ),
                    child: Column(
                      children: [
                        if (bookingCode != null && bookingCode.isNotEmpty) ...[
                          _buildDetailRow(
                            label: l10n.loyaltyOrderCode,
                            value: '#$bookingCode',
                            colors: colors,
                          ),
                          Divider(color: colors.borderSubtle, height: 16),
                        ],
                        if (movieTitle != null && movieTitle.isNotEmpty) ...[
                          _buildDetailRow(
                            label: l10n.movies,
                            value: movieTitle,
                            colors: colors,
                          ),
                          Divider(color: colors.borderSubtle, height: 16),
                        ],
                        _buildDetailRow(
                          label: l10n.loyaltyTransactionTime,
                          value: _formatDateTime(createdAt),
                          colors: colors,
                        ),
                        Divider(color: colors.borderSubtle, height: 16),
                        _buildDetailRow(
                          label: l10n.loyaltyPointsChange,
                          value: '${isPositive ? '+' : '-'}${FormatUtils.formatNumber(points.abs())}',
                          colors: colors,
                          valueColor: pointColor,
                          valueWeight: FontWeight.bold,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (bookingId != null && bookingId.toString().isNotEmpty) ...[
                    AppButton(
                      text: l10n.loyaltyViewTicket,
                      icon: Icons.confirmation_number_outlined,
                      onPressed: () {
                        Navigator.of(sheetContext).pop();
                        context.push('/my-tickets/$bookingId');
                      },
                    ),
                    const SizedBox(height: 10),
                  ],
                  AppButton(
                    text: l10n.close,
                    isOutlined: true,
                    onPressed: () => Navigator.of(sheetContext).pop(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow({
    required String label,
    required String value,
    required CineplexColors colors,
    Color? valueColor,
    FontWeight? valueWeight,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: colors.textSecondary,
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: 13,
              fontWeight: valueWeight ?? FontWeight.w500,
              color: valueColor ?? colors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPolicyTab(
    CineplexColors colors,
    AppLocalizations l10n,
    bool isDark,
  ) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      children: [
        _buildPolicyCard(
          icon: Icons.card_giftcard_rounded,
          iconColor: const Color(0xFFE50914),
          title: l10n.earnRate,
          description: l10n.loyaltyPolicyEarn,
          colors: colors,
          isDark: isDark,
        ),
        const SizedBox(height: 12),
        _buildPolicyCard(
          icon: Icons.currency_exchange_rounded,
          iconColor: const Color(0xFFFFB800),
          title: l10n.pointValue,
          description: l10n.loyaltyPolicyDiscount,
          colors: colors,
          isDark: isDark,
        ),
        const SizedBox(height: 12),
        _buildPolicyCard(
          icon: Icons.replay_circle_filled_rounded,
          iconColor: const Color(0xFF2E7D32),
          title: l10n.cancel,
          description: l10n.loyaltyPolicyRefund,
          colors: colors,
          isDark: isDark,
        ),
        const SizedBox(height: 12),
        _buildPolicyCard(
          icon: Icons.fastfood_rounded,
          iconColor: const Color(0xFFFF9800),
          title: l10n.redeemWithPoints,
          description: l10n.loyaltyPolicyGifts,
          colors: colors,
          isDark: isDark,
        ),
        const SizedBox(height: 12),
        _buildPolicyCard(
          icon: Icons.local_offer_rounded,
          iconColor: const Color(0xFF1E88E5),
          title: l10n.discountAmount,
          description: l10n.loyaltyPolicyVoucher,
          colors: colors,
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildPolicyCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
    required CineplexColors colors,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? colors.card : colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.borderSubtle, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.45,
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mobile_shared/mobile_shared.dart';

import '../cubit/ticket_management_cubit.dart';
import '../cubit/ticket_management_state.dart';
import '../widgets/booking_ticket_card.dart';
import '../widgets/booking_detail_bottom_sheet.dart';
import '../widgets/ticket_price_table.dart';

class TicketManagementScreen extends StatefulWidget {
  final Widget? drawer;

  const TicketManagementScreen({super.key, this.drawer});

  @override
  State<TicketManagementScreen> createState() => _TicketManagementScreenState();
}

class _TicketManagementScreenState extends State<TicketManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    context.read<TicketManagementCubit>().loadAll();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<CineplexColors>()!;
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return AppScaffold(
      title: l10n.manageTickets,
      drawer: widget.drawer,
      actions: [
        IconButton(
          icon: const Icon(LucideIcons.scanLine),
          tooltip: l10n.ticketOpenScanner,
          onPressed: () => context.push('/scanner'),
        ),
      ],
      body: Column(
        children: [
          // Tab bar
          Container(
            color: colors.surface,
            child: TabBar(
              controller: _tabController,
              indicatorColor: colorScheme.primary,
              labelColor: colorScheme.primary,
              unselectedLabelColor: colors.textSecondary,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 14,
              ),
              tabs: [
                Tab(
                  icon: const Icon(LucideIcons.ticket, size: 18),
                  text: l10n.ticketBookingList,
                ),
                Tab(
                  icon: const Icon(LucideIcons.tag, size: 18),
                  text: l10n.ticketPriceConfig,
                ),
              ],
            ),
          ),
          Divider(color: colors.borderSubtle, height: 1),

          // Tab content
          Expanded(
            child: BlocBuilder<TicketManagementCubit, TicketManagementState>(
              builder: (context, state) {
                if (state is TicketManagementLoading) {
                  return const Center(child: AppLoading());
                } else if (state is TicketManagementError) {
                  return AppErrorView(
                    message: state.message,
                    onRetry: () =>
                        context.read<TicketManagementCubit>().loadAll(),
                  );
                } else if (state is TicketManagementLoaded) {
                  return TabBarView(
                    controller: _tabController,
                    children: [
                      // Tab 0: Bookings
                      _buildBookingsTab(context, state),

                      // Tab 1: Ticket Prices
                      TicketPriceTable(
                        prices: state.ticketPrices,
                        onUpdatePrice: (id, price) => context
                            .read<TicketManagementCubit>()
                            .updatePrice(id, price),
                      ),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingsTab(BuildContext context, TicketManagementLoaded state) {
    final colors = Theme.of(context).extension<CineplexColors>()!;
    final l10n = AppLocalizations.of(context)!;
    final bookings = state.filteredBookings;

    return Column(
      children: [
        // Search & Filter header
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          color: colors.surface,
          child: Column(
            children: [
              // Search input
              TextField(
                controller: _searchController,
                style: TextStyle(color: colors.textPrimary, fontSize: 14),
                decoration: InputDecoration(
                  hintText: l10n.ticketSearchHint,
                  hintStyle: TextStyle(color: colors.textMuted, fontSize: 13.5),
                  prefixIcon: Icon(
                    LucideIcons.search,
                    size: 18,
                    color: colors.iconSecondary,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(LucideIcons.x, size: 16),
                          onPressed: () {
                            _searchController.clear();
                            context.read<TicketManagementCubit>().search('');
                          },
                        )
                      : null,
                  isDense: true,
                  filled: true,
                  fillColor: colors.surfaceVariant.withValues(alpha: 0.5),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colors.borderSubtle),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colors.borderSubtle),
                  ),
                ),
                onChanged: (val) =>
                    context.read<TicketManagementCubit>().search(val),
              ),
              const SizedBox(height: 10),

              // Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip(
                      context,
                      label: l10n.ticketFilterAll,
                      value: 'ALL',
                      current: state.statusFilter,
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      context,
                      label: l10n.ticketStatusConfirmed,
                      value: 'CONFIRMED',
                      current: state.statusFilter,
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      context,
                      label: l10n.ticketStatusPending,
                      value: 'PENDING',
                      current: state.statusFilter,
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      context,
                      label: l10n.ticketStatusCancelled,
                      value: 'CANCELLED',
                      current: state.statusFilter,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Divider(color: colors.borderSubtle, height: 1),

        // List
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => context.read<TicketManagementCubit>().loadAll(),
            child: bookings.isEmpty
                ? Center(
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: AppEmptyView(message: l10n.ticketEmptyList),
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: bookings.length,
                    itemBuilder: (context, index) {
                      final item = bookings[index];
                      return BookingTicketCard(
                        booking: item,
                        onTap: () =>
                            BookingDetailBottomSheet.show(context, item),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(
    BuildContext context, {
    required String label,
    required String value,
    required String current,
  }) {
    final colors = Theme.of(context).extension<CineplexColors>()!;
    final colorScheme = Theme.of(context).colorScheme;
    final isSelected = current == value;

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: colorScheme.primary,
      backgroundColor: colors.surfaceVariant.withValues(alpha: 0.5),
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        color: isSelected ? Colors.white : colors.textSecondary,
      ),
      side: BorderSide(
        color: isSelected ? colorScheme.primary : colors.borderSubtle,
      ),
      onSelected: (_) =>
          context.read<TicketManagementCubit>().setStatusFilter(value),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_shared/mobile_shared.dart';
import '../cubit/my_tickets_cubit.dart';
import '../widgets/ticket_card.dart';

class MyTicketsScreen extends StatefulWidget {
  const MyTicketsScreen({super.key});

  @override
  State<MyTicketsScreen> createState() => _MyTicketsScreenState();
}

class _MyTicketsScreenState extends State<MyTicketsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    context.read<MyTicketsCubit>().loadMyTickets();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = CineplexColors.of(context);

    return AppScaffold(
      title: l10n.myTickets,
      bottomSafeArea: false,
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            labelColor: colors.primary,
            unselectedLabelColor: colors.textSecondary,
            indicatorColor: colors.primary,
            tabs: [
              Tab(text: l10n.upcomingTickets),
              Tab(text: l10n.pastTickets),
            ],
          ),
          Expanded(
            child: BlocBuilder<MyTicketsCubit, MyTicketsState>(
              builder: (context, state) {
                if (state is MyTicketsLoading) return const AppLoading();
                if (state is MyTicketsLoaded) {
                  return TabBarView(
                    controller: _tabController,
                    children: [
                      _buildList(state.upcoming, l10n, colors),
                      _buildList(state.past, l10n, colors),
                    ],
                  );
                }
                if (state is MyTicketsError) {
                  return AppErrorView(
                    message: state.message,
                    onRetry: () => context.read<MyTicketsCubit>().loadMyTickets(),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _buildList(List bookings, AppLocalizations l10n, CineplexColors colors) {
    final bottomPadding = 100 + MediaQuery.of(context).padding.bottom;

    if (bookings.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.fromLTRB(24, 24, 24, bottomPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.confirmation_number_outlined,
                size: 64,
                color: colors.iconMuted,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.ticketListEmptyPrompt,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: colors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              AppButton(
                text: l10n.bookNow,
                onPressed: () => context.go('/movies'),
              ),
            ],
          ),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: () => context.read<MyTicketsCubit>().loadMyTickets(),
      color: colors.primary,
      child: ListView.builder(
        padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPadding),
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          return TicketCard(booking: bookings[index]);
        },
      ),
    );
  }
}

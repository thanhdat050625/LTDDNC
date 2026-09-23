import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cineplex_mobile/core/widgets/app_scaffold.dart';
import 'package:cineplex_mobile/core/widgets/app_loading.dart';
import '../cubit/my_tickets_cubit.dart';
import '../widgets/ticket_card.dart';

class MyTicketsScreen extends StatefulWidget {
  const MyTicketsScreen({Key? key}) : super(key: key);

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
    return AppScaffold(
      title: 'My Tickets',
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            tabs: const [Tab(text: 'Upcoming'), Tab(text: 'Past')],
          ),
          Expanded(
            child: BlocBuilder<MyTicketsCubit, MyTicketsState>(
              builder: (context, state) {
                if (state is MyTicketsLoading) return const AppLoading();
                if (state is MyTicketsLoaded) {
                  return TabBarView(
                    controller: _tabController,
                    children: [
                      _buildList(state.upcoming),
                      _buildList(state.past),
                    ],
                  );
                }
                if (state is MyTicketsError) return Center(child: Text(state.message));
                return const SizedBox.shrink();
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _buildList(List bookings) {
    if (bookings.isEmpty) return const Center(child: Text('No tickets found'));
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        return TicketCard(booking: bookings[index]);
      },
    );
  }
}

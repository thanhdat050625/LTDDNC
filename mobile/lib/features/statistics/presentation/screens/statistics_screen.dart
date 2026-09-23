import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cineplex_mobile/core/widgets/app_scaffold.dart';
import 'package:cineplex_mobile/core/widgets/app_loading.dart';
import 'package:cineplex_mobile/core/utils/format_utils.dart';
import '../cubit/statistics_cubit.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({Key? key}) : super(key: key);

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<StatisticsCubit>().loadStats();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Statistics',
      body: BlocBuilder<StatisticsCubit, StatisticsState>(
        builder: (context, state) {
          if (state is StatisticsLoading) return const AppLoading();
          if (state is StatisticsLoaded) {
            final summary = state.summary;
            return GridView.count(
              padding: const EdgeInsets.all(16),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildCard('Revenue', FormatUtils.formatCurrency((summary.revenue).toInt()), Icons.attach_money, Colors.green),
                _buildCard('Tickets', summary.tickets.toString(), Icons.confirmation_num, Colors.blue),
                _buildCard('Cinemas', summary.cinemas.toString(), Icons.business, Colors.orange),
                _buildCard('Active Movies', summary.activeMovies.toString(), Icons.movie, Colors.purple),
              ],
            );
          }
          if (state is StatisticsError) return Center(child: Text(state.message));
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_shared/mobile_shared.dart';
import 'package:cineplex_client/features/home/presentation/cubit/home_cubit.dart';
import 'package:cineplex_client/features/home/presentation/widgets/movie_carousel.dart';
import 'package:cineplex_client/features/home/presentation/widgets/now_showing_section.dart';
import 'package:cineplex_client/features/home/presentation/widgets/coming_soon_section.dart';
import 'package:cineplex_client/features/notification/presentation/widgets/notification_badge_icon.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Đảm bảo dữ liệu được tải khi vào màn hình này
    final cubit = context.read<HomeCubit>();
    if (cubit.state is HomeInitial) {
      cubit.load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = CineplexColors.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) {
            if (state is HomeLoading || state is HomeInitial) {
              return const Center(child: AppLoading());
            } else if (state is HomeError) {
              return AppErrorView(
                message: state.error,
                onRetry: () => context.read<HomeCubit>().load(),
              );
            } else if (state is HomeLoaded) {
              final data = state.data;
              return RefreshIndicator(
                onRefresh: () async => context.read<HomeCubit>().load(),
                color: colors.primary,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.movie_filter_rounded, color: colors.primary, size: 28),
                                const SizedBox(width: 8),
                                Text(
                                  l10n.appTitle,
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colors.primary,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ],
                            ),
                            IconButton(
                              icon: NotificationBadgeIcon(
                                color: colors.iconPrimary,
                                size: 24,
                                icon: Icons.notifications_none_outlined,
                              ),
                              onPressed: () => context.push('/notifications'),
                            ),
                          ],
                        ),
                      ),
                      if (data.nowShowing.isNotEmpty)
                        MovieCarousel(movies: data.nowShowing.take(5).toList()),
                      const SizedBox(height: 24),
                      NowShowingSection(movies: data.nowShowing),
                      const SizedBox(height: 24),
                      ComingSoonSection(movies: data.comingSoon),
                      SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
                    ],
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cineplex_mobile/l10n/app_localizations.dart';
import 'package:cineplex_mobile/core/theme/app_colors.dart';
import 'package:cineplex_mobile/features/home/presentation/cubit/home_cubit.dart';
import 'package:cineplex_mobile/features/home/presentation/widgets/movie_carousel.dart';
import 'package:cineplex_mobile/features/home/presentation/widgets/now_showing_section.dart';
import 'package:cineplex_mobile/features/home/presentation/widgets/coming_soon_section.dart';
import 'package:cineplex_mobile/features/home/presentation/widgets/promotion_banner.dart';
import 'package:cineplex_mobile/core/widgets/app_loading.dart';
import 'package:cineplex_mobile/core/widgets/app_error_view.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) {
            if (state is HomeLoading) {
              return const Center(child: AppLoading());
            } else if (state is HomeError) {
              return AppErrorView(message: state.error, onRetry: () => context.read<HomeCubit>().load());
            } else if (state is HomeLoaded) {
              final data = state.data;
              return RefreshIndicator(
                onRefresh: () async => context.read<HomeCubit>().load(),
                color: AppColors.primary,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          l10n.welcome,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      if (data.nowShowing.isNotEmpty)
                        MovieCarousel(movies: data.nowShowing.take(5).toList()),
                      const SizedBox(height: 24),
                      NowShowingSection(movies: data.nowShowing),
                      const SizedBox(height: 24),
                      ComingSoonSection(movies: data.comingSoon),
                      const SizedBox(height: 24),
                      PromotionBanner(promotions: data.activePromotions),
                      const SizedBox(height: 48),
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

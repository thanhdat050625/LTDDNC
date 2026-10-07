import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mobile_shared/mobile_shared.dart';

class MovieManagementDetailScreen extends StatefulWidget {
  final int movieId;
  final MovieModel? initialMovie;

  const MovieManagementDetailScreen({
    super.key,
    required this.movieId,
    this.initialMovie,
  });

  @override
  State<MovieManagementDetailScreen> createState() =>
      _MovieManagementDetailScreenState();
}

class _MovieManagementDetailScreenState
    extends State<MovieManagementDetailScreen> {
  late MovieModel? _movie;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _movie = widget.initialMovie;
    _loadMovieDetail();
  }

  Future<void> _loadMovieDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final repo = MovieManagementRepository(context.read<DioClient>());
      final fetched = await repo.getMovieDetail(widget.movieId);
      if (mounted) {
        setState(() {
          _movie = fetched;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          if (_movie == null) {
            _errorMessage = e.toString();
          }
        });
      }
    }
  }

  void _openTrailerPlayer(
    BuildContext context,
    String url,
    String title, {
    String? genre,
    int? durationMinutes,
    String? description,
  }) {
    TrailerPlayerScreen.open(
      context,
      trailerUrl: url,
      title: title,
      genre: genre,
      durationMinutes: durationMinutes,
      description: description,
    );
  }

  Future<void> _navigateToEdit() async {
    if (_movie == null) return;
    await context.push('/movies/${_movie!.id}/edit', extra: _movie);
    if (mounted) {
      _loadMovieDetail();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<CineplexColors>()!;
    final l10n = AppLocalizations.of(context)!;

    return AppScaffold(
      title: l10n.movieDetail,
      actions: [
        if (_movie != null)
          IconButton(
            icon: const Icon(LucideIcons.pencil),
            tooltip: l10n.editMovie,
            onPressed: _navigateToEdit,
          ),
      ],
      body: _buildBody(theme, l10n),
    );
  }

  Widget _buildBody(CineplexColors theme, AppLocalizations l10n) {
    if (_isLoading && _movie == null) {
      return const AppLoading();
    }

    if (_errorMessage != null && _movie == null) {
      return AppErrorView(message: _errorMessage!, onRetry: _loadMovieDetail);
    }

    if (_movie == null) {
      return Center(
        child: Text(l10n.noData, style: TextStyle(color: theme.textSecondary)),
      );
    }

    final movie = _movie!;
    final dateFormat = DateFormat('dd/MM/yyyy');
    final releaseStr = movie.releaseDate != null
        ? dateFormat.format(movie.releaseDate!)
        : '---';
    final endStr = movie.screeningEndDate != null
        ? dateFormat.format(movie.screeningEndDate!)
        : '---';
    final hasTrailer =
        movie.trailerUrl != null && movie.trailerUrl!.trim().isNotEmpty;

    return RefreshIndicator(
      onRefresh: _loadMovieDetail,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          theme.spacingMd,
          theme.spacingSm,
          theme.spacingMd,
          theme.spacingMd,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Section: Poster + Basic Details
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Poster & Trailer Action
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Hero(
                      tag: 'movie_poster_${movie.id}',
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(theme.radiusMd),
                        child: Container(
                          width: 110,
                          height: 160,
                          color: theme.surface,
                          child:
                              (movie.posterUrl != null &&
                                  movie.posterUrl!.isNotEmpty)
                              ? AppCachedImage(
                                  imageUrl: movie.posterUrl!,
                                  fit: BoxFit.cover,
                                )
                              : Center(
                                  child: Icon(
                                    LucideIcons.film,
                                    size: 40,
                                    color: theme.textSecondary,
                                  ),
                                ),
                        ),
                      ),
                    ),
                    if (hasTrailer) ...[
                      const SizedBox(height: 8),
                      SizedBox(
                        width: 110,
                        height: 34,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                theme.radiusSm,
                              ),
                            ),
                            elevation: 0,
                          ),
                          icon: const Icon(LucideIcons.play, size: 14),
                          label: Text(
                            l10n.watchTrailer,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onPressed: () => _openTrailerPlayer(
                            context,
                            movie.trailerUrl!,
                            movie.title,
                            genre: movie.genre,
                            durationMinutes: movie.durationMinutes,
                            description: movie.description,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                SizedBox(width: theme.spacingMd),

                // Title & Badges
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        movie.title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: theme.textPrimary,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Status Badge
                      _buildStatusBadge(movie.status, theme, l10n),
                      const SizedBox(height: 10),

                      // Chips: Duration, AgeLimit, Genre, Language
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          if (movie.durationMinutes > 0)
                            _buildInfoChip(
                              icon: LucideIcons.clock,
                              label: l10n.durationMinutes(
                                movie.durationMinutes,
                              ),
                              theme: theme,
                            ),
                          if (movie.ageLimit != null && movie.ageLimit! > 0)
                            _buildInfoChip(
                              icon: LucideIcons.shieldAlert,
                              label: '${movie.ageLimit}+',
                              theme: theme,
                              color: theme.accent,
                            ),
                          if (movie.genre.isNotEmpty)
                            _buildInfoChip(
                              icon: LucideIcons.tags,
                              label: movie.genre,
                              theme: theme,
                            ),
                          if (movie.language != null &&
                              movie.language!.isNotEmpty)
                            _buildInfoChip(
                              icon: LucideIcons.languages,
                              label: movie.language!,
                              theme: theme,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Info Card
            AppCard(
              padding: EdgeInsets.all(theme.spacingMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(LucideIcons.info, size: 18, color: theme.primary),
                      const SizedBox(width: 8),
                      Text(
                        l10n.movieInfo,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: theme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  _buildDetailRow(
                    l10n.director,
                    movie.director ?? '---',
                    theme,
                  ),
                  const SizedBox(height: 10),
                  _buildDetailRow(l10n.cast, movie.cast ?? '---', theme),
                  const SizedBox(height: 10),
                  _buildDetailRow(l10n.releaseDate, releaseStr, theme),
                  const SizedBox(height: 10),
                  _buildDetailRow(l10n.screeningEndDate, endStr, theme),
                  if (movie.language != null && movie.language!.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    _buildDetailRow(l10n.language, movie.language!, theme),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Description Card
            AppCard(
              padding: EdgeInsets.all(theme.spacingMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        LucideIcons.fileText,
                        size: 18,
                        color: theme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        l10n.movieDescription,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: theme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  SelectableText(
                    (movie.description != null &&
                            movie.description!.trim().isNotEmpty)
                        ? movie.description!
                        : '---',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.6,
                      color: theme.textPrimary.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(
    String status,
    CineplexColors theme,
    AppLocalizations l10n,
  ) {
    Color badgeColor;
    String badgeText;

    switch (status.toUpperCase()) {
      case 'NOW_SHOWING':
        badgeColor = theme.success;
        badgeText = l10n.nowShowing;
        break;
      case 'COMING_SOON':
        badgeColor = theme.accent;
        badgeText = l10n.comingSoon;
        break;
      case 'STOPPED':
      default:
        badgeColor = theme.error;
        badgeText = l10n.stoppedShowing;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: badgeColor.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: badgeColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              badgeText,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: badgeColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required CineplexColors theme,
    Color? color,
  }) {
    final chipColor = color ?? theme.textSecondary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.background,
        borderRadius: BorderRadius.circular(theme.radiusSm),
        border: Border.all(color: theme.textSecondary.withValues(alpha: 0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: chipColor),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                color: chipColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, CineplexColors theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: theme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              color: theme.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mobile_shared/mobile_shared.dart';

class TicketSaleScreen extends StatefulWidget {
  const TicketSaleScreen({super.key});

  @override
  State<TicketSaleScreen> createState() => _TicketSaleScreenState();
}

class _TicketSaleScreenState extends State<TicketSaleScreen> {
  late List<String> _cinemas;
  late String _selectedCinema;

  final List<Map<String, dynamic>> _movies = [
    {
      'id': '1',
      'title': 'Mai',
      'duration': 131,
      'poster': 'https://res.cloudinary.com/dn4vjsers/image/upload/v1/movies/mai',
    },
    {
      'id': '2',
      'title': 'Đào, Phở và Piano',
      'duration': 100,
      'poster': 'https://res.cloudinary.com/dn4vjsers/image/upload/v1/movies/dao',
    }
  ];
  String? _selectedMovieId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final l10n = AppLocalizations.of(context)!;
    _cinemas = [l10n.cineplexDistrict1, 'Cineplex Quận 2', 'Cineplex Gò Vấp'];
    _selectedCinema = _cinemas.first;
  }

  @override
  void initState() {
    super.initState();
    if (_movies.isNotEmpty) {
      _selectedMovieId = _movies[0]['id'];
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<CineplexColors>()!;
    final l10n = AppLocalizations.of(context)!;

    return AppScaffold(
      title: l10n.counterSale,
      body: SizedBox.expand(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top: Movies list (35% height)
            Expanded(
              flex: 35,
              child: Container(
                decoration: BoxDecoration(
                  color: theme.surface,
                  border: Border(bottom: BorderSide(color: theme.textSecondary.withValues(alpha: 0.1))),
                ),
                child: Column(
                  children: [
                    _buildCinemaSelector(theme, l10n),
                    Divider(color: theme.textSecondary.withValues(alpha: 0.1), height: 1),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _movies.length,
                        itemBuilder: (context, index) {
                          final movie = _movies[index];
                          final isSelected = movie['id'] == _selectedMovieId;
                          return InkWell(
                            onTap: () => setState(() => _selectedMovieId = movie['id']),
                            child: Container(
                              padding: EdgeInsets.all(theme.spacingMd),
                              decoration: BoxDecoration(
                                color: isSelected ? theme.primary.withValues(alpha: 0.1) : Colors.transparent,
                                border: Border(
                                  left: BorderSide(
                                    color: isSelected ? theme.primary : Colors.transparent,
                                    width: 4,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: theme.textSecondary.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(theme.radiusSm),
                                    ),
                                    child: Icon(LucideIcons.film, color: theme.textSecondary, size: 20),
                                  ),
                                  SizedBox(width: theme.spacingSm),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          movie['title'],
                                          style: TextStyle(
                                            color: theme.textPrimary,
                                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          l10n.durationMinutes(movie['duration']),
                                          style: TextStyle(
                                            color: theme.textSecondary,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Main content: Showtimes (65% height)
            Expanded(
              flex: 65,
              child: _selectedMovieId == null
                  ? Center(child: Text(l10n.noData, style: TextStyle(color: theme.textSecondary)))
                  : _buildShowtimes(theme, l10n),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCinemaSelector(CineplexColors theme, AppLocalizations l10n) {
    return Padding(
      padding: EdgeInsets.all(theme.spacingMd),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: theme.spacingMd),
        decoration: BoxDecoration(
          color: theme.background,
          borderRadius: BorderRadius.circular(theme.radiusMd),
          border: Border.all(color: theme.textSecondary.withValues(alpha: 0.2)),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _selectedCinema,
            isExpanded: true,
            dropdownColor: theme.surface,
            icon: Icon(LucideIcons.chevronDown, color: theme.textPrimary),
            style: TextStyle(color: theme.textPrimary, fontWeight: FontWeight.bold),
            onChanged: (value) {
              if (value != null) {
                setState(() => _selectedCinema = value);
              }
            },
            items: _cinemas.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildShowtimes(CineplexColors theme, AppLocalizations l10n) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(theme.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.todayShowtimes,
            style: AppTextStyles.title.copyWith(color: theme.textPrimary),
          ),
          SizedBox(height: theme.spacingMd),
          Wrap(
            spacing: theme.spacingMd,
            runSpacing: theme.spacingMd,
            children: [
              _buildShowtimeCard(theme, '10:00', l10n.standard2D),
              _buildShowtimeCard(theme, '12:30', l10n.standard2D),
              _buildShowtimeCard(theme, '15:15', 'VIP • 2D'),
              _buildShowtimeCard(theme, '18:00', 'IMAX • 3D'),
              _buildShowtimeCard(theme, '20:45', 'Couple • 2D'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShowtimeCard(CineplexColors theme, String time, String type) {
    return GestureDetector(
      onTap: () => context.push('/ticket-sale/seat-selection'),
      child: AppCard(
        padding: EdgeInsets.symmetric(vertical: theme.spacingMd, horizontal: theme.spacingSm),
        child: Column(
          children: [
            Text(
              time,
              style: TextStyle(
                color: theme.primary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
            Text(
              type,
              style: TextStyle(
                color: theme.textSecondary,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

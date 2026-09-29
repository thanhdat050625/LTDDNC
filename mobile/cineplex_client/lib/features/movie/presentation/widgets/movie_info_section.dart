import 'package:flutter/material.dart';
import 'package:mobile_shared/l10n/app_localizations.dart';

class MovieInfoSection extends StatelessWidget {
  final String? director;
  final String? cast;
  final String? language;
  final String? releaseDate;

  const MovieInfoSection({
    super.key,
    this.director,
    this.cast,
    this.language,
    this.releaseDate,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRow(context, Icons.person, l10n.director, director ?? '-'),
        const SizedBox(height: 12),
        _buildRow(context, Icons.group, l10n.cast, cast ?? '-'),
        const SizedBox(height: 12),
        _buildRow(context, Icons.language, l10n.language, language ?? '-'),
        const SizedBox(height: 12),
        _buildRow(context, Icons.calendar_today, l10n.releaseDate, releaseDate ?? '-'),
      ],
    );
  }

  Widget _buildRow(BuildContext context, IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
        const SizedBox(width: 12),
        SizedBox(
          width: 90, 
          child: Text(
            label, 
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5))
          ),
        ),
        Expanded(
          child: Text(
            value, 
            style: TextStyle(fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.onSurface)
          )
        ),
      ],
    );
  }
}

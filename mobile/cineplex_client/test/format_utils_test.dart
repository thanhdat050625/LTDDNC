import 'package:flutter_test/flutter_test.dart';
import 'package:cineplex_client/core/utils/format_utils.dart';

void main() {
  test('FormatUtils currency, duration and countdown format checks', () {
    expect(FormatUtils.formatDuration(135), '2h 15m');
    expect(FormatUtils.formatCountdown(65), '01:05');
    expect(FormatUtils.formatCountdown(0), '00:00');
    expect(FormatUtils.formatCurrency(50000).contains('50'), isTrue);
  });
}

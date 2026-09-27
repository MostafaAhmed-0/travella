import 'package:intl/intl.dart';

class AppFormatters {
  AppFormatters._();

  // ── Currency ───────────────────────────────────────────────────────────────
  static String formatPrice(num amount, {String currency = 'USD'}) {
    final formatter = NumberFormat.currency(
      locale: 'en_US',
      symbol: _currencySymbol(currency),
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  static String _currencySymbol(String code) => switch (code) {
        'USD' => '\$',
        'EUR' => '€',
        'GBP' => '£',
        'SAR' => 'SAR ',
        'EGP' => 'EGP ',
        'AED' => 'AED ',
        _ => '$code ',
      };

  // ── Date ───────────────────────────────────────────────────────────────────
  static String formatDate(DateTime date) =>
      DateFormat('MMM dd, yyyy').format(date);

  static String formatDateShort(DateTime date) =>
      DateFormat('dd MMM').format(date);

  static String formatDateFull(DateTime date) =>
      DateFormat('EEEE, MMMM dd, yyyy').format(date);

  static String formatDateTime(DateTime date) =>
      DateFormat('MMM dd, yyyy • hh:mm a').format(date);

  static String timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 365) return '${(diff.inDays / 365).floor()} years ago';
    if (diff.inDays > 30) return '${(diff.inDays / 30).floor()} months ago';
    if (diff.inDays > 0) return '${diff.inDays} days ago';
    if (diff.inHours > 0) return '${diff.inHours} hours ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes} minutes ago';
    return 'Just now';
  }

  // ── Numbers ────────────────────────────────────────────────────────────────
  static String formatCompact(num number) {
    final formatter = NumberFormat.compact(locale: 'en_US');
    return formatter.format(number);
  }

  static String formatWithCommas(num number) {
    final formatter = NumberFormat('#,###', 'en_US');
    return formatter.format(number);
  }

  // ── Duration ──────────────────────────────────────────────────────────────
  static String formatDuration(int days) {
    if (days == 1) return '1 Day';
    if (days < 7) return '$days Days';
    if (days == 7) return '1 Week';
    if (days < 30) return '${(days / 7).floor()} Weeks';
    return '${(days / 30).floor()} Month${days > 59 ? 's' : ''}';
  }

  // ── Text ──────────────────────────────────────────────────────────────────
  static String truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return '${text[0].toUpperCase()}${text.substring(1)}';
  }
}

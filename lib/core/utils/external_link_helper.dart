import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

/// Helper utility for opening external URLs, social media links, and communication protocols safely
class ExternalLinkHelper {
  ExternalLinkHelper._();

  /// Launch an external link in a new browser tab (`target="_blank"`)
  static Future<bool> openExternalUrl(String rawUrl) async {
    final trimmed = rawUrl.trim();
    if (trimmed.isEmpty || trimmed == '#' || trimmed == 'javascript:void(0)') {
      debugPrint('[ExternalLinkHelper] Ignored empty or placeholder URL: "$trimmed"');
      return false;
    }

    String formatted = trimmed;
    if (!formatted.startsWith('http://') &&
        !formatted.startsWith('https://') &&
        !formatted.startsWith('mailto:') &&
        !formatted.startsWith('tel:')) {
      formatted = 'https://$formatted';
    }

    try {
      final uri = Uri.parse(formatted);
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
        webOnlyWindowName: '_blank',
      );
      return launched;
    } catch (e) {
      debugPrint('[ExternalLinkHelper] Error launching "$formatted": $e');
      return false;
    }
  }

  /// Launch WhatsApp with given phone number or link and prefilled message
  static Future<bool> openWhatsApp({
    required String rawPhoneOrUrl,
    String? message,
  }) async {
    final trimmed = rawPhoneOrUrl.trim();
    if (trimmed.isEmpty) return false;

    String targetUrl;
    final encodedMsg = message != null && message.isNotEmpty
        ? '?text=${Uri.encodeComponent(message)}'
        : '';

    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      if (message != null && !trimmed.contains('text=')) {
        final separator = trimmed.contains('?') ? '&' : '?';
        targetUrl = '$trimmed${separator}text=${Uri.encodeComponent(message)}';
      } else {
        targetUrl = trimmed;
      }
    } else {
      String cleanDigits = trimmed.replaceAll(RegExp(r'[^0-9]'), '');
      if (cleanDigits.startsWith('01') && cleanDigits.length == 11) {
        cleanDigits = '2$cleanDigits';
      } else if (cleanDigits.startsWith('00')) {
        cleanDigits = cleanDigits.substring(2);
      }
      targetUrl = 'https://wa.me/$cleanDigits$encodedMsg';
    }

    return openExternalUrl(targetUrl);
  }

  /// Launch email client with mailto:
  static Future<bool> openEmail(String email, {String? subject, String? body}) async {
    final trimmed = email.trim();
    if (trimmed.isEmpty) return false;

    final params = <String>[];
    if (subject != null && subject.isNotEmpty) {
      params.add('subject=${Uri.encodeComponent(subject)}');
    }
    if (body != null && body.isNotEmpty) {
      params.add('body=${Uri.encodeComponent(body)}');
    }

    final query = params.isNotEmpty ? '?${params.join('&')}' : '';
    return openExternalUrl('mailto:$trimmed$query');
  }

  /// Launch phone dialer with tel:
  static Future<bool> openPhone(String phone) async {
    final clean = phone.replaceAll(RegExp(r'[^\d+]'), '');
    if (clean.isEmpty) return false;
    return openExternalUrl('tel:$clean');
  }
}

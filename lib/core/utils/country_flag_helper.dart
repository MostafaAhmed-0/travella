/// Helper to resolve country flag emojis and country representations
class CountryFlagHelper {
  CountryFlagHelper._();

  static final Map<String, String> _countryFlagMap = {
    // Europe
    'spain': '🇪🇸',
    'إسبانيا': '🇪🇸',
    'united kingdom': '🇬🇧',
    'uk': '🇬🇧',
    'britain': '🇬🇧',
    'england': '🇬🇧',
    'المملكة المتحدة': '🇬🇧',
    'بريطانيا': '🇬🇧',
    'france': '🇫🇷',
    'فرنسا': '🇫🇷',
    'germany': '🇩🇪',
    'ألمانيا': '🇩🇪',
    'italy': '🇮🇹',
    'إيطاليا': '🇮🇹',
    'schengen': '🇪🇺',
    'schengen area': '🇪🇺',
    'شنغن': '🇪🇺',
    'دول الشنغن': '🇪🇺',
    'greece': '🇬🇷',
    'اليونان': '🇬🇷',
    'netherlands': '🇳🇱',
    'holland': '🇳🇱',
    'هولندا': '🇳🇱',
    'switzerland': '🇨🇭',
    'سويسرا': '🇨🇭',
    'austria': '🇦🇹',
    'النمسا': '🇦🇹',
    'portugal': '🇵🇹',
    'البرتغال': '🇵🇹',
    'belgium': '🇧🇪',
    'بلجيكا': '🇧🇪',
    'sweden': '🇸🇪',
    'السويد': '🇸🇪',
    'norway': '🇳🇴',
    'النرويج': '🇳🇴',
    'denmark': '🇩🇰',
    'الدنمارك': '🇩🇰',
    'finland': '🇫🇮',
    'فنلندا': '🇫🇮',
    'poland': '🇵🇱',
    'بولندا': '🇵🇱',
    'ireland': '🇮🇪',
    'أيرلندا': '🇮🇪',
    'czech republic': '🇨🇿',
    'czechia': '🇨🇿',
    'التشيك': '🇨🇿',
    'hungary': '🇭🇺',
    'المجر': '🇭🇺',
    'romania': '🇷🇴',
    'رومانيا': '🇷🇴',
    'bulgaria': '🇧🇬',
    'بلغاريا': '🇧🇬',
    'croatia': '🇭🇷',
    'كرواتيا': '🇭🇷',
    'cyprus': '🇨🇾',
    'قبرص': '🇨🇾',
    'turkey': '🇹🇷',
    'türkiye': '🇹🇷',
    'تركيا': '🇹🇷',
    'russia': '🇷🇺',
    'روسيا': '🇷🇺',

    // Americas
    'usa': '🇺🇸',
    'united states': '🇺🇸',
    'united states of america': '🇺🇸',
    'أمريكا': '🇺🇸',
    'الولايات المتحدة': '🇺🇸',
    'الولايات المتحدة الأمريكية': '🇺🇸',
    'canada': '🇨🇦',
    'كندا': '🇨🇦',
    'brazil': '🇧🇷',
    'البرازيل': '🇧🇷',
    'argentina': '🇦🇷',
    'الأرجنتين': '🇦🇷',
    'mexico': '🇲🇽',
    'المكسيك': '🇲🇽',

    // Middle East & Arab World
    'saudi arabia': '🇸🇦',
    'ksa': '🇸🇦',
    'السعودية': '🇸🇦',
    'المملكة العربية السعودية': '🇸🇦',
    'united arab emirates': '🇦🇪',
    'uae': '🇦🇪',
    'dubai': '🇦🇪',
    'الإمارات': '🇦🇪',
    'الإمارات العربية المتحدة': '🇦🇪',
    'دبي': '🇦🇪',
    'egypt': '🇪🇬',
    'مصر': '🇪🇬',
    'qatar': '🇶🇦',
    'قطر': '🇶🇦',
    'kuwait': '🇰🇼',
    'الكويت': '🇰🇼',
    'oman': '🇴🇲',
    'عمان': '🇴🇲',
    'سلطنة عمان': '🇴🇲',
    'bahrain': '🇧🇭',
    'البحرين': '🇧🇭',
    'jordan': '🇯🇴',
    'الأردن': '🇯🇴',
    'lebanon': '🇱🇧',
    'لبنان': '🇱🇧',
    'morocco': '🇲🇦',
    'المغرب': '🇲🇦',
    'tunisia': '🇹🇳',
    'تونس': '🇹🇳',
    'algeria': '🇩🇿',
    'الجزائر': '🇩🇿',

    // Asia & Oceania
    'japan': '🇯🇵',
    'اليابان': '🇯🇵',
    'china': '🇨🇳',
    'الصين': '🇨🇳',
    'south korea': '🇰🇷',
    'korea': '🇰🇷',
    'كوريا الجنوبية': '🇰🇷',
    'singapore': '🇸🇬',
    'سنغافورة': '🇸🇬',
    'malaysia': '🇲🇾',
    'ماليزيا': '🇲🇾',
    'thailand': '🇹🇭',
    'تايلاند': '🇹🇭',
    'indonesia': '🇮🇩',
    'إندونيسيا': '🇮🇩',
    'bali': '🇮🇩',
    'بالي': '🇮🇩',
    'india': '🇮🇳',
    'الهند': '🇮🇳',
    'australia': '🇦🇺',
    'أستراليا': '🇦🇺',
    'new zealand': '🇳🇿',
    'نيوزيلندا': '🇳🇿',
    'vietnam': '🇻🇳',
    'فيتنام': '🇻🇳',
    'philippines': '🇵🇭',
    'الفلبين': '🇵🇭',
    'maldives': '🇲🇻',
    'جزر المالديف': '🇲🇻',
    'المالديف': '🇲🇻',
    'georgia': '🇬🇪',
    'جورجيا': '🇬🇪',
    'azerbaijan': '🇦🇿',
    'أذربيجان': '🇦🇿',
    'armenia': '🇦🇲',
    'أرمينيا': '🇦🇲',
    'south africa': '🇿🇦',
    'جنوب أفريقيا': '🇿🇦',
  };

  /// Returns the country flag emoji for a given country name or fallback
  static String getFlag(String countryName, [String? currentFlag]) {
    if (currentFlag != null &&
        currentFlag.trim().isNotEmpty &&
        currentFlag.trim() != '✈️' &&
        currentFlag.trim() != '🌐' &&
        currentFlag.trim() != '📄') {
      return currentFlag.trim();
    }

    final clean = countryName.toLowerCase().trim();
    if (_countryFlagMap.containsKey(clean)) {
      return _countryFlagMap[clean]!;
    }

    for (final entry in _countryFlagMap.entries) {
      if (clean.contains(entry.key) || entry.key.contains(clean)) {
        return entry.value;
      }
    }

    return '🏳️'; // Default country flag representation
  }
}

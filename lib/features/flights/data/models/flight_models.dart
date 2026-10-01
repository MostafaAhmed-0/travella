import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Supported Trip Types
enum TripType {
  roundTrip,
  oneWay,
}

/// Flight Stops Filter
enum FlightStopsFilter {
  any,
  nonStop,
  oneStop,
  twoPlusStops,
}

/// Flight Time Slots (for departure & arrival time filters)
enum FlightTimeSlot {
  any,
  earlyMorning, // 00:00 - 06:00
  morning,      // 06:00 - 12:00
  afternoon,    // 12:00 - 18:00
  evening,      // 18:00 - 24:00
}

/// Model holding flight search parameters
class FlightSearchQuery {
  final String origin;
  final String destination;
  final DateTime departureDate;
  final DateTime? returnDate;
  final TripType tripType;
  final int adults;
  final int children;
  final List<int> childAges;
  final String cabinClass;

  const FlightSearchQuery({
    required this.origin,
    required this.destination,
    required this.departureDate,
    this.returnDate,
    this.tripType = TripType.roundTrip,
    this.adults = 2,
    this.children = 0,
    this.childAges = const [],
    this.cabinClass = 'Economy',
  });

  bool get isRoundTrip => tripType == TripType.roundTrip;
  bool get isOneWay => tripType == TripType.oneWay;
  int get totalTravelers => adults + children;

  FlightSearchQuery copyWith({
    String? origin,
    String? destination,
    DateTime? departureDate,
    DateTime? returnDate,
    TripType? tripType,
    int? adults,
    int? children,
    List<int>? childAges,
    String? cabinClass,
  }) {
    return FlightSearchQuery(
      origin: origin ?? this.origin,
      destination: destination ?? this.destination,
      departureDate: departureDate ?? this.departureDate,
      returnDate: tripType == TripType.oneWay ? null : (returnDate ?? this.returnDate),
      tripType: tripType ?? this.tripType,
      adults: adults ?? this.adults,
      children: children ?? this.children,
      childAges: childAges ?? this.childAges,
      cabinClass: cabinClass ?? this.cabinClass,
    );
  }

  factory FlightSearchQuery.defaultQuery() {
    final now = DateTime.now();
    return FlightSearchQuery(
      origin: 'Cairo (CAI)',
      destination: 'Istanbul (IST)',
      departureDate: now.add(const Duration(days: 14)),
      returnDate: now.add(const Duration(days: 21)),
      tripType: TripType.roundTrip,
      adults: 2,
      children: 0,
      childAges: const [],
      cabinClass: 'Economy',
    );
  }

  factory FlightSearchQuery.fromUri(Uri uri) {
    final query = uri.queryParameters;
    final now = DateTime.now().add(const Duration(days: 14));
    final dep = query['departure'] != null
        ? DateTime.tryParse(query['departure']!) ?? now
        : now;
    final ret = query['return'] != null
        ? DateTime.tryParse(query['return']!)
        : now.add(const Duration(days: 7));

    final isRound = (query['roundTrip'] ?? 'true') == 'true';
    final tripType = isRound ? TripType.roundTrip : TripType.oneWay;

    final childAgesRaw = query['childAges'];
    List<int> parsedAges = [];
    if (childAgesRaw != null && childAgesRaw.isNotEmpty) {
      parsedAges = childAgesRaw
          .split(',')
          .map((e) => int.tryParse(e.trim()) ?? 6)
          .toList();
    }

    return FlightSearchQuery(
      origin: query['from'] ?? query['origin'] ?? 'Cairo (CAI)',
      destination: query['to'] ?? query['destination'] ?? 'Istanbul (IST)',
      departureDate: dep,
      returnDate: isRound ? ret : null,
      tripType: tripType,
      adults: int.tryParse(query['adults'] ?? '2') ?? 2,
      children: int.tryParse(query['children'] ?? '0') ?? 0,
      childAges: parsedAges,
      cabinClass: query['cabinClass'] ?? 'Economy',
    );
  }

  Map<String, String> toQueryParameters() {
    final depStr = DateFormat('yyyy-MM-dd').format(departureDate);
    final retStr = isRoundTrip && returnDate != null
        ? DateFormat('yyyy-MM-dd').format(returnDate!)
        : '';
    final agesStr = childAges.join(',');

    return {
      'from': origin,
      'destination': destination,
      'departure': depStr,
      if (isRoundTrip && retStr.isNotEmpty) 'return': retStr,
      'roundTrip': isRoundTrip.toString(),
      'adults': adults.toString(),
      'children': children.toString(),
      if (agesStr.isNotEmpty) 'childAges': agesStr,
      'cabinClass': cabinClass,
    };
  }

  String travelersFormattedSummary({bool isArabic = false}) {
    final adultsText = isArabic
        ? '$adults ${adults == 1 ? 'بالغ' : 'بالغين'}'
        : '$adults ${adults == 1 ? 'Adult' : 'Adults'}';

    if (children > 0) {
      final agesStr = childAges.isNotEmpty ? childAges.join(', ') : '';
      final agesSuffix = agesStr.isNotEmpty
          ? (isArabic ? ' (أعمار: $agesStr)' : ' (Ages: $agesStr)')
          : '';
      final kidsText = isArabic
          ? '، $children ${children == 1 ? 'طفل' : 'أطفال'}$agesSuffix'
          : ', $children ${children == 1 ? 'Child' : 'Children'}$agesSuffix';
      return '$adultsText$kidsText';
    }
    return adultsText;
  }
}

/// Filter state options
class FlightFilterState {
  final FlightStopsFilter stops;
  final Set<String> selectedAirlines;
  final FlightTimeSlot departureSlot;
  final FlightTimeSlot arrivalSlot;
  final double maxPrice;
  final double maxDurationHours;
  final String sortBy;

  const FlightFilterState({
    this.stops = FlightStopsFilter.any,
    this.selectedAirlines = const {},
    this.departureSlot = FlightTimeSlot.any,
    this.arrivalSlot = FlightTimeSlot.any,
    this.maxPrice = 2500,
    this.maxDurationHours = 18,
    this.sortBy = 'Recommended',
  });

  bool get hasActiveFilters {
    return stops != FlightStopsFilter.any ||
        selectedAirlines.isNotEmpty ||
        departureSlot != FlightTimeSlot.any ||
        arrivalSlot != FlightTimeSlot.any ||
        maxPrice < 2500 ||
        maxDurationHours < 18 ||
        sortBy != 'Recommended';
  }

  FlightFilterState copyWith({
    FlightStopsFilter? stops,
    Set<String>? selectedAirlines,
    FlightTimeSlot? departureSlot,
    FlightTimeSlot? arrivalSlot,
    double? maxPrice,
    double? maxDurationHours,
    String? sortBy,
  }) {
    return FlightFilterState(
      stops: stops ?? this.stops,
      selectedAirlines: selectedAirlines ?? this.selectedAirlines,
      departureSlot: departureSlot ?? this.departureSlot,
      arrivalSlot: arrivalSlot ?? this.arrivalSlot,
      maxPrice: maxPrice ?? this.maxPrice,
      maxDurationHours: maxDurationHours ?? this.maxDurationHours,
      sortBy: sortBy ?? this.sortBy,
    );
  }

  static const defaultState = FlightFilterState();
}

/// Model representing a verified airline flight offer / schedule consultation card
class FlightOffer {
  final String id;
  final String airlineName;
  final String airlineCode;
  final String flightNumber;
  final String departureAirportCode;
  final String departureAirportName;
  final String departureCity;
  final String departureTime;
  final int departureHour;
  final String arrivalAirportCode;
  final String arrivalAirportName;
  final String arrivalCity;
  final String arrivalTime;
  final int arrivalHour;
  final int durationMinutes;
  final String durationFormatted;
  final int stopsCount;
  final String stopsLabel;
  final double price;
  final String currency;
  final String cabinClass;
  final String baggageAllowance;
  final String aircraft;
  final List<String> tags;
  final bool isRefundable;
  final bool hasWifi;
  final bool hasEntertainment;
  final bool hasMeals;
  final Color brandingPrimaryColor;
  final Color brandingAccentColor;

  const FlightOffer({
    required this.id,
    required this.airlineName,
    required this.airlineCode,
    required this.flightNumber,
    required this.departureAirportCode,
    required this.departureAirportName,
    required this.departureCity,
    required this.departureTime,
    required this.departureHour,
    required this.arrivalAirportCode,
    required this.arrivalAirportName,
    required this.arrivalCity,
    required this.arrivalTime,
    required this.arrivalHour,
    required this.durationMinutes,
    required this.durationFormatted,
    required this.stopsCount,
    required this.stopsLabel,
    required this.price,
    this.currency = 'USD',
    this.cabinClass = 'Economy',
    this.baggageAllowance = '2 x 23kg + 7kg Cabin',
    this.aircraft = 'Boeing 777-300ER',
    this.tags = const [],
    this.isRefundable = true,
    this.hasWifi = true,
    this.hasEntertainment = true,
    this.hasMeals = true,
    this.brandingPrimaryColor = const Color(0xFF0F2236),
    this.brandingAccentColor = const Color(0xFFF5B800),
  });

  bool get isNonStop => stopsCount == 0;
  double get durationHours => durationMinutes / 60.0;
}

/// Helper repository providing verified partner airline route consultation data
class FlightOfferCatalog {
  FlightOfferCatalog._();

  static List<FlightOffer> getOffersForQuery(FlightSearchQuery query) {
    final originCode = _extractCode(query.origin, 'CAI');
    final originCity = _extractCity(query.origin, 'Cairo');
    final destCode = _extractCode(query.destination, 'IST');
    final destCity = _extractCity(query.destination, 'Istanbul');

    // Dynamic curated partner airline options based on route
    return [
      FlightOffer(
        id: 'FL-EK-$originCode-$destCode-01',
        airlineName: 'Emirates',
        airlineCode: 'EK',
        flightNumber: 'EK 924',
        departureAirportCode: originCode,
        departureAirportName: '$originCity International Airport',
        departureCity: originCity,
        departureTime: '08:15 AM',
        departureHour: 8,
        arrivalAirportCode: destCode,
        arrivalAirportName: '$destCity International Airport',
        arrivalCity: destCity,
        arrivalTime: '11:45 AM',
        arrivalHour: 11,
        durationMinutes: 210,
        durationFormatted: '3h 30m',
        stopsCount: 0,
        stopsLabel: 'Non-stop (Direct)',
        price: 420.0,
        currency: 'USD',
        cabinClass: query.cabinClass,
        baggageAllowance: '2 x 23kg Checked + 7kg Cabin',
        aircraft: 'Boeing 777-300ER',
        tags: const ['Travella Choice', 'Direct', 'Gourmet Dining'],
        isRefundable: true,
        hasWifi: true,
        hasEntertainment: true,
        hasMeals: true,
        brandingPrimaryColor: const Color(0xFFD71921),
        brandingAccentColor: const Color(0xFFF5B800),
      ),
      FlightOffer(
        id: 'FL-MS-$originCode-$destCode-02',
        airlineName: 'EgyptAir',
        airlineCode: 'MS',
        flightNumber: 'MS 737',
        departureAirportCode: originCode,
        departureAirportName: '$originCity International Airport',
        departureCity: originCity,
        departureTime: '10:30 AM',
        departureHour: 10,
        arrivalAirportCode: destCode,
        arrivalAirportName: '$destCity International Airport',
        arrivalCity: destCity,
        arrivalTime: '01:50 PM',
        arrivalHour: 13,
        durationMinutes: 200,
        durationFormatted: '3h 20m',
        stopsCount: 0,
        stopsLabel: 'Non-stop (Direct)',
        price: 350.0,
        currency: 'USD',
        cabinClass: query.cabinClass,
        baggageAllowance: '2 x 23kg Checked + 8kg Cabin',
        aircraft: 'Airbus A321neo',
        tags: const ['Best Value', 'Direct', 'Star Alliance'],
        isRefundable: true,
        hasWifi: true,
        hasEntertainment: true,
        hasMeals: true,
        brandingPrimaryColor: const Color(0xFF002B49),
        brandingAccentColor: const Color(0xFFC59B27),
      ),
      FlightOffer(
        id: 'FL-TK-$originCode-$destCode-03',
        airlineName: 'Turkish Airlines',
        airlineCode: 'TK',
        flightNumber: 'TK 693',
        departureAirportCode: originCode,
        departureAirportName: '$originCity International Airport',
        departureCity: originCity,
        departureTime: '02:45 PM',
        departureHour: 14,
        arrivalAirportCode: destCode,
        arrivalAirportName: '$destCity International Airport',
        arrivalCity: destCity,
        arrivalTime: '06:05 PM',
        arrivalHour: 18,
        durationMinutes: 200,
        durationFormatted: '3h 20m',
        stopsCount: 0,
        stopsLabel: 'Non-stop (Direct)',
        price: 390.0,
        currency: 'USD',
        cabinClass: query.cabinClass,
        baggageAllowance: '30kg Total + 8kg Cabin',
        aircraft: 'Airbus A330-300',
        tags: const ['Award Winner', 'Flying Chef', 'Direct'],
        isRefundable: true,
        hasWifi: true,
        hasEntertainment: true,
        hasMeals: true,
        brandingPrimaryColor: const Color(0xFFC8102E),
        brandingAccentColor: const Color(0xFF1E293B),
      ),
      FlightOffer(
        id: 'FL-QR-$originCode-$destCode-04',
        airlineName: 'Qatar Airways',
        airlineCode: 'QR',
        flightNumber: 'QR 1302',
        departureAirportCode: originCode,
        departureAirportName: '$originCity International Airport',
        departureCity: originCity,
        departureTime: '06:20 PM',
        departureHour: 18,
        arrivalAirportCode: destCode,
        arrivalAirportName: '$destCity International Airport',
        arrivalCity: destCity,
        arrivalTime: '11:40 PM',
        arrivalHour: 23,
        durationMinutes: 320,
        durationFormatted: '5h 20m',
        stopsCount: 1,
        stopsLabel: '1 Stop in DOH (1h 10m)',
        price: 460.0,
        currency: 'USD',
        cabinClass: query.cabinClass,
        baggageAllowance: '2 x 23kg Checked + 7kg Cabin',
        aircraft: 'Airbus A350-1000',
        tags: const ['World Best Airline', 'Oryx One', '1 Stop'],
        isRefundable: true,
        hasWifi: true,
        hasEntertainment: true,
        hasMeals: true,
        brandingPrimaryColor: const Color(0xFF5C0632),
        brandingAccentColor: const Color(0xFFF5B800),
      ),
      FlightOffer(
        id: 'FL-SV-$originCode-$destCode-05',
        airlineName: 'Saudia',
        airlineCode: 'SV',
        flightNumber: 'SV 302',
        departureAirportCode: originCode,
        departureAirportName: '$originCity International Airport',
        departureCity: originCity,
        departureTime: '11:15 PM',
        departureHour: 23,
        arrivalAirportCode: destCode,
        arrivalAirportName: '$destCity International Airport',
        arrivalCity: destCity,
        arrivalTime: '05:30 AM',
        arrivalHour: 5,
        durationMinutes: 375,
        durationFormatted: '6h 15m',
        stopsCount: 1,
        stopsLabel: '1 Stop in JED (1h 25m)',
        price: 340.0,
        currency: 'USD',
        cabinClass: query.cabinClass,
        baggageAllowance: '2 x 23kg Checked + 7kg Cabin',
        aircraft: 'Boeing 787-9 Dreamliner',
        tags: const ['Economy Delight', '1 Stop', 'SkyTeam'],
        isRefundable: true,
        hasWifi: true,
        hasEntertainment: true,
        hasMeals: true,
        brandingPrimaryColor: const Color(0xFF006633),
        brandingAccentColor: const Color(0xFFCCA352),
      ),
    ];
  }

  static String _extractCode(String text, String fallback) {
    final match = RegExp(r'\(([A-Z]{3})\)').firstMatch(text);
    if (match != null) {
      return match.group(1)!;
    }
    final words = text.split(RegExp(r'[, -]'));
    if (words.isNotEmpty && words.first.length >= 3) {
      return words.first.substring(0, 3).toUpperCase();
    }
    return fallback;
  }

  static String _extractCity(String text, String fallback) {
    if (text.contains('(')) {
      return text.split('(').first.trim();
    }
    if (text.contains(',')) {
      return text.split(',').first.trim();
    }
    return text.trim().isNotEmpty ? text.trim() : fallback;
  }
}

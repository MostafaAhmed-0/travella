import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/responsive/app_breakpoints.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../../../core/animations/animation_widgets.dart';
import '../../../../core/localization/app_translations.dart';
import '../../../../data/models/hotel_model.dart';
import '../../../../data/repositories/hotel_repository.dart';
import '../../../../shared/presentation/widgets/app_navbar.dart';
import '../../../../shared/presentation/widgets/app_footer.dart';
import '../../../bookings/presentation/cubit/booking_cubit.dart';
import '../../../bookings/presentation/cubit/booking_state.dart';

class HotelsPage extends StatefulWidget {
  final String? initialDestination;
  final String? checkIn;
  final String? checkOut;
  final int? adults;
  final int? children;
  final int? rooms;

  const HotelsPage({
    super.key,
    this.initialDestination,
    this.checkIn,
    this.checkOut,
    this.adults,
    this.children,
    this.rooms,
  });

  @override
  State<HotelsPage> createState() => _HotelsPageState();
}

class _HotelsPageState extends State<HotelsPage> {
  final HotelRepository _repository = HotelRepository();
  List<HotelModel> _allHotels = [];
  List<HotelModel> _filteredHotels = [];
  bool _isLoading = true;
  String? _errorMessage;

  late TextEditingController _searchCtrl;
  String _searchQuery = '';
  String _selectedRating = 'All';
  String _sortBy = 'Recommended';

  final List<String> _ratingFilters = ['All', '5 Stars', '4 Stars', '4.9+ Rated'];
  final List<String> _sortOptions = [
    'Recommended',
    'Price: Low to High',
    'Price: High to Low',
    'Rating',
  ];

  @override
  void initState() {
    super.initState();
    _searchQuery = widget.initialDestination ?? '';
    _searchCtrl = TextEditingController(text: _searchQuery);
    _loadHotels();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadHotels() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final list = await _repository.getAllHotels(activeOnly: true);
      if (mounted) {
        setState(() {
          _allHotels = list;
          _isLoading = false;
          _applyFilters();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  void _applyFilters() {
    var result = List<HotelModel>.from(_allHotels);

    if (_selectedRating == '5 Stars') {
      result = result.where((h) => h.stars == 5).toList();
    } else if (_selectedRating == '4 Stars') {
      result = result.where((h) => h.stars == 4).toList();
    } else if (_selectedRating == '4.9+ Rated') {
      result = result.where((h) => h.rating >= 4.9).toList();
    }

    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.toLowerCase().trim();
      result = result.where((h) =>
          h.name.toLowerCase().contains(q) ||
          (h.nameAr != null && h.nameAr!.toLowerCase().contains(q)) ||
          h.location.toLowerCase().contains(q) ||
          h.city.toLowerCase().contains(q) ||
          h.country.toLowerCase().contains(q) ||
          h.description.toLowerCase().contains(q)).toList();
    }

    if (_sortBy == 'Price: Low to High') {
      result.sort((a, b) => a.price.compareTo(b.price));
    } else if (_sortBy == 'Price: High to Low') {
      result.sort((a, b) => b.price.compareTo(a.price));
    } else if (_sortBy == 'Rating') {
      result.sort((a, b) => b.rating.compareTo(a.rating));
    }

    setState(() {
      _filteredHotels = result;
    });
  }

  void _openBookingDialog(HotelModel hotel) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _HotelBookingModal(
        hotel: hotel,
        initialCheckIn: widget.checkIn,
        initialCheckOut: widget.checkOut,
        initialAdults: widget.adults ?? 2,
        initialChildren: widget.children ?? 0,
        initialRooms: widget.rooms ?? 1,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hPad = AppBreakpoints.horizontalPadding(context);
    final isMobile = AppBreakpoints.isMobile(context);
    final isArabic = context.isArabic;
    final columns = isMobile ? 1 : 2;

    return Scaffold(
      backgroundColor: AppColors.surfaceLight,
      body: CustomScrollView(
        slivers: [
          // ── Navbar ────────────────────────────────────────────────────────
          const SliverToBoxAdapter(
            child: AppNavbar(currentRoute: AppRoutes.hotels),
          ),

          // ── Header Banner ────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              color: AppColors.navyDark,
              padding: EdgeInsets.symmetric(
                horizontal: hPad,
                vertical: isMobile ? 48 : 72,
              ),
              child: MaxWidthContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.gold.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.hotel_rounded, color: AppColors.gold, size: 14),
                          const SizedBox(width: 6),
                          Text(
                            isArabic ? 'إقامات ومنتجعات فاخرة' : 'LUXURY ACCOMMODATIONS',
                            style: const TextStyle(
                              color: AppColors.gold,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      isArabic ? 'أفخم الفنادق والمنتجعات العالمية' : 'Luxury Hotels & Resorts',
                      style: (isMobile ? AppTextStyles.h2 : AppTextStyles.h1).copyWith(
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      isArabic
                          ? 'باقة مختارة بعناية من أرقى المنتجعات الشاطئية والفلل المائية وقصور الضيافة التاريخية حول العالم.'
                          : 'Handpicked 5-star beachfront resorts, overwater villas, and historic palace sanctuaries verified by Travella.',
                      style: AppTextStyles.bodyLG.copyWith(
                        color: AppColors.textOnDarkMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Search & Filter Bar ──────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              color: AppColors.white,
              padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 20),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.borderLight)),
              ),
              child: MaxWidthContainer(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchCtrl,
                            onChanged: (val) {
                              _searchQuery = val;
                              _applyFilters();
                            },
                            decoration: InputDecoration(
                              hintText: isArabic
                                  ? 'ابحث عن فندق باسمه، المدينة، أو الوجهة...'
                                  : 'Search hotels by name, city, or destination...',
                              prefixIcon: const Icon(Icons.search, color: AppColors.royalBlue),
                              suffixIcon: _searchQuery.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear_rounded, size: 18),
                                      onPressed: () {
                                        _searchCtrl.clear();
                                        _searchQuery = '';
                                        _applyFilters();
                                      },
                                    )
                                  : null,
                              filled: true,
                              fillColor: AppColors.surfaceLight,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: AppColors.borderLight),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: AppColors.borderLight),
                              ),
                            ),
                          ),
                        ),
                        if (!isMobile) ...[
                          const SizedBox(width: 16),
                          DropdownButtonHideUnderline(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceLight,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.borderLight),
                              ),
                              child: DropdownButton<String>(
                                value: _sortBy,
                                icon: const Icon(Icons.sort_rounded, color: AppColors.royalBlue),
                                items: _sortOptions.map((s) {
                                  return DropdownMenuItem<String>(
                                    value: s,
                                    child: Text(s, style: AppTextStyles.labelMD),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() => _sortBy = val);
                                    _applyFilters();
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 14),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _ratingFilters.map((r) {
                          final isSel = _selectedRating == r;
                          return Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: FilterChip(
                              label: Text(r),
                              selected: isSel,
                              onSelected: (_) {
                                setState(() => _selectedRating = r);
                                _applyFilters();
                              },
                              selectedColor: AppColors.navy,
                              checkmarkColor: AppColors.white,
                              labelStyle: TextStyle(
                                color: isSel ? AppColors.white : AppColors.navyDark,
                                fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                              ),
                              backgroundColor: AppColors.surfaceLight,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100),
                                side: BorderSide(
                                  color: isSel ? AppColors.navy : AppColors.borderLight,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Content ───────────────────────────────────────────────────────
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 40),
            sliver: SliverToBoxAdapter(
              child: MaxWidthContainer(
                child: _buildContent(columns, isMobile, isArabic),
              ),
            ),
          ),

          // ── Footer ────────────────────────────────────────────────────────
          const SliverToBoxAdapter(
            child: AppFooter(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(int columns, bool isMobile, bool isArabic) {
    if (_isLoading) {
      return SizedBox(
        height: 400,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: AppColors.royalBlue),
              const SizedBox(height: 16),
              Text(
                isArabic ? 'جاري تحميل الفنادق من الخادم...' : 'Loading luxury hotels from Supabase...',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return SizedBox(
        height: 360,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded, color: AppColors.errorRed, size: 54),
              const SizedBox(height: 14),
              Text(
                isArabic ? 'فشل تحميل بيانات الفنادق' : 'Failed to load hotels',
                style: AppTextStyles.h4,
              ),
              const SizedBox(height: 8),
              Text(_errorMessage!, style: const TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 20),
              TravellaButton(
                label: isArabic ? 'إعادة المحاولة' : 'Retry',
                variant: TravellaButtonVariant.primary,
                onPressed: _loadHotels,
              ),
            ],
          ),
        ),
      );
    }

    if (_filteredHotels.isEmpty) {
      return SizedBox(
        height: 360,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.hotel_rounded, color: AppColors.gray400, size: 56),
              const SizedBox(height: 16),
              Text(
                isArabic ? 'لا توجد فنادق مطابقة للبحث' : 'No hotels found matching your search.',
                style: AppTextStyles.h4,
              ),
              const SizedBox(height: 8),
              Text(
                isArabic ? 'جرّب تعديل مصطلح البحث أو إزالة الفلاتر' : 'Try adjusting your destination keyword or resetting rating filters.',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 20),
              TravellaButton(
                label: isArabic ? 'إعادة ضبط الفلاتر' : 'Reset Filters',
                variant: TravellaButtonVariant.secondary,
                onPressed: () {
                  _searchCtrl.clear();
                  setState(() {
                    _searchQuery = '';
                    _selectedRating = 'All';
                    _sortBy = 'Recommended';
                  });
                  _applyFilters();
                },
              ),
            ],
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        mainAxisExtent: isMobile ? 540 : 380,
        crossAxisSpacing: 24,
        mainAxisSpacing: 24,
      ),
      itemCount: _filteredHotels.length,
      itemBuilder: (context, i) {
        final hotel = _filteredHotels[i];
        return ScaleInOnScroll(
          delay: Duration(milliseconds: (i % 2) * 80),
          child: _HotelGridCard(
            hotel: hotel,
            isMobile: isMobile,
            onBook: () => _openBookingDialog(hotel),
          ),
        );
      },
    );
  }
}

class _HotelGridCard extends StatefulWidget {
  final HotelModel hotel;
  final bool isMobile;
  final VoidCallback onBook;

  const _HotelGridCard({
    required this.hotel,
    required this.isMobile,
    required this.onBook,
  });

  @override
  State<_HotelGridCard> createState() => _HotelGridCardState();
}

class _HotelGridCardState extends State<_HotelGridCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final hotel = widget.hotel;
    final isArabic = context.isArabic;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(0.0, _isHovered ? -6.0 : 0.0, 0.0),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _isHovered ? AppColors.gold : AppColors.borderLight,
            width: _isHovered ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: _isHovered
                  ? AppColors.navy.withValues(alpha: 0.12)
                  : AppColors.navy.withValues(alpha: 0.04),
              blurRadius: _isHovered ? 28 : 14,
              offset: Offset(0, _isHovered ? 12 : 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: widget.isMobile
              ? Column(
                  children: [
                    _buildImageSection(hotel),
                    Expanded(child: _buildInfoSection(hotel, isArabic)),
                  ],
                )
              : Row(
                  children: [
                    Expanded(flex: 5, child: _buildImageSection(hotel)),
                    Expanded(flex: 6, child: _buildInfoSection(hotel, isArabic)),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildImageSection(HotelModel hotel) {
    return SizedBox(
      height: widget.isMobile ? 220 : double.infinity,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          AnimatedScale(
            scale: _isHovered ? 1.06 : 1.0,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutCubic,
            child: Image.network(
              hotel.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: AppColors.navyMedium,
                child: const Icon(Icons.hotel_rounded, color: AppColors.gray400, size: 48),
              ),
            ),
          ),
          if (hotel.badge != null)
            Positioned(
              top: 14,
              left: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.gold,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 2)),
                  ],
                ),
                child: Text(
                  hotel.badge!,
                  style: AppTextStyles.labelSM.copyWith(
                    color: AppColors.navyDark,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(HotelModel hotel, bool isArabic) {
    final displayName = hotel.localizedName(isArabic);

    return Padding(
      padding: EdgeInsets.all(widget.isMobile ? 16 : 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.place_rounded, size: 14, color: AppColors.royalBlue),
                  const SizedBox(width: 4),
                  Text(
                    '${hotel.city}, ${hotel.country}',
                    style: AppTextStyles.labelSM.copyWith(
                      color: AppColors.royalBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              RatingStars(rating: hotel.rating, size: 14),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            displayName,
            style: AppTextStyles.h4.copyWith(color: AppColors.navyDark),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            hotel.roomType,
            style: AppTextStyles.bodySM.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: hotel.amenities.take(3).map((amenity) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  amenity,
                  style: AppTextStyles.labelSM.copyWith(
                    fontSize: 11,
                    color: AppColors.textPrimary,
                  ),
                ),
              );
            }).toList(),
          ),
          const Spacer(),
          const Divider(color: AppColors.borderLight, height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isArabic ? 'ابتداءً من' : 'STARTING FROM',
                    style: AppTextStyles.overline.copyWith(
                      color: AppColors.textLightMuted,
                      fontSize: 9,
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '${hotel.currency} ${hotel.price.toInt()}',
                        style: AppTextStyles.h4.copyWith(
                          color: AppColors.royalBlueDark,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        isArabic ? ' / ليلة' : ' / night',
                        style: AppTextStyles.bodySM.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: widget.onBook,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isHovered ? AppColors.gold : AppColors.navy,
                  foregroundColor: _isHovered ? AppColors.navyDark : AppColors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
                child: Text(
                  isArabic ? 'حجز الغرفة' : 'Book Room',
                  style: AppTextStyles.labelMD.copyWith(
                    color: _isHovered ? AppColors.navyDark : AppColors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Interactive Hotel Booking & Consultation Dialog that submits to Supabase
class _HotelBookingModal extends StatefulWidget {
  final HotelModel hotel;
  final String? initialCheckIn;
  final String? initialCheckOut;
  final int initialAdults;
  final int initialChildren;
  final int initialRooms;

  const _HotelBookingModal({
    required this.hotel,
    this.initialCheckIn,
    this.initialCheckOut,
    required this.initialAdults,
    required this.initialChildren,
    required this.initialRooms,
  });

  @override
  State<_HotelBookingModal> createState() => _HotelBookingModalState();
}

class _HotelBookingModalState extends State<_HotelBookingModal> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  late DateTime _checkIn;
  late DateTime _checkOut;
  late int _adults;
  late int _children;
  late int _rooms;
  bool _isSubmitting = false;
  String? _bookingRef;

  final DateFormat _dateFormat = DateFormat('dd MMM yyyy');

  @override
  void initState() {
    super.initState();
    _adults = widget.initialAdults;
    _children = widget.initialChildren;
    _rooms = widget.initialRooms;

    final now = DateTime.now().add(const Duration(days: 7));
    _checkIn = widget.initialCheckIn != null
        ? DateTime.tryParse(widget.initialCheckIn!) ?? now
        : now;
    _checkOut = widget.initialCheckOut != null
        ? DateTime.tryParse(widget.initialCheckOut!) ?? _checkIn.add(const Duration(days: 5))
        : _checkIn.add(const Duration(days: 5));
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _submitHotelBooking() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final nights = _checkOut.difference(_checkIn).inDays.clamp(1, 365);
    final totalEstimate = widget.hotel.price * nights * _rooms;

    final structuredNotes = StringBuffer()
      ..writeln('=== HOTEL RESERVATION REQUEST ===')
      ..writeln('Hotel: ${widget.hotel.name}')
      ..writeln('Location: ${widget.hotel.location}')
      ..writeln('Room Type: ${widget.hotel.roomType}')
      ..writeln('Check-in: ${_dateFormat.format(_checkIn)}')
      ..writeln('Check-out: ${_dateFormat.format(_checkOut)} ($nights Nights)')
      ..writeln('Guests: $_adults Adults, $_children Children')
      ..writeln('Rooms: $_rooms Room(s)')
      ..writeln('Estimated Total: ${widget.hotel.currency} $totalEstimate');

    if (_notesCtrl.text.trim().isNotEmpty) {
      structuredNotes.writeln('Special Requests: ${_notesCtrl.text.trim()}');
    }

    final bookingCubit = context.read<BookingCubit>();
    final success = await bookingCubit.submitBooking(
      customerName: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      travelDate: _checkIn,
      travelers: _adults + _children,
      notes: structuredNotes.toString(),
    );

    if (mounted) {
      setState(() {
        _isSubmitting = false;
        if (success) {
          final state = bookingCubit.state;
          if (state is BookingSubmittedSuccess) {
            _bookingRef = state.booking.bookingReference;
          } else {
            _bookingRef = 'HT-${DateTime.now().millisecondsSinceEpoch.toRadixString(16).toUpperCase()}';
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = context.isArabic;
    final nights = _checkOut.difference(_checkIn).inDays.clamp(1, 365);

    if (_bookingRef != null) {
      return AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_rounded, color: AppColors.successGreen, size: 56),
            const SizedBox(height: 16),
            Text(
              isArabic ? 'تم تأكيد طلب حجز الفندق!' : 'Hotel Reservation Submitted!',
              style: AppTextStyles.h4.copyWith(color: AppColors.navyDark),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              isArabic ? 'رقم مرجع الحجز الخاص بك:' : 'Your reservation reference number:',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.gold),
              ),
              child: Text(
                _bookingRef!,
                style: AppTextStyles.labelLG.copyWith(
                  color: AppColors.royalBlueDark,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isArabic
                  ? 'سيتواصل معك مدير حجز الفنادق لتأكيد الغرفة وإرسال قسيمة الفندق الإلكترونية.'
                  : 'A Travella concierge specialist will confirm room availability and issue your hotel voucher.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ],
        ),
        actions: [
          TravellaButton(
            label: isArabic ? 'إغلاق' : 'Close',
            variant: TravellaButtonVariant.primary,
            fullWidth: true,
            onPressed: () => Navigator.pop(context),
          ),
        ],
      );
    }

    return AlertDialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.royalBlueFaded,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.hotel_rounded, color: AppColors.royalBlue, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.hotel.localizedName(isArabic),
                  style: AppTextStyles.h5.copyWith(color: AppColors.navyDark),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${widget.hotel.city}, ${widget.hotel.country} • ${widget.hotel.currency} ${widget.hotel.price.toInt()}/night',
                  style: AppTextStyles.bodySM.copyWith(color: AppColors.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      content: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Dates & Guests summary
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(isArabic ? 'تاريخ الوصول' : 'Check-in', style: const TextStyle(fontSize: 11, color: AppColors.textLightMuted)),
                          Text(_dateFormat.format(_checkIn), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        ],
                      ),
                      const Icon(Icons.arrow_forward_rounded, color: AppColors.gold, size: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(isArabic ? 'تاريخ المغادرة' : 'Check-out', style: const TextStyle(fontSize: 11, color: AppColors.textLightMuted)),
                          Text(_dateFormat.format(_checkOut), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.royalBlueFaded,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '$nights ${isArabic ? 'ليالٍ' : 'Nights'}',
                          style: const TextStyle(color: AppColors.royalBlue, fontWeight: FontWeight.bold, fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Contact Fields
                TextFormField(
                  controller: _nameCtrl,
                  decoration: InputDecoration(
                    labelText: isArabic ? 'الاسم الكامل *' : 'Full Name *',
                    prefixIcon: const Icon(Icons.person_outline_rounded),
                    filled: true,
                    fillColor: AppColors.surfaceLight,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty
                      ? (isArabic ? 'الاسم مطلوب' : 'Name is required')
                      : null,
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: isArabic ? 'البريد *' : 'Email *',
                          prefixIcon: const Icon(Icons.email_outlined),
                          filled: true,
                          fillColor: AppColors.surfaceLight,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        validator: (v) => v == null || !v.contains('@')
                            ? (isArabic ? 'بريد غير صالح' : 'Valid email required')
                            : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _phoneCtrl,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: isArabic ? 'الهاتف *' : 'Phone *',
                          prefixIcon: const Icon(Icons.phone_outlined),
                          filled: true,
                          fillColor: AppColors.surfaceLight,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        validator: (v) => v == null || v.trim().length < 7
                            ? (isArabic ? 'هاتف غير صالح' : 'Valid phone required')
                            : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _notesCtrl,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: isArabic ? 'ملاحظات أو طلبات خاصة' : 'Special Room Requests',
                    hintText: isArabic
                        ? 'مثال: سرير إضافي، إطلالة على البحر، وصول متأخر...'
                        : 'e.g. King bed, sea view, late check-in...',
                    filled: true,
                    fillColor: AppColors.surfaceLight,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(isArabic ? 'إلغاء' : 'Cancel', style: const TextStyle(color: AppColors.gray600)),
        ),
        TravellaButton(
          label: isArabic ? 'تأكيد طلب الحجز' : 'Request Reservation',
          variant: TravellaButtonVariant.gold,
          isLoading: _isSubmitting,
          onPressed: _submitHotelBooking,
        ),
      ],
    );
  }
}

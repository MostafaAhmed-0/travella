import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/common_widgets.dart';
import '../localization/app_translations.dart';

/// Immutable model holding travelers and rooms configuration
class TravelerSelection {
  final int adults;
  final int children;
  final List<int> childAges;
  final int rooms;

  const TravelerSelection({
    this.adults = 2,
    this.children = 0,
    this.childAges = const [],
    this.rooms = 1,
  });

  int get totalTravelers => adults + children;

  String formattedSummary({bool isArabic = false, bool includeRooms = false}) {
    final adultsText = isArabic
        ? '$adults ${adults == 1 ? 'بالغ' : 'بالغين'}'
        : '$adults ${adults == 1 ? 'Adult' : 'Adults'}';

    String kidsText = '';
    if (children > 0) {
      if (childAges.isNotEmpty) {
        final agesStr = childAges.join(', ');
        kidsText = isArabic
            ? '، $children ${children == 1 ? 'طفل' : 'أطفال'} ($agesStr سنوات)'
            : ', $children ${children == 1 ? 'Child' : 'Children'} (Ages: $agesStr)';
      } else {
        kidsText = isArabic
            ? '، $children ${children == 1 ? 'طفل' : 'أطفال'}'
            : ', $children ${children == 1 ? 'Child' : 'Children'}';
      }
    }

    final roomsText = includeRooms
        ? (isArabic
            ? '، $rooms ${rooms == 1 ? 'غرفة' : 'غرف'}'
            : ', $rooms ${rooms == 1 ? 'Room' : 'Rooms'}')
        : '';

    return '$adultsText$kidsText$roomsText';
  }

  TravelerSelection copyWith({
    int? adults,
    int? children,
    List<int>? childAges,
    int? rooms,
  }) {
    return TravelerSelection(
      adults: adults ?? this.adults,
      children: children ?? this.children,
      childAges: childAges ?? this.childAges,
      rooms: rooms ?? this.rooms,
    );
  }
}

/// Modal bottom sheet for configuring travelers, child ages, and rooms
Future<TravelerSelection?> showTravelerSelectorModal(
  BuildContext context, {
  required TravelerSelection initial,
  bool showRooms = false,
  String? title,
}) async {
  return showModalBottomSheet<TravelerSelection>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (ctx) => _TravelerSelectorSheet(
      initial: initial,
      showRooms: showRooms,
      title: title,
    ),
  );
}

class _TravelerSelectorSheet extends StatefulWidget {
  final TravelerSelection initial;
  final bool showRooms;
  final String? title;

  const _TravelerSelectorSheet({
    required this.initial,
    required this.showRooms,
    this.title,
  });

  @override
  State<_TravelerSelectorSheet> createState() => _TravelerSelectorSheetState();
}

class _TravelerSelectorSheetState extends State<_TravelerSelectorSheet> {
  late int _adults;
  late int _children;
  late List<int> _childAges;
  late int _rooms;

  @override
  void initState() {
    super.initState();
    _adults = widget.initial.adults.clamp(1, 12);
    _children = widget.initial.children.clamp(0, 8);
    _rooms = widget.initial.rooms.clamp(1, 10);

    _childAges = List<int>.from(widget.initial.childAges);
    _syncChildAgesList();
  }

  void _syncChildAgesList() {
    if (_childAges.length < _children) {
      final diff = _children - _childAges.length;
      for (int i = 0; i < diff; i++) {
        _childAges.add(6); // Default 6 years old
      }
    } else if (_childAges.length > _children) {
      _childAges = _childAges.take(_children).toList();
    }
  }

  void _updateChildrenCount(int count) {
    final clamped = count.clamp(0, 8);
    setState(() {
      _children = clamped;
      _syncChildAgesList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = context.isArabic;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      margin: EdgeInsets.only(bottom: bottomInset),
      decoration: const BoxDecoration(
        color: AppColors.navyMedium,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 30,
            offset: Offset(0, -10),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.title ??
                        (isArabic ? 'تحديد المسافرين والغرف' : 'Select Travelers & Rooms'),
                    style: AppTextStyles.h4.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppColors.gray400),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Adults Row
              _buildCounterCard(
                title: isArabic ? 'بالغين' : 'Adults',
                subtitle: isArabic ? 'العمر 12 سنة فأكثر' : 'Ages 12 and above',
                icon: Icons.person_rounded,
                count: _adults,
                min: 1,
                max: 12,
                onChanged: (v) => setState(() => _adults = v),
              ),
              const SizedBox(height: 12),

              // Children Row
              _buildCounterCard(
                title: isArabic ? 'أطفال' : 'Children',
                subtitle: isArabic ? 'العمر 0 - 11 سنة' : 'Ages 0 to 11 years',
                icon: Icons.child_care_rounded,
                count: _children,
                min: 0,
                max: 8,
                onChanged: _updateChildrenCount,
              ),

              // Child Ages Section (Dynamically shown when Children > 0)
              if (_children > 0) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.navyDark.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.gold.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.cake_rounded, color: AppColors.gold, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            isArabic ? 'أعمار الأطفال (مطلوبة)' : 'Child Ages (Required)',
                            style: AppTextStyles.labelMD.copyWith(
                              color: AppColors.goldLight,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isArabic
                            ? 'يرجى تحديد عمر كل طفل للحصول على أسعار وحجوزات دقيقة'
                            : 'Specify each child’s age for accurate pricing and ticketing',
                        style: AppTextStyles.bodySM.copyWith(
                          color: AppColors.textOnDarkMuted,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...List.generate(_children, (index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                isArabic
                                    ? 'الطفل ${index + 1}'
                                    : 'Child ${index + 1}',
                                style: AppTextStyles.labelMD.copyWith(
                                  color: AppColors.white,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.navyMedium,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: AppColors.white.withValues(alpha: 0.15),
                                  ),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<int>(
                                    value: _childAges[index],
                                    dropdownColor: AppColors.navyDark,
                                    icon: const Icon(Icons.arrow_drop_down_rounded, color: AppColors.gold),
                                    style: AppTextStyles.labelMD.copyWith(
                                      color: AppColors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    items: List.generate(18, (age) {
                                      final ageLabel = age == 0
                                          ? (isArabic ? 'أقل من سنة' : '< 1 year')
                                          : (isArabic ? '$age سنوات' : '$age years');
                                      return DropdownMenuItem<int>(
                                        value: age,
                                        child: Text(ageLabel),
                                      );
                                    }),
                                    onChanged: (newAge) {
                                      if (newAge != null) {
                                        setState(() {
                                          _childAges[index] = newAge;
                                        });
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],

              // Rooms Row (if applicable)
              if (widget.showRooms) ...[
                const SizedBox(height: 12),
                _buildCounterCard(
                  title: isArabic ? 'الغرف' : 'Rooms',
                  subtitle: isArabic ? 'عدد الغرف المطلوبة' : 'Number of hotel rooms',
                  icon: Icons.meeting_room_rounded,
                  count: _rooms,
                  min: 1,
                  max: 10,
                  onChanged: (v) => setState(() => _rooms = v),
                ),
              ],

              const SizedBox(height: 24),

              // Done Button
              TravellaButton(
                label: isArabic ? 'تأكيد الاختيار' : 'Done',
                variant: TravellaButtonVariant.gold,
                size: TravellaButtonSize.lg,
                fullWidth: true,
                onPressed: () {
                  Navigator.pop(
                    context,
                    TravelerSelection(
                      adults: _adults,
                      children: _children,
                      childAges: _childAges,
                      rooms: _rooms,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCounterCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required int count,
    required int min,
    required int max,
    required ValueChanged<int> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.navyDark.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.royalBlue.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppColors.gold, size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.labelLG.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySM.copyWith(
                      color: AppColors.textOnDarkMuted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              _CounterButton(
                icon: Icons.remove_rounded,
                enabled: count > min,
                onTap: () => onChanged(count - 1),
              ),
              SizedBox(
                width: 38,
                child: Text(
                  '$count',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.h4.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              _CounterButton(
                icon: Icons.add_rounded,
                enabled: count < max,
                onTap: () => onChanged(count + 1),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CounterButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const _CounterButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(100),
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: enabled
                ? AppColors.royalBlue.withValues(alpha: 0.4)
                : AppColors.white.withValues(alpha: 0.05),
            shape: BoxShape.circle,
            border: Border.all(
              color: enabled
                  ? AppColors.gold.withValues(alpha: 0.5)
                  : AppColors.white.withValues(alpha: 0.1),
            ),
          ),
          child: Icon(
            icon,
            size: 18,
            color: enabled ? AppColors.goldLight : AppColors.textOnDarkMuted.withValues(alpha: 0.3),
          ),
        ),
      ),
    );
  }
}

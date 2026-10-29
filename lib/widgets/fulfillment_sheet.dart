import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_strings.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/store_geo.dart';
import '../cubits/home/home_state.dart';
import '../data/mock/product_mock_data.dart';
import '../data/models/store_model.dart';
import 'store_mini_map.dart';

Future<({FulfillmentMode mode, StoreModel store})?> showFulfillmentSheet({
  required BuildContext context,
  required FulfillmentMode initialMode,
  required StoreModel initialStore,
}) {
  return showModalBottomSheet<({FulfillmentMode mode, StoreModel store})>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: AppColors.dark.withOpacity(0.35),
    builder: (context) {
      return _FulfillmentSheet(
        initialMode: initialMode,
        initialStore: initialStore,
      );
    },
  );
}

class _FulfillmentSheet extends StatefulWidget {
  const _FulfillmentSheet({
    required this.initialMode,
    required this.initialStore,
  });

  final FulfillmentMode initialMode;
  final StoreModel initialStore;

  @override
  State<_FulfillmentSheet> createState() => _FulfillmentSheetState();
}

class _FulfillmentSheetState extends State<_FulfillmentSheet>
    with SingleTickerProviderStateMixin {
  late StoreModel _store;
  late final AnimationController _enter;
  late double _userLat;
  late double _userLng;
  bool _mapExpanded = false;
  bool _mapReady = false;
  bool _didAutoSelect = false;

  @override
  void initState() {
    super.initState();
    _store = widget.initialStore;
    _userLat = StoreGeo.mockUserLat;
    _userLng = StoreGeo.mockUserLng;
    _enter = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );

    // Defer map mount until the sheet settles, plus a short beat so
    // layout size is stable before the map attaches.
    void markMapReady() {
      if (!mounted || _mapReady) return;
      Future<void>.delayed(const Duration(milliseconds: 120), () {
        if (!mounted || _mapReady) return;
        setState(() => _mapReady = true);
      });
    }

    _enter.addStatusListener((status) {
      if (status == AnimationStatus.completed) markMapReady();
    });
    _enter.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _didAutoSelect) return;
      _didAutoSelect = true;
      _applyRanking(preferNearestOpen: true);
    });
  }

  @override
  void dispose() {
    _enter.dispose();
    super.dispose();
  }

  List<StoreModel> get _ranked => StoreGeo.rankStores(
        stores: ProductMockData.stores,
        userLat: _userLat,
        userLng: _userLng,
        dineInOnly: true,
      );

  void _applyRanking({required bool preferNearestOpen}) {
    final ranked = _ranked;
    if (ranked.isEmpty) return;

    StoreModel next;
    if (preferNearestOpen) {
      next = StoreGeo.nearestOpen(ranked) ?? ranked.first;
    } else {
      next = ranked.firstWhere(
        (s) => s.id == _store.id,
        orElse: () => StoreGeo.nearestOpen(ranked) ?? ranked.first,
      );
    }

    setState(() => _store = next);
  }

  void _selectStore(StoreModel store) {
    if (_store.id == store.id) return;
    HapticFeedback.selectionClick();
    setState(() => _store = store);
  }

  void _confirm() {
    if (!_store.isOpen) return;
    HapticFeedback.lightImpact();
    Navigator.of(context).pop(
      (mode: FulfillmentMode.dineIn, store: _store),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    final ranked = _ranked;
    final nearest = StoreGeo.nearestOpen(ranked) ?? ranked.first;
    final others = ranked.where((s) => s.id != nearest.id).toList();
    final canConfirm = _store.isOpen;

    return AnimatedBuilder(
      animation: _enter,
      builder: (context, child) {
        final t = Curves.easeOutCubic.transform(_enter.value);
        return Transform.translate(
          offset: Offset(0, (1 - t) * 28),
          child: Opacity(opacity: t, child: child),
        );
      },
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.92,
        ),
        margin: const EdgeInsets.fromLTRB(10, 0, 10, 10),
        decoration: BoxDecoration(
          color: AppColors.cream,
          borderRadius: BorderRadius.circular(28),
          boxShadow: AppTheme.softShadow,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.divider,
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppStrings.fulfillmentHow,
                    style: GoogleFonts.nunito(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppStrings.fulfillmentHint,
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.nearestToYou,
                      style: GoogleFonts.nunito(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _NearestHeroCard(
                      store: nearest,
                      selected: _store.id == nearest.id,
                      onTap: () => _selectStore(nearest),
                    ),
                    const SizedBox(height: 14),
                    StoreMiniMap(
                      stores: ranked,
                      selectedStoreId: _store.id,
                      userLat: _userLat,
                      userLng: _userLng,
                      expanded: _mapExpanded,
                      mountMap: _mapReady,
                      onStoreTap: _selectStore,
                      onLocateMe: () {
                        HapticFeedback.selectionClick();
                        setState(() {
                          _userLat = StoreGeo.mockUserLat;
                          _userLng = StoreGeo.mockUserLng;
                        });
                        _applyRanking(preferNearestOpen: true);
                      },
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          HapticFeedback.selectionClick();
                          setState(() => _mapExpanded = !_mapExpanded);
                        },
                        child: Text(
                          _mapExpanded
                              ? AppStrings.collapseMap
                              : AppStrings.expandMap,
                          style: GoogleFonts.nunito(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryPink,
                          ),
                        ),
                      ),
                    ),
                    if (others.isNotEmpty) ...[
                      Text(
                        AppStrings.otherNearby,
                        style: GoogleFonts.nunito(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...others.map(
                        (store) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _StoreRow(
                            store: store,
                            selected: _store.id == store.id,
                            onTap: () => _selectStore(store),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20, 4, 20, 16 + bottom),
              child: Column(
                children: [
                  if (!canConfirm)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        '${AppStrings.storeClosedHint} · ${_store.opensHint}',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.nunito(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: canConfirm ? _confirm : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.orange,
                        disabledBackgroundColor:
                            AppColors.orange.withOpacity(0.35),
                        foregroundColor: AppColors.white,
                        disabledForegroundColor:
                            AppColors.white.withOpacity(0.85),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: const StadiumBorder(),
                      ),
                      child: Text(
                        canConfirm
                            ? '${AppStrings.confirm} · ${_store.name}'
                            : AppStrings.confirm,
                        style: GoogleFonts.nunito(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.4,
                        ),
                      ),
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
}

class _NearestHeroCard extends StatelessWidget {
  const _NearestHeroCard({
    required this.store,
    required this.selected,
    required this.onTap,
  });

  final StoreModel store;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: store.isOpen ? onTap : null,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? AppColors.primaryPink : AppColors.divider,
              width: selected ? 1.6 : 1,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: AppColors.primaryPink.withOpacity(0.18),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ]
                : AppTheme.softShadowLight,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      store.name,
                      style: GoogleFonts.nunito(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  _Badge(
                    label: store.distanceLabel,
                    foreground: AppColors.orange,
                    background: AppColors.orange.withOpacity(0.12),
                  ),
                  const SizedBox(width: 6),
                  _Badge(
                    label: store.isOpen
                        ? AppStrings.openLabel
                        : AppStrings.closedLabel,
                    foreground: store.isOpen
                        ? const Color(0xFF2E7D32)
                        : const Color(0xFFC62828),
                    background: store.isOpen
                        ? const Color(0xFFE8F5E9)
                        : const Color(0xFFFFEBEE),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                store.metaLabel,
                style: GoogleFonts.nunito(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              if (store.isOpen) ...[
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    selected
                        ? '✓ ${AppStrings.useThisStore}'
                        : AppStrings.useThisStore,
                    style: GoogleFonts.nunito(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryPink,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.label,
    required this.foreground,
    required this.background,
  });

  final String label;
  final Color foreground;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label,
        style: GoogleFonts.nunito(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: foreground,
        ),
      ),
    );
  }
}

class _StoreRow extends StatelessWidget {
  const _StoreRow({
    required this.store,
    required this.selected,
    required this.onTap,
  });

  final StoreModel store;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = store.isOpen;
    return Opacity(
      opacity: enabled ? 1 : 0.55,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: selected ? AppColors.primaryPink : AppColors.divider,
                width: selected ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        selected ? AppColors.primaryPink : Colors.transparent,
                    border: Border.all(
                      color: selected
                          ? AppColors.primaryPink
                          : AppColors.textSecondary,
                      width: 2,
                    ),
                  ),
                  child: selected
                      ? const Icon(
                          Icons.check,
                          size: 12,
                          color: AppColors.white,
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        store.name,
                        style: GoogleFonts.nunito(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        store.metaLabel,
                        style: GoogleFonts.nunito(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      store.distanceLabel,
                      style: GoogleFonts.nunito(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: selected
                            ? AppColors.primaryPink
                            : AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      store.isOpen
                          ? AppStrings.openLabel
                          : AppStrings.closedLabel,
                      style: GoogleFonts.nunito(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: store.isOpen
                            ? const Color(0xFF2E7D32)
                            : const Color(0xFFC62828),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

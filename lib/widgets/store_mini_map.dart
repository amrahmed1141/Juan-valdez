import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../core/constants/app_colors.dart';
import '../data/models/store_model.dart';

class StoreMiniMap extends StatefulWidget {
  const StoreMiniMap({
    super.key,
    required this.stores,
    required this.selectedStoreId,
    required this.userLat,
    required this.userLng,
    required this.onStoreTap,
    this.expanded = false,
    this.mountMap = true,
    this.onLocateMe,
  });

  final List<StoreModel> stores;
  final String selectedStoreId;
  final double userLat;
  final double userLng;
  final ValueChanged<StoreModel> onStoreTap;
  final bool expanded;

  /// When false, hold off creating the map until the sheet settles.
  final bool mountMap;
  final VoidCallback? onLocateMe;

  @override
  State<StoreMiniMap> createState() => _StoreMiniMapState();
}

class _StoreMiniMapState extends State<StoreMiniMap>
    with SingleTickerProviderStateMixin {
  final MapController _mapController = MapController();
  late final AnimationController _veil;
  bool _mapReady = false;
  String? _lastSelectedId;

  static const _mapBg = Color(0xFFE8EEF2);

  @override
  void initState() {
    super.initState();
    _veil = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
      value: 1,
    );
  }

  @override
  void dispose() {
    _veil.dispose();
    _mapController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant StoreMiniMap oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.mountMap && !oldWidget.mountMap) {
      _mapReady = false;
      _veil.value = 1;
      _lastSelectedId = null;
    }

    final idChanged = widget.selectedStoreId != _lastSelectedId;
    if (_mapReady && idChanged) {
      _lastSelectedId = widget.selectedStoreId;
      _focusSelected();
    }

    if (widget.expanded != oldWidget.expanded && _mapReady) {
      Future<void>.delayed(const Duration(milliseconds: 320), () {
        if (mounted && _mapReady) _fitNearby();
      });
    }
  }

  void _onMapReady() {
    if (!mounted || _mapReady) return;
    _mapReady = true;
    _lastSelectedId = widget.selectedStoreId;
    _fitNearby();
    setState(() {});
    _veil.animateTo(0, curve: Curves.easeOutCubic);
  }

  void _focusSelected() {
    StoreModel? selected;
    for (final s in widget.stores) {
      if (s.id == widget.selectedStoreId) {
        selected = s;
        break;
      }
    }
    if (selected == null) return;
    _mapController.move(
      LatLng(selected.latitude, selected.longitude),
      13.0,
    );
  }

  void _fitNearby() {
    final points = <LatLng>[
      LatLng(widget.userLat, widget.userLng),
      ...widget.stores.take(3).map((s) => LatLng(s.latitude, s.longitude)),
    ];

    if (points.length == 1) {
      _mapController.move(points.first, 13.0);
      return;
    }

    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: LatLngBounds.fromPoints(points),
        padding: const EdgeInsets.all(48),
        maxZoom: 14.5,
      ),
    );
  }

  void _locateMe() {
    _mapController.move(LatLng(widget.userLat, widget.userLng), 13.6);
    widget.onLocateMe?.call();
  }

  List<Marker> _buildMarkers() {
    return [
      Marker(
        point: LatLng(widget.userLat, widget.userLng),
        width: 22,
        height: 22,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF2F80ED),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.18),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
        ),
      ),
      ...widget.stores.map((store) {
        final selected = store.id == widget.selectedStoreId;
        final color = !store.isOpen
            ? AppColors.navInactive
            : (selected ? AppColors.orange : AppColors.primaryPink);
        final size = selected ? 30.0 : 22.0;
        return Marker(
          point: LatLng(store.latitude, store.longitude),
          width: size,
          height: size,
          child: GestureDetector(
            onTap: () => widget.onStoreTap(store),
            child: Container(
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: selected ? 3.5 : 2.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.18),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final height = widget.expanded ? 280.0 : 168.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 360),
      curve: Curves.easeInOutCubic,
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: _mapBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const ColoredBox(color: _mapBg),
          if (!widget.mountMap)
            const _SoftMapVeil(showPulse: true)
          else ...[
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: LatLng(widget.userLat, widget.userLng),
                initialZoom: 11.8,
                maxZoom: 18,
                minZoom: 3,
                onMapReady: _onMapReady,
              ),
              children: [
                TileLayer(
                  // OSM's public tile.openstreetmap.org blocks/refuses many app
                  // clients (incl. Android emulators). CartoCDN is free for
                  // reasonable use and works reliably with flutter_map.
                  urlTemplate:
                      'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png',
                  fallbackUrl:
                      'https://tile.openstreetmap.de/{z}/{x}/{y}.png',
                  subdomains: const ['a', 'b', 'c', 'd'],
                  userAgentPackageName: 'com.example.juan_valdez',
                ),
                MarkerLayer(markers: _buildMarkers()),
              ],
            ),
            IgnorePointer(
              child: FadeTransition(
                opacity: _veil,
                child: const _SoftMapVeil(showPulse: true),
              ),
            ),
            Positioned(
              right: 10,
              bottom: 10,
              child: AnimatedOpacity(
                opacity: _mapReady ? 1 : 0,
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOut,
                child: Material(
                  color: AppColors.white,
                  shape: const CircleBorder(),
                  elevation: 2,
                  shadowColor: AppColors.shadow,
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: _mapReady ? _locateMe : null,
                    child: const SizedBox(
                      width: 40,
                      height: 40,
                      child: Icon(
                        Icons.my_location_rounded,
                        size: 20,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Soft branded wash — no spinner. Pulses gently while waiting for tiles.
class _SoftMapVeil extends StatefulWidget {
  const _SoftMapVeil({this.showPulse = false});

  final bool showPulse;

  @override
  State<_SoftMapVeil> createState() => _SoftMapVeilState();
}

class _SoftMapVeilState extends State<_SoftMapVeil>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    if (widget.showPulse) {
      _pulse.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant _SoftMapVeil oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showPulse && !_pulse.isAnimating) {
      _pulse.repeat(reverse: true);
    } else if (!widget.showPulse && _pulse.isAnimating) {
      _pulse.stop();
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, _) {
        final t = widget.showPulse ? _pulse.value : 0.0;
        return DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.lerp(
                  const Color(0xFFF3F6F8),
                  const Color(0xFFFFF0F6),
                  t,
                )!,
                Color.lerp(
                  const Color(0xFFE8EEF2),
                  const Color(0xFFFFE8D6),
                  t,
                )!,
              ],
            ),
          ),
          child: Center(
            child: Opacity(
              opacity: 0.35 + (t * 0.25),
              child: const Icon(
                Icons.map_rounded,
                size: 36,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        );
      },
    );
  }
}

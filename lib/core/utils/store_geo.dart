import 'dart:math' as math;

import '../../data/models/store_model.dart';

/// Default mock user pin near Mall of Egypt (6th of October).
abstract final class StoreGeo {
  static const double mockUserLat = 29.9750;
  static const double mockUserLng = 30.9500;

  static double haversineKm({
    required double lat1,
    required double lng1,
    required double lat2,
    required double lng2,
  }) {
    const earthRadiusKm = 6371.0;
    final dLat = _rad(lat2 - lat1);
    final dLng = _rad(lng2 - lng1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_rad(lat1)) *
            math.cos(_rad(lat2)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusKm * c;
  }

  static double _rad(double deg) => deg * math.pi / 180;

  /// Open stores first, then nearest. Optionally filter dine-in support.
  static List<StoreModel> rankStores({
    required List<StoreModel> stores,
    required double userLat,
    required double userLng,
    required bool dineInOnly,
  }) {
    var ranked = stores
        .map(
          (s) => s.copyWith(
            distanceKm: haversineKm(
              lat1: userLat,
              lng1: userLng,
              lat2: s.latitude,
              lng2: s.longitude,
            ),
          ),
        )
        .toList();

    if (dineInOnly) {
      ranked = ranked.where((s) => s.supportsDineIn).toList();
    }

    ranked.sort((a, b) {
      if (a.isOpen != b.isOpen) return a.isOpen ? -1 : 1;
      return a.distanceKm.compareTo(b.distanceKm);
    });
    return ranked;
  }

  static StoreModel? nearestOpen(List<StoreModel> ranked) {
    for (final s in ranked) {
      if (s.isOpen) return s;
    }
    return ranked.isEmpty ? null : ranked.first;
  }
}

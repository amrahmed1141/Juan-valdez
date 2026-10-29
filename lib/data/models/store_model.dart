import 'package:equatable/equatable.dart';

class StoreModel extends Equatable {
  const StoreModel({
    required this.id,
    required this.name,
    required this.distanceKm,
    required this.status,
    required this.readyInMinutes,
    required this.latitude,
    required this.longitude,
    required this.isOpen,
    required this.hours,
    required this.supportsDineIn,
    this.address = '',
  });

  final String id;
  final String name;
  final double distanceKm;
  final String status;
  final int readyInMinutes;
  final double latitude;
  final double longitude;
  final bool isOpen;
  final String hours;
  final bool supportsDineIn;
  final String address;

  String get distanceLabel {
    if (distanceKm < 1) {
      return '${(distanceKm * 1000).round()} m';
    }
    return '${distanceKm.toStringAsFixed(1)} km';
  }

  String get metaLabel => isOpen
      ? '$status · Ready in ~$readyInMinutes min'
      : '$status · $hours';

  String get opensHint => isOpen ? metaLabel : 'Opens at ${hours.split('–').first.trim()}';

  StoreModel copyWith({
    String? id,
    String? name,
    double? distanceKm,
    String? status,
    int? readyInMinutes,
    double? latitude,
    double? longitude,
    bool? isOpen,
    String? hours,
    bool? supportsDineIn,
    String? address,
  }) {
    return StoreModel(
      id: id ?? this.id,
      name: name ?? this.name,
      distanceKm: distanceKm ?? this.distanceKm,
      status: status ?? this.status,
      readyInMinutes: readyInMinutes ?? this.readyInMinutes,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isOpen: isOpen ?? this.isOpen,
      hours: hours ?? this.hours,
      supportsDineIn: supportsDineIn ?? this.supportsDineIn,
      address: address ?? this.address,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        distanceKm,
        status,
        readyInMinutes,
        latitude,
        longitude,
        isOpen,
        hours,
        supportsDineIn,
        address,
      ];
}

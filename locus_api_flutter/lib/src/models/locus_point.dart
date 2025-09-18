/// Represents a geographical point that can be displayed in Locus Map
class LocusPoint {
  /// Unique identifier for the point
  final String? id;
  
  /// Display name of the point
  final String name;
  
  /// Latitude coordinate
  final double latitude;
  
  /// Longitude coordinate
  final double longitude;
  
  /// Altitude in meters (optional)
  final double? altitude;
  
  /// Description text
  final String? description;
  
  /// Icon name or path
  final String? icon;
  
  /// Additional parameters
  final Map<String, dynamic>? extraData;

  const LocusPoint({
    this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.altitude,
    this.description,
    this.icon,
    this.extraData,
  });

  /// Convert to map for platform channel communication
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'altitude': altitude,
      'description': description,
      'icon': icon,
      'extraData': extraData,
    };
  }

  /// Create from map received from platform channel
  factory LocusPoint.fromMap(Map<String, dynamic> map) {
    return LocusPoint(
      id: map['id'],
      name: map['name'] ?? '',
      latitude: map['latitude']?.toDouble() ?? 0.0,
      longitude: map['longitude']?.toDouble() ?? 0.0,
      altitude: map['altitude']?.toDouble(),
      description: map['description'],
      icon: map['icon'],
      extraData: map['extraData'] != null 
          ? Map<String, dynamic>.from(map['extraData']) 
          : null,
    );
  }

  @override
  String toString() {
    return 'LocusPoint(id: $id, name: $name, lat: $latitude, lon: $longitude)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LocusPoint &&
        other.id == id &&
        other.name == name &&
        other.latitude == latitude &&
        other.longitude == longitude;
  }

  @override
  int get hashCode {
    return Object.hash(id, name, latitude, longitude);
  }
}
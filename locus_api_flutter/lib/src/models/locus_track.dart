/// Represents a GPS track that can be displayed in Locus Map
class LocusTrack {
  /// Unique identifier for the track
  final String? id;
  
  /// Display name of the track
  final String name;
  
  /// List of track points
  final List<LocusTrackPoint> points;
  
  /// Description text
  final String? description;
  
  /// Track color in hex format (e.g., "#FF0000" for red)
  final String? color;
  
  /// Track width in pixels
  final double? width;
  
  /// Additional parameters
  final Map<String, dynamic>? extraData;

  const LocusTrack({
    this.id,
    required this.name,
    required this.points,
    this.description,
    this.color,
    this.width,
    this.extraData,
  });

  /// Convert to map for platform channel communication
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'points': points.map((p) => p.toMap()).toList(),
      'description': description,
      'color': color,
      'width': width,
      'extraData': extraData,
    };
  }

  /// Create from map received from platform channel
  factory LocusTrack.fromMap(Map<String, dynamic> map) {
    return LocusTrack(
      id: map['id'],
      name: map['name'] ?? '',
      points: (map['points'] as List<dynamic>?)
          ?.map((p) => LocusTrackPoint.fromMap(Map<String, dynamic>.from(p)))
          .toList() ?? [],
      description: map['description'],
      color: map['color'],
      width: map['width']?.toDouble(),
      extraData: map['extraData'] != null 
          ? Map<String, dynamic>.from(map['extraData']) 
          : null,
    );
  }

  @override
  String toString() {
    return 'LocusTrack(id: $id, name: $name, points: ${points.length})';
  }
}

/// Represents a single point in a GPS track
class LocusTrackPoint {
  /// Latitude coordinate
  final double latitude;
  
  /// Longitude coordinate
  final double longitude;
  
  /// Altitude in meters (optional)
  final double? altitude;
  
  /// Timestamp in milliseconds since epoch (optional)
  final int? timestamp;
  
  /// Speed in m/s (optional)
  final double? speed;
  
  /// Accuracy in meters (optional)
  final double? accuracy;

  const LocusTrackPoint({
    required this.latitude,
    required this.longitude,
    this.altitude,
    this.timestamp,
    this.speed,
    this.accuracy,
  });

  /// Convert to map for platform channel communication
  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'altitude': altitude,
      'timestamp': timestamp,
      'speed': speed,
      'accuracy': accuracy,
    };
  }

  /// Create from map received from platform channel
  factory LocusTrackPoint.fromMap(Map<String, dynamic> map) {
    return LocusTrackPoint(
      latitude: map['latitude']?.toDouble() ?? 0.0,
      longitude: map['longitude']?.toDouble() ?? 0.0,
      altitude: map['altitude']?.toDouble(),
      timestamp: map['timestamp']?.toInt(),
      speed: map['speed']?.toDouble(),
      accuracy: map['accuracy']?.toDouble(),
    );
  }

  @override
  String toString() {
    return 'LocusTrackPoint(lat: $latitude, lon: $longitude, alt: $altitude)';
  }
}
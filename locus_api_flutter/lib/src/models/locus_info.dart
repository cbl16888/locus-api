/// Information about the Locus Map application
class LocusInfo {
  /// Whether Locus Map is installed
  final bool isInstalled;
  
  /// Version name of Locus Map
  final String? versionName;
  
  /// Version code of Locus Map
  final int? versionCode;
  
  /// Package name of Locus Map
  final String? packageName;
  
  /// Whether Locus Map is currently running
  final bool isRunning;
  
  /// Whether periodic updates are enabled
  final bool periodicUpdatesEnabled;
  
  /// Current units used in Locus Map
  final LocusUnits? units;

  const LocusInfo({
    required this.isInstalled,
    this.versionName,
    this.versionCode,
    this.packageName,
    required this.isRunning,
    required this.periodicUpdatesEnabled,
    this.units,
  });

  /// Create from map received from platform channel
  factory LocusInfo.fromMap(Map<String, dynamic> map) {
    return LocusInfo(
      isInstalled: map['isInstalled'] ?? false,
      versionName: map['versionName'],
      versionCode: map['versionCode']?.toInt(),
      packageName: map['packageName'],
      isRunning: map['isRunning'] ?? false,
      periodicUpdatesEnabled: map['periodicUpdatesEnabled'] ?? false,
      units: map['units'] != null 
          ? LocusUnits.fromMap(Map<String, dynamic>.from(map['units']))
          : null,
    );
  }

  @override
  String toString() {
    return 'LocusInfo(installed: $isInstalled, version: $versionName, running: $isRunning)';
  }
}

/// Units configuration in Locus Map
class LocusUnits {
  /// Distance units (0=metric, 1=imperial)
  final int distanceUnits;
  
  /// Altitude units (0=metric, 1=imperial)
  final int altitudeUnits;
  
  /// Speed units (0=km/h, 1=mph, 2=knots, 3=m/s)
  final int speedUnits;
  
  /// Angle units (0=degrees, 1=mils)
  final int angleUnits;

  const LocusUnits({
    required this.distanceUnits,
    required this.altitudeUnits,
    required this.speedUnits,
    required this.angleUnits,
  });

  /// Create from map received from platform channel
  factory LocusUnits.fromMap(Map<String, dynamic> map) {
    return LocusUnits(
      distanceUnits: map['distanceUnits']?.toInt() ?? 0,
      altitudeUnits: map['altitudeUnits']?.toInt() ?? 0,
      speedUnits: map['speedUnits']?.toInt() ?? 0,
      angleUnits: map['angleUnits']?.toInt() ?? 0,
    );
  }

  @override
  String toString() {
    return 'LocusUnits(distance: $distanceUnits, altitude: $altitudeUnits, speed: $speedUnits)';
  }
}

/// Track recording state information
class TrackRecordingState {
  /// Whether track recording is active
  final bool isRecording;
  
  /// Whether track recording is paused
  final bool isPaused;
  
  /// Current profile name
  final String? profileName;
  
  /// Recording start time in milliseconds
  final int? startTime;
  
  /// Total distance recorded in meters
  final double? totalDistance;
  
  /// Total time recorded in milliseconds
  final int? totalTime;

  const TrackRecordingState({
    required this.isRecording,
    required this.isPaused,
    this.profileName,
    this.startTime,
    this.totalDistance,
    this.totalTime,
  });

  /// Create from map received from platform channel
  factory TrackRecordingState.fromMap(Map<String, dynamic> map) {
    return TrackRecordingState(
      isRecording: map['isRecording'] ?? false,
      isPaused: map['isPaused'] ?? false,
      profileName: map['profileName'],
      startTime: map['startTime']?.toInt(),
      totalDistance: map['totalDistance']?.toDouble(),
      totalTime: map['totalTime']?.toInt(),
    );
  }

  @override
  String toString() {
    return 'TrackRecordingState(recording: $isRecording, paused: $isPaused, profile: $profileName)';
  }
}
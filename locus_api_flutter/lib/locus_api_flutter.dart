export 'src/models/locus_point.dart';
export 'src/models/locus_track.dart';
export 'src/models/locus_info.dart';

import 'locus_api_flutter_platform_interface.dart';
import 'src/models/locus_point.dart';
import 'src/models/locus_track.dart';

/// Main class for interacting with Locus Map application
class LocusApiFlutter {
  
  /// Get information about Locus Map installation and state
  Future<Map<String, dynamic>?> getLocusInfo() {
    return LocusApiFlutterPlatform.instance.getLocusInfo();
  }

  /// Display a single point in Locus Map
  Future<void> displayPoint(LocusPoint point, {String? imagePath}) {
    return LocusApiFlutterPlatform.instance.displayPoint(point, imagePath: imagePath);
  }

  /// Display multiple points in Locus Map
  Future<void> displayPoints(List<LocusPoint> points, {String? imagePath}) {
    return LocusApiFlutterPlatform.instance.displayPoints(points, imagePath: imagePath);
  }

  /// Update a single point in Locus Map (for real-time updates)
  Future<void> updatePoint(LocusPoint point, {String? imagePath}) {
    return LocusApiFlutterPlatform.instance.updatePoint(point, imagePath: imagePath);
  }

  /// Update multiple points in Locus Map (for real-time updates)
  Future<void> updatePoints(List<LocusPoint> points, {String? imagePath}) {
    return LocusApiFlutterPlatform.instance.updatePoints(points, imagePath: imagePath);
  }

  /// Clear all points from Locus Map
  Future<void> clearPoints() {
    return LocusApiFlutterPlatform.instance.clearPoints();
  }

  /// Clear points with specific pack name from Locus Map
  Future<void> clearPointsWithName(String packName) {
    return LocusApiFlutterPlatform.instance.clearPointsWithName(packName);
  }

  /// Start navigation to a specific point
  Future<void> startNavigation(LocusPoint point) {
    return LocusApiFlutterPlatform.instance.startNavigation(point);
  }

  /// Display a single track in Locus Map
  Future<void> displayTrack(LocusTrack track) {
    return LocusApiFlutterPlatform.instance.displayTrack(track);
  }

  /// Display multiple tracks in Locus Map
  Future<void> displayTracks(List<LocusTrack> tracks) {
    return LocusApiFlutterPlatform.instance.displayTracks(tracks);
  }

  /// Update a single track in Locus Map (for real-time updates)
  Future<void> updateTrack(LocusTrack track) {
    return LocusApiFlutterPlatform.instance.updateTrack(track);
  }

  /// Update multiple tracks in Locus Map (for real-time updates)
  Future<void> updateTracks(List<LocusTrack> tracks) {
    return LocusApiFlutterPlatform.instance.updateTracks(tracks);
  }

  /// Start track recording
  Future<void> startTrackRecording({String? profileName}) {
    return LocusApiFlutterPlatform.instance.startTrackRecording(profileName: profileName);
  }

  /// Stop track recording
  Future<void> stopTrackRecording({bool autoSave = true}) {
    return LocusApiFlutterPlatform.instance.stopTrackRecording(autoSave: autoSave);
  }

  /// Pause track recording
  Future<void> pauseTrackRecording() {
    return LocusApiFlutterPlatform.instance.pauseTrackRecording();
  }

  /// Resume track recording
  Future<void> resumeTrackRecording() {
    return LocusApiFlutterPlatform.instance.resumeTrackRecording();
  }

  /// Check if Locus Map is installed
  Future<bool> isLocusMapInstalled() {
    return LocusApiFlutterPlatform.instance.isLocusMapInstalled();
  }

  /// Check if track recording is currently active
  Future<bool> isTrackRecording() {
    return LocusApiFlutterPlatform.instance.isTrackRecording();
  }

  /// Get platform version (for debugging)
  Future<String?> getPlatformVersion() {
    return LocusApiFlutterPlatform.instance.getPlatformVersion();
  }

  /// Clear all tracks from Locus Map
  Future<void> clearTracks() {
    return LocusApiFlutterPlatform.instance.clearTracks();
  }

  /// Clear specific track by name from Locus Map
  Future<void> clearTrackByName(String trackName) {
    return LocusApiFlutterPlatform.instance.clearTrackByName(trackName);
  }

  Future<void> openLocusMap() {
    return LocusApiFlutterPlatform.instance.openLocusMap();
  }
}
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'locus_api_flutter_method_channel.dart';
import 'src/models/locus_point.dart';

abstract class LocusApiFlutterPlatform extends PlatformInterface {
  /// Constructs a LocusApiFlutterPlatform.
  LocusApiFlutterPlatform() : super(token: _token);

  static final Object _token = Object();

  static LocusApiFlutterPlatform _instance = MethodChannelLocusApiFlutter();

  /// The default instance of [LocusApiFlutterPlatform] to use.
  ///
  /// Defaults to [MethodChannelLocusApiFlutter].
  static LocusApiFlutterPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [LocusApiFlutterPlatform] when
  /// they register themselves.
  static set instance(LocusApiFlutterPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Get information about Locus Map installation and state
  Future<Map<String, dynamic>?> getLocusInfo() {
    throw UnimplementedError('getLocusInfo() has not been implemented.');
  }

  /// Display a single point in Locus Map
  Future<void> displayPoint(LocusPoint point) {
    throw UnimplementedError('displayPoint() has not been implemented.');
  }

  /// Display multiple points in Locus Map
  Future<void> displayPoints(List<LocusPoint> points) {
    throw UnimplementedError('displayPoints() has not been implemented.');
  }

  /// Update a single point in Locus Map (for real-time updates)
  Future<void> updatePoint(LocusPoint point) {
    throw UnimplementedError('updatePoint() has not been implemented.');
  }

  /// Update multiple points in Locus Map (for real-time updates)
  Future<void> updatePoints(List<LocusPoint> points) {
    throw UnimplementedError('updatePoints() has not been implemented.');
  }

  /// Clear all points from Locus Map
  Future<void> clearPoints() {
    throw UnimplementedError('clearPoints() has not been implemented.');
  }

  /// Clear points with specific pack name from Locus Map
  Future<void> clearPointsWithName(String packName) {
    throw UnimplementedError('clearPointsWithName() has not been implemented.');
  }

  /// Start navigation to a specific point
  Future<void> startNavigation(LocusPoint point) {
    throw UnimplementedError('startNavigation() has not been implemented.');
  }

  /// Start track recording
  Future<void> startTrackRecording({String? profileName}) {
    throw UnimplementedError('startTrackRecording() has not been implemented.');
  }

  /// Stop track recording
  Future<void> stopTrackRecording({bool autoSave = true}) {
    throw UnimplementedError('stopTrackRecording() has not been implemented.');
  }

  /// Pause track recording
  Future<void> pauseTrackRecording() {
    throw UnimplementedError('pauseTrackRecording() has not been implemented.');
  }

  /// Resume track recording
  Future<void> resumeTrackRecording() {
    throw UnimplementedError('resumeTrackRecording() has not been implemented.');
  }

  /// Check if Locus Map is installed
  Future<bool> isLocusMapInstalled() {
    throw UnimplementedError('isLocusMapInstalled() has not been implemented.');
  }

  /// Check if track recording is currently active
  Future<bool> isTrackRecording() {
    throw UnimplementedError('isTrackRecording() has not been implemented.');
  }

  /// Get platform version (for debugging)
  Future<String?> getPlatformVersion() {
    throw UnimplementedError('getPlatformVersion() has not been implemented.');
  }
}
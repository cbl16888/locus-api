import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'locus_api_flutter_method_channel.dart';
import 'src/models/locus_point.dart';
import 'src/models/locus_track.dart';

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
  Future<void> displayPoint(LocusPoint point, {String? imagePath}) {
    throw UnimplementedError('displayPoint() has not been implemented.');
  }

  /// Display multiple points in Locus Map
  Future<void> displayPoints(List<LocusPoint> points, {String? imagePath}) {
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

  /// Display a single track in Locus Map
  Future<void> displayTrack(LocusTrack track) {
    throw UnimplementedError('displayTrack() has not been implemented.');
  }

  /// Display multiple tracks in Locus Map
  Future<void> displayTracks(List<LocusTrack> tracks) {
    throw UnimplementedError('displayTracks() has not been implemented.');
  }

  /// Update a single track in Locus Map (for real-time updates)
  Future<void> updateTrack(LocusTrack track) {
    throw UnimplementedError('updateTrack() has not been implemented.');
  }

  /// Update multiple tracks in Locus Map (for real-time updates)
  Future<void> updateTracks(List<LocusTrack> tracks) {
    throw UnimplementedError('updateTracks() has not been implemented.');
  }

  /// Clear all tracks from Locus Map
  Future<void> clearTracks() {
    throw UnimplementedError('clearTracks() has not been implemented.');
  }

  /// Clear specific track by name from Locus Map
  Future<void> clearTrackByName(String trackName) {
    throw UnimplementedError('clearTrackByName() has not been implemented.');
  }

  Future<void> openLocusMap() {
    throw UnimplementedError('openLocusMap() has not been implemented.');
  }

  // Extra APIs exposed by Android plugin
  Future<void> importPointsFromFile(String fileUri, {bool centerOnData = true}) {
    throw UnimplementedError('importPointsFromFile() has not been implemented.');
  }

  Future<void> importTracksFromFile(String fileUri, {bool centerOnData = true}) {
    throw UnimplementedError('importTracksFromFile() has not been implemented.');
  }

  Future<void> viewFileInLocus(String fileUri, {String? mimeType}) {
    throw UnimplementedError('viewFileInLocus() has not been implemented.');
  }

  Future<void> displayCircles(List<Map<String, dynamic>> circles, {bool centerOnData = false}) {
    throw UnimplementedError('displayCircles() has not been implemented.');
  }

  Future<void> removeCirclesByIds(List<int> ids) {
    throw UnimplementedError('removeCirclesByIds() has not been implemented.');
  }

  Future<void> clearCircles() {
    throw UnimplementedError('clearCircles() has not been implemented.');
  }

  Future<void> displayPolylines(List<Map<String, dynamic>> polylines, {bool centerOnData = false}) {
    throw UnimplementedError('displayPolylines() has not been implemented.');
  }

  Future<void> displayPolygons(List<Map<String, dynamic>> polygons, {bool centerOnData = false}) {
    throw UnimplementedError('displayPolygons() has not been implemented.');
  }

  Future<void> openFieldNotes({bool createLog = false}) {
    throw UnimplementedError('openFieldNotes() has not been implemented.');
  }

  Future<void> logFieldNotes(List<int> ids, {bool createLog = false}) {
    throw UnimplementedError('logFieldNotes() has not been implemented.');
  }

  Future<void> openPointDetailById(int id) {
    throw UnimplementedError('openPointDetailById() has not been implemented.');
  }

  Future<void> startNavigationById(int id) {
    throw UnimplementedError('startNavigationById() has not been implemented.');
  }

  Future<void> startGuidingById(int id) {
    throw UnimplementedError('startGuidingById() has not been implemented.');
  }

  Future<void> openAddress(String address) {
    throw UnimplementedError('openAddress() has not been implemented.');
  }

  Future<void> navigateTo(String name, double latitude, double longitude) {
    throw UnimplementedError('navigateTo() has not been implemented.');
  }

  Future<void> addNewWmsMap(String url) {
    throw UnimplementedError('addNewWmsMap() has not been implemented.');
  }

  Future<Map<String, dynamic>?> getActiveVersionInfo() {
    throw UnimplementedError('getActiveVersionInfo() has not been implemented.');
  }
}
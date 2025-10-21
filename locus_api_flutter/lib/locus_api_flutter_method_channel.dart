import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'locus_api_flutter_platform_interface.dart';
import 'src/models/locus_point.dart';
import 'src/models/locus_track.dart';

/// An implementation of [LocusApiFlutterPlatform] that uses method channels.
class MethodChannelLocusApiFlutter extends LocusApiFlutterPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('locus_api_flutter');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<Map<String, dynamic>?> getLocusInfo() async {
    final result = await methodChannel.invokeMethod<Map<Object?, Object?>>('getLocusInfo');
    if (result == null) {
      return null;
    }
    return Map<String, dynamic>.from(result);
  }

  @override
  Future<void> displayPoint(LocusPoint point, {String? imagePath}) async {
    await methodChannel.invokeMethod('displayPoint', {
      'name': point.name,
      'latitude': point.latitude,
      'longitude': point.longitude,
      'description': point.description,
      if (imagePath != null) 'imagePath': imagePath,
    });
  }

  @override
  Future<void> displayPoints(List<LocusPoint> points, {String? imagePath}) async {
    await methodChannel.invokeMethod('displayPoints', {
      'points': points.map((p) => p.toMap()).toList(),
      if (imagePath != null) 'imagePath': imagePath,
    });
  }

  @override
  Future<void> startNavigation(LocusPoint point) async {
    await methodChannel.invokeMethod('startNavigation', {
      'name': point.name,
      'latitude': point.latitude,
      'longitude': point.longitude,
    });
  }

  @override
  Future<void> updatePoint(LocusPoint point) async {
    await methodChannel.invokeMethod('updatePoint', {
      'name': point.name,
      'latitude': point.latitude,
      'longitude': point.longitude,
      'description': point.description,
      'icon': point.icon ?? ''
    });
  }

  @override
  Future<void> updatePoints(List<LocusPoint> points) async {
    await methodChannel.invokeMethod('updatePoints', {
      'points': points.map((p) => p.toMap()).toList()
    });
  }

  @override
  Future<void> clearPoints() async {
    await methodChannel.invokeMethod('clearPoints');
  }

  @override
  Future<void> clearPointsWithName(String packName) async {
    await methodChannel.invokeMethod('clearPointsWithName', {
      'packName': packName,
    });
  }

  @override
  Future<void> startTrackRecording({String? profileName}) async {
    await methodChannel.invokeMethod('startTrackRecording');
  }

  @override
  Future<void> stopTrackRecording({bool autoSave = true}) async {
    await methodChannel.invokeMethod('stopTrackRecording');
  }

  @override
  Future<void> pauseTrackRecording() async {
    await methodChannel.invokeMethod('pauseTrackRecording');
  }

  @override
  Future<void> resumeTrackRecording() async {
    await methodChannel.invokeMethod('resumeTrackRecording');
  }

  @override
  Future<bool> isLocusMapInstalled() async {
    final result = await methodChannel.invokeMethod<bool>('isLocusMapInstalled');
    return result ?? false;
  }

  @override
  Future<bool> isTrackRecording() async {
    final result = await methodChannel.invokeMethod<bool>('isTrackRecording');
    return result ?? false;
  }

  @override
  Future<void> displayTrack(LocusTrack track) async {
    await methodChannel.invokeMethod('displayTrack', {
      'track': track.toMap(),
    });
  }

  @override
  Future<void> displayTracks(List<LocusTrack> tracks) async {
    await methodChannel.invokeMethod('displayTracks', {
      'tracks': tracks.map((t) => t.toMap()).toList(),
    });
  }

  @override
  Future<void> updateTrack(LocusTrack track, {String? imagePath}) async {
    await methodChannel.invokeMethod('updateTrack', {
      'track': track.toMap(),
      if (imagePath != null) 'imagePath': imagePath,
    });
  }

  @override
  Future<void> updateTracks(List<LocusTrack> tracks, {String? imagePath}) async {
    await methodChannel.invokeMethod('updateTracks', {
      'tracks': tracks.map((t) => t.toMap()).toList(),
      if (imagePath != null) 'imagePath': imagePath,
    });
  }

  @override
  Future<void> clearTracks() async {
    await methodChannel.invokeMethod('clearTracks');
  }

  @override
  Future<void> clearTrackByName(String trackName) async {
    await methodChannel.invokeMethod('clearTrackByName', {
      'trackName': trackName,
    });
  }

  @override
  Future<void> openLocusMap() async {
    await methodChannel.invokeMethod('openLocusMap');
  }

  @override
  Future<void> importPointsFromFile(String fileUri, {bool centerOnData = true}) async {
    await methodChannel.invokeMethod('importPointsFromFile', {
      'fileUri': fileUri,
      'centerOnData': centerOnData,
    });
  }

  @override
  Future<void> importTracksFromFile(String fileUri, {bool centerOnData = true}) async {
    await methodChannel.invokeMethod('importTracksFromFile', {
      'fileUri': fileUri,
      'centerOnData': centerOnData,
    });
  }

  @override
  Future<void> viewFileInLocus(String fileUri, {String? mimeType}) async {
    await methodChannel.invokeMethod('viewFileInLocus', {
      'fileUri': fileUri,
      if (mimeType != null) 'mimeType': mimeType,
    });
  }

  @override
  Future<void> displayCircles(List<Map<String, dynamic>> circles, {bool centerOnData = false}) async {
    await methodChannel.invokeMethod('displayCircles', {
      'circles': circles,
      'centerOnData': centerOnData,
    });
  }

  @override
  Future<void> removeCirclesByIds(List<int> ids) async {
    await methodChannel.invokeMethod('removeCirclesByIds', {
      'ids': ids,
    });
  }

  @override
  Future<void> clearCircles() async {
    await methodChannel.invokeMethod('clearCircles');
  }

  @override
  Future<void> displayPolylines(List<Map<String, dynamic>> polylines, {bool centerOnData = false}) async {
    await methodChannel.invokeMethod('displayPolylines', {
      'polylines': polylines,
      'centerOnData': centerOnData,
    });
  }

  @override
  Future<void> displayPolygons(List<Map<String, dynamic>> polygons, {bool centerOnData = false}) async {
    await methodChannel.invokeMethod('displayPolygons', {
      'polygons': polygons,
      'centerOnData': centerOnData,
    });
  }

  @override
  Future<void> openFieldNotes({bool createLog = false}) async {
    await methodChannel.invokeMethod('openFieldNotes', {
      'createLog': createLog,
    });
  }

  @override
  Future<void> logFieldNotes(List<int> ids, {bool createLog = false}) async {
    await methodChannel.invokeMethod('logFieldNotes', {
      'ids': ids,
      'createLog': createLog,
    });
  }

  @override
  Future<void> openPointDetailById(int id) async {
    await methodChannel.invokeMethod('openPointDetailById', {
      'id': id,
    });
  }

  @override
  Future<void> startNavigationById(int id) async {
    await methodChannel.invokeMethod('startNavigationById', {
      'id': id,
    });
  }

  @override
  Future<void> startGuidingById(int id) async {
    await methodChannel.invokeMethod('startGuidingById', {
      'id': id,
    });
  }

  @override
  Future<void> openAddress(String address) async {
    await methodChannel.invokeMethod('openAddress', {
      'address': address,
    });
  }

  @override
  Future<void> navigateTo(String name, double latitude, double longitude) async {
    await methodChannel.invokeMethod('navigateTo', {
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
    });
  }

  @override
  Future<void> addNewWmsMap(String url) async {
    await methodChannel.invokeMethod('addNewWmsMap', {
      'url': url,
    });
  }

  @override
  Future<Map<String, dynamic>?> getActiveVersionInfo() async {
    final result = await methodChannel.invokeMethod<Map<Object?, Object?>>('getActiveVersionInfo');
    if (result == null) return null;
    return Map<String, dynamic>.from(result);
  }
}
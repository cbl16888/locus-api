import 'package:flutter_test/flutter_test.dart';
import 'package:locus_api_flutter/locus_api_flutter.dart';
import 'package:locus_api_flutter/locus_api_flutter_platform_interface.dart';
import 'package:locus_api_flutter/locus_api_flutter_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockLocusApiFlutterPlatform
    with MockPlatformInterfaceMixin
    implements LocusApiFlutterPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<Map<String, dynamic>?> getLocusInfo() => Future.value({
    'isRunning': true,
    'versionName': '4.0.0',
    'versionCode': 400,
    'isPeriodicUpdatesEnabled': false,
    'isTrackRecording': false,
  });

  @override
  Future<void> displayPoint(LocusPoint point, {String? imagePath}) => Future.value();

  @override
  Future<void> displayPoints(List<LocusPoint> points, {String? imagePath}) => Future.value();

  @override
  Future<void> updatePoint(LocusPoint point, {String? imagePath}) => Future.value();

  @override
  Future<void> updatePoints(List<LocusPoint> points, {String? imagePath}) => Future.value();

  @override
  Future<void> clearPoints() => Future.value();

  @override
  Future<void> clearPointsWithName(String packName) => Future.value();

  @override
  Future<void> startNavigation(LocusPoint point) => Future.value();

  @override
  Future<void> startTrackRecording({String? profileName}) => Future.value();

  @override
  Future<void> stopTrackRecording({bool autoSave = true}) => Future.value();

  @override
  Future<void> pauseTrackRecording() => Future.value();

  @override
  Future<void> resumeTrackRecording() => Future.value();

  @override
  Future<bool> isLocusMapInstalled() => Future.value(true);

  @override
  Future<bool> isTrackRecording() => Future.value(false);

  @override
  Future<void> displayTrack(LocusTrack track) => Future.value();

  @override
  Future<void> displayTracks(List<LocusTrack> tracks) => Future.value();

  @override
  Future<void> updateTrack(LocusTrack track) => Future.value();

  @override
  Future<void> updateTracks(List<LocusTrack> tracks) => Future.value();

  @override
  Future<void> clearTracks() => Future.value();

  @override
  Future<void> clearTrackByName(String trackName) => Future.value();

  @override
  Future<void> openLocusMap() => Future.value();

  @override
  Future<void> addNewWmsMap(String url) {
    // TODO: implement addNewWmsMap
    throw UnimplementedError();
  }

  @override
  Future<void> clearCircles() {
    // TODO: implement clearCircles
    throw UnimplementedError();
  }

  @override
  Future<void> displayCircles(List<Map<String, dynamic>> circles, {bool centerOnData = false}) {
    // TODO: implement displayCircles
    throw UnimplementedError();
  }

  @override
  Future<void> displayPolygons(List<Map<String, dynamic>> polygons, {bool centerOnData = false}) {
    // TODO: implement displayPolygons
    throw UnimplementedError();
  }

  @override
  Future<void> displayPolylines(List<Map<String, dynamic>> polylines, {bool centerOnData = false}) {
    // TODO: implement displayPolylines
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>?> getActiveVersionInfo() {
    // TODO: implement getActiveVersionInfo
    throw UnimplementedError();
  }

  @override
  Future<void> importPointsFromFile(String fileUri, {bool centerOnData = true}) {
    // TODO: implement importPointsFromFile
    throw UnimplementedError();
  }

  @override
  Future<void> importTracksFromFile(String fileUri, {bool centerOnData = true}) {
    // TODO: implement importTracksFromFile
    throw UnimplementedError();
  }

  @override
  Future<void> logFieldNotes(List<int> ids, {bool createLog = false}) {
    // TODO: implement logFieldNotes
    throw UnimplementedError();
  }

  @override
  Future<void> navigateTo(String name, double latitude, double longitude) {
    // TODO: implement navigateTo
    throw UnimplementedError();
  }

  @override
  Future<void> openAddress(String address) {
    // TODO: implement openAddress
    throw UnimplementedError();
  }

  @override
  Future<void> openFieldNotes({bool createLog = false}) {
    // TODO: implement openFieldNotes
    throw UnimplementedError();
  }

  @override
  Future<void> openPointDetailById(int id) {
    // TODO: implement openPointDetailById
    throw UnimplementedError();
  }

  @override
  Future<void> removeCirclesByIds(List<int> ids) {
    // TODO: implement removeCirclesByIds
    throw UnimplementedError();
  }

  @override
  Future<void> startGuidingById(int id) {
    // TODO: implement startGuidingById
    throw UnimplementedError();
  }

  @override
  Future<void> startNavigationById(int id) {
    // TODO: implement startNavigationById
    throw UnimplementedError();
  }

  @override
  Future<void> viewFileInLocus(String fileUri, {String? mimeType}) {
    // TODO: implement viewFileInLocus
    throw UnimplementedError();
  }
}

void main() {
  final LocusApiFlutterPlatform initialPlatform = LocusApiFlutterPlatform.instance;

  test('$MethodChannelLocusApiFlutter is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelLocusApiFlutter>());
  });

  test('getPlatformVersion', () async {
    LocusApiFlutter locusApiFlutterPlugin = LocusApiFlutter();
    MockLocusApiFlutterPlatform fakePlatform = MockLocusApiFlutterPlatform();
    LocusApiFlutterPlatform.instance = fakePlatform;

    expect(await locusApiFlutterPlugin.getPlatformVersion(), '42');
  });

  test('getLocusInfo', () async {
    LocusApiFlutter locusApiFlutterPlugin = LocusApiFlutter();
    MockLocusApiFlutterPlatform fakePlatform = MockLocusApiFlutterPlatform();
    LocusApiFlutterPlatform.instance = fakePlatform;

    final info = await locusApiFlutterPlugin.getLocusInfo();
    expect(info, isNotNull);
    expect(info!['isRunning'], true);
    expect(info['versionName'], '4.0.0');
  });

  test('isLocusMapInstalled', () async {
    LocusApiFlutter locusApiFlutterPlugin = LocusApiFlutter();
    MockLocusApiFlutterPlatform fakePlatform = MockLocusApiFlutterPlatform();
    LocusApiFlutterPlatform.instance = fakePlatform;

    expect(await locusApiFlutterPlugin.isLocusMapInstalled(), true);
  });

  test('displayPoint', () async {
    LocusApiFlutter locusApiFlutterPlugin = LocusApiFlutter();
    MockLocusApiFlutterPlatform fakePlatform = MockLocusApiFlutterPlatform();
    LocusApiFlutterPlatform.instance = fakePlatform;

    final point = LocusPoint(
      name: 'Test Point',
      latitude: 50.0755,
      longitude: 14.4378,
    );

    // Should not throw
    await locusApiFlutterPlugin.displayPoint(point);
  });
}
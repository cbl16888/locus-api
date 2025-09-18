import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'locus_api_flutter_platform_interface.dart';
import 'src/models/locus_point.dart';
import 'src/models/locus_track.dart';
import 'src/models/locus_info.dart';

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
  Future<void> displayPoint(LocusPoint point) async {
    await methodChannel.invokeMethod('displayPoint', {
      'name': point.name,
      'latitude': point.latitude,
      'longitude': point.longitude,
      'description': point.description,
    });
  }

  @override
  Future<void> displayPoints(List<LocusPoint> points) async {
    await methodChannel.invokeMethod('displayPoints', {
      'points': points.map((p) => p.toMap()).toList(),
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
  Future<void> startTrackRecording({String? profileName}) async {
    await methodChannel.invokeMethod('startTrackRecording', {
      'profileName': profileName,
    });
  }

  @override
  Future<void> stopTrackRecording({bool autoSave = true}) async {
    await methodChannel.invokeMethod('stopTrackRecording', {
      'autoSave': autoSave,
    });
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
}
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:locus_api_flutter/locus_api_flutter_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelLocusApiFlutter platform = MethodChannelLocusApiFlutter();
  const MethodChannel channel = MethodChannel('locus_api_flutter');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        switch (methodCall.method) {
          case 'getPlatformVersion':
            return '42';
          case 'getLocusInfo':
            return {
              'isInstalled': true,
              'packageName': 'test.package',
              'isRunning': true,
            };
          case 'displayPoint':
          case 'startNavigation':
          case 'startTrackRecording':
          case 'stopTrackRecording':
          case 'pauseTrackRecording':
          case 'resumeTrackRecording':
          case 'isLocusMapInstalled':
          case 'isTrackRecording':
          case 'openLocusMap':
            return true;
          default:
            return null;
        }
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });

  test('getLocusInfo', () async {
    final result = await platform.getLocusInfo();
    expect(result?['isInstalled'], true);
    expect(result?['packageName'], 'test.package');
    expect(result?['isRunning'], true);
  });

  test('isLocusMapInstalled', () async {
    expect(await platform.isLocusMapInstalled(), true);
  });
}
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:locus_api_flutter/locus_api_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Locus API Flutter Plugin',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _locusApiFlutterPlugin = LocusApiFlutter();
  String _status = 'Unknown';
  bool _isLocusInstalled = false;
  bool _isTrackRecording = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _checkLocusStatus();
  }

  Future<void> _checkLocusStatus() async {
    try {
      final isInstalled = await _locusApiFlutterPlugin.isLocusMapInstalled();
      final isRecording = await _locusApiFlutterPlugin.isTrackRecording();
      final info = await _locusApiFlutterPlugin.getLocusInfo();
      
      setState(() {
        _isLocusInstalled = isInstalled;
        _isTrackRecording = isRecording;
        _status = info != null 
            ? 'Locus ${info['packageName']} - Running: ${info['isRunning']}'
            : 'Locus not available';
      });
    } catch (e) {
      setState(() {
        _status = 'Error: $e';
      });
    }
  }

  Future<void> _displayTestPoint() async {
    try {
      final point = LocusPoint(
        name: 'Test Point',
        latitude: 24.485408,
        longitude: 118.164626,
        description: 'This is a test point from Flutter plugin',
      );


      //   {"lon": 118.164626, "lat": 24.485408, "name": "user00"},
      //   {"lon": 118.175725, "lat": 24.485408, "name": "user01"},
      //   {"lon": 118.186824, "lat": 24.485408, "name": "user02"}

      await _locusApiFlutterPlugin.displayPoint(point);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Point sent to Locus Map')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _displayTestPoints() async {
    try {
      final points = [
        LocusPoint(
          name: 'Test Point 00',
          latitude: 24.485408,
          longitude: 118.164626,
          description: 'This is a test point from Flutter plugin',
        ),
        LocusPoint(
          name: 'Test Point 01',
          latitude: 24.485408,
          longitude: 118.175725,
          description: 'This is a test point from Flutter plugin',
        ),
        LocusPoint(
          name: 'Test Point 02',
          latitude: 24.485408,
          longitude: 118.186824,
          description: 'This is a test point from Flutter plugin',
        )
      ];


      //   {"lon": 118.164626, "lat": 24.485408, "name": "user00"},
      //   {"lon": 118.175725, "lat": 24.485408, "name": "user01"},
      //   {"lon": 118.186824, "lat": 24.485408, "name": "user02"}

      await _locusApiFlutterPlugin.displayPoints(points);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Points sent to Locus Map')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _startNavigation() async {
    try {
      final point = LocusPoint(
        name: 'Navigation Target',
        latitude: 50.0755,
        longitude: 14.4378,
      );
      
      await _locusApiFlutterPlugin.startNavigation(point);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Navigation started in Locus Map')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _toggleTrackRecording() async {
    try {
      if (_isTrackRecording) {
        await _locusApiFlutterPlugin.stopTrackRecording();
      } else {
        await _locusApiFlutterPlugin.startTrackRecording();
      }
      
      await _checkLocusStatus();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isTrackRecording 
                ? 'Track recording stopped' 
                : 'Track recording started'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _startRealTimeUpdate() async {
    // 模拟实时更新多个点位（比如车辆位置）
    final points = [
      LocusPoint(
        name: '车辆1',
        latitude: 24.485408,
        longitude: 118.164626,
        description: '实时位置更新 - 车辆1',
      ),
      LocusPoint(
        name: '车辆2',
        latitude: 24.485408,
        longitude: 118.175725,
        description: '实时位置更新 - 车辆2',
      ),
      LocusPoint(
        name: '车辆3',
        latitude: 24.485408,
        longitude: 118.186824,
        description: '实时位置更新 - 车辆3',
      ),
    ];
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      for (var point in points) {
        point.latitude -= 0.001;
        point.longitude -= 0.001;
      }
      _updatePoints(points);
    });
    _updatePoints(points);
  }

  _updatePoints(List<LocusPoint> points) async {
    try {
      await _locusApiFlutterPlugin.updatePoints(points);
      print("实时点位已更新");
    } catch (e) {
      print("更新点位失败: $e");
    }
  }

  Future<void> _clearAllPoints() async {
    try {
      _timer?.cancel();
      await _locusApiFlutterPlugin.clearPoints();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('所有点位已清除')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('清除点位失败: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Locus API Flutter Plugin'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Locus Map Status',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text('Status: $_status'),
                    Text('Installed: ${_isLocusInstalled ? 'Yes' : 'No'}'),
                    Text('Recording: ${_isTrackRecording ? 'Yes' : 'No'}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _checkLocusStatus,
              child: const Text('Refresh Status'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _isLocusInstalled ? _displayTestPoint : null,
              child: const Text('Display Test Point'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _isLocusInstalled ? _displayTestPoints : null,
              child: const Text('Display Test Points'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _isLocusInstalled ? _startNavigation : null,
              child: const Text('Start Navigation'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _isLocusInstalled ? _toggleTrackRecording : null,
              child: Text(_isTrackRecording 
                  ? 'Stop Track Recording' 
                  : 'Start Track Recording'),
            ),
            const SizedBox(height: 16),
            const Divider(),
            Text(
              '实时更新功能',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _isLocusInstalled ? _startRealTimeUpdate : null,
              child: const Text('实时更新多个点位'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _isLocusInstalled ? _clearAllPoints : null,
              child: const Text('清除所有点位'),
            ),
          ],
        ),
      ),
    );
  }
}
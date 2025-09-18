import 'package:flutter/material.dart';
import 'package:locus_api_flutter/locus_api_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _locusApiFlutterPlugin = LocusApiFlutter();
  String _status = 'Unknown';
  bool _isLocusInstalled = false;
  bool _isTrackRecording = false;

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
            ? 'Locus ${info['versionName']} - Running: ${info['isRunning']}'
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
        latitude: 50.0755,
        longitude: 14.4378,
        description: 'This is a test point from Flutter plugin',
      );
      
      await _locusApiFlutterPlugin.displayPoint(point);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Point sent to Locus Map')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
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
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Navigation started in Locus Map')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _toggleTrackRecording() async {
    try {
      if (_isTrackRecording) {
        await _locusApiFlutterPlugin.stopTrackRecording(autoSave: true);
      } else {
        await _locusApiFlutterPlugin.startTrackRecording();
      }
      
      await _checkLocusStatus();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isTrackRecording 
              ? 'Track recording stopped' 
              : 'Track recording started'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
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
            ],
          ),
        ),
      ),
    );
  }
}
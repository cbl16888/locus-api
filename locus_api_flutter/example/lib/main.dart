import 'dart:async';
import 'dart:math';

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
  bool _testPointDisplayed = false;
  bool _testPointsDisplayed = false;
  Timer? _timer;
  
  // 存储每个车辆的历史轨迹点
  final Map<String, List<LocusTrackPoint>> _vehicleTrajectories = {};

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
      if (_testPointDisplayed) {
        // 删除测试点位
        await _locusApiFlutterPlugin.clearPointsWithName('Test Point');
        
        setState(() {
          _testPointDisplayed = false;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('测试点位已删除')),
          );
        }
      } else {
        // 显示测试点位
        final point = LocusPoint(
          name: 'Test Point',
          latitude: 24.485408,
          longitude: 118.164626,
          description: 'This is a test point from Flutter plugin',
        );

        await _locusApiFlutterPlugin.displayPoint(point);
        
        setState(() {
          _testPointDisplayed = true;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('测试点位已显示')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('操作失败: $e')),
        );
      }
    }
  }

  Future<void> _displayTestPoints() async {
    try {
      if (_testPointsDisplayed) {
        // 删除多个测试点位
        await _locusApiFlutterPlugin.clearPointsWithName('Multiple Points');
        
        setState(() {
          _testPointsDisplayed = false;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('多个测试点位已删除')),
          );
        }
      } else {
        // 显示多个测试点位
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

        await _locusApiFlutterPlugin.displayPoints(points);
        
        setState(() {
          _testPointsDisplayed = true;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('多个测试点位已显示')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('操作失败: $e')),
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
    
    // 初始化轨迹数据
    for (var point in points) {
      _vehicleTrajectories[point.name] = [
        LocusTrackPoint(
          latitude: point.latitude,
          longitude: point.longitude,
          timestamp: DateTime.now().millisecondsSinceEpoch,
        )
      ];
    }

    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {

      for (var point in points) {

        var factor = Random().nextDouble() * 0.001;
        var factor2 = Random().nextDouble() * 0.001;
        var add = Random().nextBool();
        var add2 = Random().nextBool();
        // 更新位置
        if (add) {
          point.latitude += factor;
        } else {
          point.latitude -= factor;
        }
        if (add2) {
          point.longitude += factor2;
        } else {
          point.longitude -= factor2;
        }
        // 保存当前位置到轨迹历史
        _vehicleTrajectories[point.name]?.add(LocusTrackPoint(
          latitude: point.latitude,
          longitude: point.longitude,
          timestamp: DateTime.now().millisecondsSinceEpoch,
        ));
      }
      _updatePointsAndTracks(points);
    });
    _updatePointsAndTracks(points);
  }

  /// 使用真正的轨迹API显示轨迹连线
  _updatePointsAndTracks(List<LocusPoint> points) async {
    try {
      // 1. 更新当前车辆位置点
      await _locusApiFlutterPlugin.updatePoints(points);
      
      // 2. 为每个车辆创建并显示轨迹线
      List<LocusTrack> tracks = [];
      
      for (var vehicleName in _vehicleTrajectories.keys) {
        var trajectoryPoints = _vehicleTrajectories[vehicleName] ?? [];
        
        if (trajectoryPoints.isNotEmpty) {
          // 创建轨迹对象
          var track = LocusTrack(
            name: '${vehicleName}_轨迹',
            points: trajectoryPoints.length == 1 ? [trajectoryPoints[0], trajectoryPoints[0]] : trajectoryPoints,
            description: '$vehicleName 的移动轨迹',
            color: _getVehicleColor(vehicleName), // 为不同车辆设置不同颜色
            width: 1.0, // 增加轨迹线宽度到5像素，更容易看到
          );
          tracks.add(track);
        }
      }
      
      // 3. 更新所有轨迹线
      if (tracks.isNotEmpty) {
        await _locusApiFlutterPlugin.updateTracks(tracks);
      }
      
      debugPrint("实时点位和轨迹线已更新 - ${points.length} 个车辆，${tracks.length} 条轨迹");
      
      // 打印轨迹统计信息
      for (var vehicleName in _vehicleTrajectories.keys) {
        var count = _vehicleTrajectories[vehicleName]?.length ?? 0;
        debugPrint("$vehicleName 轨迹点数量: $count");
      }
    } catch (e) {
      debugPrint("更新点位和轨迹失败: $e");
    }
  }

  /// 为不同车辆分配不同的轨迹颜色
  String _getVehicleColor(String vehicleName) {
    switch (vehicleName) {
      case '车辆1':
        return '#FF0000'; // 红色
      case '车辆2':
        return '#00FF00'; // 绿色
      case '车辆3':
        return '#0000FF'; // 蓝色
      default:
        return '#FF00FF'; // 紫色
    }
  }

  Future<void> _clearAllPoints() async {
    try {
      _timer?.cancel();
      
      // 同时清除点位和轨迹线
      // 首先清除每个已知的轨迹
      List<Future> clearTasks = [
        _locusApiFlutterPlugin.clearPoints(),
      ];
      
      // 为每个车辆轨迹添加清除任务
      for (String vehicleName in _vehicleTrajectories.keys) {
        clearTasks.add(_locusApiFlutterPlugin.clearTrackByName('${vehicleName}_轨迹'));
      }
      
      await Future.wait(clearTasks);
      
      // 重置所有状态和清理轨迹数据
      setState(() {
        _testPointDisplayed = false;
        _testPointsDisplayed = false;
        _vehicleTrajectories.clear(); // 清理轨迹数据
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('所有点位和轨迹已清除')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('清除失败: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    // 清理轨迹数据
    _vehicleTrajectories.clear();
    super.dispose();
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
              child: Text(_testPointDisplayed ? '删除测试点位' : '显示测试点位'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _isLocusInstalled ? _displayTestPoints : null,
              child: Text(_testPointsDisplayed ? '删除多个测试点位' : '显示多个测试点位'),
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
              '实时轨迹功能',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _isLocusInstalled ? _startRealTimeUpdate : null,
              child: const Text('实时更新轨迹线'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _isLocusInstalled ? _clearAllPoints : null,
              child: const Text('清除所有点位和轨迹'),
            ),
          ],
        ),
      ),
    );
  }
}
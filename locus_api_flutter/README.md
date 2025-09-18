# Locus API Flutter Plugin

一个用于与 Locus Map Android 应用集成的 Flutter 插件。该插件提供了与 Locus Map 交互的核心功能，包括显示坐标点、导航、轨迹记录等。

## 功能特性

- ✅ 检查 Locus Map 安装状态
- ✅ 获取 Locus Map 应用信息
- ✅ 显示坐标点到 Locus Map
- ✅ 启动导航功能
- ✅ 轨迹记录控制（开始/停止/暂停/恢复）
- ✅ 检查轨迹记录状态
- ✅ 打开 Locus Map 应用

## 系统要求

- Flutter 2.0 或更高版本
- Android API 21 (Android 5.0) 或更高版本
- Java 8 兼容
- 已安装 Locus Map 应用

## 安装

在 `pubspec.yaml` 文件中添加依赖：

```yaml
dependencies:
  locus_api_flutter:
    path: ../locus_api_flutter  # 本地路径
```

然后运行：

```bash
flutter pub get
```

## 使用方法

### 基本导入

```dart
import 'package:locus_api_flutter/locus_api_flutter.dart';
```

### 检查 Locus Map 安装状态

```dart
final locusApi = LocusApiFlutter();
bool isInstalled = await locusApi.isLocusMapInstalled();
if (isInstalled) {
  print('Locus Map 已安装');
} else {
  print('Locus Map 未安装');
}
```

### 获取 Locus Map 信息

```dart
final info = await locusApi.getLocusInfo();
print('应用包名: ${info?['packageName']}');
print('是否运行: ${info?['isRunning']}');
```

### 显示坐标点

```dart
final point = LocusPoint(
  name: '我的位置',
  latitude: 39.9042,
  longitude: 116.4074,
  description: '北京天安门',
);

bool success = await locusApi.displayPoint(point);
if (success) {
  print('坐标点已发送到 Locus Map');
}
```

### 启动导航

```dart
final destination = LocusPoint(
  name: '目的地',
  latitude: 39.9042,
  longitude: 116.4074,
);

bool success = await locusApi.startNavigation(destination);
if (success) {
  print('导航已启动');
}
```

### 轨迹记录控制

```dart
// 开始记录轨迹
bool started = await locusApi.startTrackRecording();

// 暂停记录
bool paused = await locusApi.pauseTrackRecording();

// 恢复记录
bool resumed = await locusApi.resumeTrackRecording();

// 停止记录
bool stopped = await locusApi.stopTrackRecording();

// 检查记录状态
bool isRecording = await locusApi.isTrackRecording();
```

### 打开 Locus Map

```dart
bool opened = await locusApi.openLocusMap();
if (opened) {
  print('Locus Map 已打开');
}
```

## 数据模型

### LocusPoint

表示一个地理坐标点：

```dart
class LocusPoint {
  final String name;          // 点名称
  final double latitude;      // 纬度
  final double longitude;     // 经度
  final String? description;  // 描述（可选）
  
  const LocusPoint({
    required this.name,
    required this.latitude,
    required this.longitude,
    this.description,
  });
}
```

### LocusTrack

表示一个 GPS 轨迹：

```dart
class LocusTrack {
  final String name;                    // 轨迹名称
  final List<LocusTrackPoint> points;   // 轨迹点列表
  final String? description;            // 描述（可选）
  
  const LocusTrack({
    required this.name,
    required this.points,
    this.description,
  });
}
```

### LocusTrackPoint

表示轨迹中的一个点：

```dart
class LocusTrackPoint {
  final double latitude;    // 纬度
  final double longitude;   // 经度
  final double? altitude;   // 海拔（可选）
  final int? timestamp;     // 时间戳（可选）
  
  const LocusTrackPoint({
    required this.latitude,
    required this.longitude,
    this.altitude,
    this.timestamp,
  });
}
```

## 完整示例

```dart
import 'package:flutter/material.dart';
import 'package:locus_api_flutter/locus_api_flutter.dart';

class LocusMapExample extends StatefulWidget {
  @override
  _LocusMapExampleState createState() => _LocusMapExampleState();
}

class _LocusMapExampleState extends State<LocusMapExample> {
  final LocusApiFlutter _locusApi = LocusApiFlutter();
  String _status = '准备就绪';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Locus API 示例'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '状态: $_status',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _checkLocusInstallation,
              child: Text('检查 Locus Map 安装'),
            ),
            ElevatedButton(
              onPressed: _displayPoint,
              child: Text('显示坐标点'),
            ),
            ElevatedButton(
              onPressed: _startNavigation,
              child: Text('开始导航'),
            ),
            ElevatedButton(
              onPressed: _startRecording,
              child: Text('开始轨迹记录'),
            ),
            ElevatedButton(
              onPressed: _stopRecording,
              child: Text('停止轨迹记录'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _checkLocusInstallation() async {
    try {
      bool isInstalled = await _locusApi.isLocusMapInstalled();
      setState(() {
        _status = isInstalled ? 'Locus Map 已安装' : 'Locus Map 未安装';
      });
    } catch (e) {
      setState(() {
        _status = '检查失败: $e';
      });
    }
  }

  Future<void> _displayPoint() async {
    try {
      final point = LocusPoint(
        name: '示例位置',
        latitude: 39.9042,
        longitude: 116.4074,
        description: '这是一个示例坐标点',
      );
      
      bool success = await _locusApi.displayPoint(point);
      setState(() {
        _status = success ? '坐标点已发送' : '发送失败';
      });
    } catch (e) {
      setState(() {
        _status = '显示坐标点失败: $e';
      });
    }
  }

  Future<void> _startNavigation() async {
    try {
      final destination = LocusPoint(
        name: '目的地',
        latitude: 39.9042,
        longitude: 116.4074,
      );
      
      bool success = await _locusApi.startNavigation(destination);
      setState(() {
        _status = success ? '导航已启动' : '导航启动失败';
      });
    } catch (e) {
      setState(() {
        _status = '启动导航失败: $e';
      });
    }
  }

  Future<void> _startRecording() async {
    try {
      bool success = await _locusApi.startTrackRecording();
      setState(() {
        _status = success ? '轨迹记录已开始' : '轨迹记录启动失败';
      });
    } catch (e) {
      setState(() {
        _status = '启动轨迹记录失败: $e';
      });
    }
  }

  Future<void> _stopRecording() async {
    try {
      bool success = await _locusApi.stopTrackRecording();
      setState(() {
        _status = success ? '轨迹记录已停止' : '轨迹记录停止失败';
      });
    } catch (e) {
      setState(() {
        _status = '停止轨迹记录失败: $e';
      });
    }
  }
}
```

## 错误处理

插件会抛出 `PlatformException` 异常，建议使用 try-catch 块进行错误处理：

```dart
try {
  bool success = await locusApi.displayPoint(point);
  // 处理成功情况
} on PlatformException catch (e) {
  print('平台异常: ${e.message}');
  // 处理平台异常
} catch (e) {
  print('其他错误: $e');
  // 处理其他错误
}
```

## 注意事项

1. **权限要求**: 确保应用具有必要的位置权限
2. **Locus Map 版本**: 建议使用 Locus Map 4.0 或更高版本
3. **网络连接**: 某些功能可能需要网络连接
4. **Java 8 兼容**: 项目已配置为支持 Java 8

## 技术实现

- **Flutter 平台通道**: 使用 MethodChannel 进行 Flutter 与 Android 原生代码通信
- **Locus API**: 基于 Locus API Android 库 (版本 0.9.64)
- **Kotlin 实现**: Android 原生代码使用 Kotlin 编写
- **类型安全**: 完整的 Dart 类型定义和空安全支持

## 许可证

本项目基于 MIT 许可证开源。

## 贡献

欢迎提交 Issue 和 Pull Request 来改进这个插件。

## 更新日志

### v1.0.0
- 初始版本发布
- 支持基本的 Locus Map 集成功能
- Java 8 兼容性
- 完整的测试覆盖
# 实时更新功能文档

## 概述

Locus API Flutter Plugin 现在支持实时更新多个不同点位，这对于以下场景非常有用：
- 实时车辆跟踪
- 多用户位置共享
- 动态地图标记更新
- IoT 设备位置监控

## 新增功能

### 1. 实时更新单个点位
```dart
Future<void> updatePoint(LocusPoint point)
```

**用途**: 更新单个点位的位置信息，适用于单个对象的实时跟踪。

**示例**:
```dart
final locusApi = LocusApiFlutter();

// 更新车辆位置
final vehiclePoint = LocusPoint(
  name: '车辆001',
  latitude: 39.9042,
  longitude: 116.4074,
  description: '当前位置',
);

await locusApi.updatePoint(vehiclePoint);
```

### 2. 实时更新多个点位
```dart
Future<void> updatePoints(List<LocusPoint> points)
```

**用途**: 批量更新多个点位，适用于多对象同时跟踪。

**示例**:
```dart
final locusApi = LocusApiFlutter();

// 更新多个车辆位置
final vehicles = [
  LocusPoint(name: '车辆001', latitude: 39.9042, longitude: 116.4074),
  LocusPoint(name: '车辆002', latitude: 39.9142, longitude: 116.4174),
  LocusPoint(name: '车辆003', latitude: 39.8942, longitude: 116.3974),
];

await locusApi.updatePoints(vehicles);
```

### 3. 清除所有点位
```dart
Future<void> clearPoints()
```

**用途**: 清除地图上的所有点位标记。

**示例**:
```dart
await locusApi.clearPoints();
```

### 4. 清除指定名称的点位包
```dart
Future<void> clearPointsWithName(String packName)
```

**用途**: 清除特定名称的点位包，用于精确控制。

**示例**:
```dart
await locusApi.clearPointsWithName('RealTime_车辆001');
```

## 实时更新最佳实践

### 1. 定时更新示例
```dart
class RealTimeTracker {
  final LocusApiFlutter _locusApi = LocusApiFlutter();
  Timer? _updateTimer;
  
  void startRealTimeTracking() {
    _updateTimer = Timer.periodic(Duration(seconds: 5), (timer) async {
      await _updateVehiclePositions();
    });
  }
  
  void stopRealTimeTracking() {
    _updateTimer?.cancel();
    _updateTimer = null;
  }
  
  Future<void> _updateVehiclePositions() async {
    try {
      // 从服务器获取最新位置数据
      final positions = await _fetchLatestPositions();
      
      // 转换为 LocusPoint 对象
      final points = positions.map((pos) => LocusPoint(
        name: pos.vehicleId,
        latitude: pos.latitude,
        longitude: pos.longitude,
        description: '最后更新: ${DateTime.now()}',
      )).toList();
      
      // 批量更新点位
      await _locusApi.updatePoints(points);
    } catch (e) {
      print('更新位置失败: $e');
    }
  }
}
```

### 2. 流式更新示例
```dart
class StreamTracker {
  final LocusApiFlutter _locusApi = LocusApiFlutter();
  StreamSubscription? _positionSubscription;
  
  void startStreamTracking() {
    // 监听位置数据流
    _positionSubscription = positionStream.listen((positions) async {
      final points = positions.map((pos) => LocusPoint(
        name: pos.id,
        latitude: pos.lat,
        longitude: pos.lng,
      )).toList();
      
      await _locusApi.updatePoints(points);
    });
  }
  
  void stopStreamTracking() {
    _positionSubscription?.cancel();
  }
}
```

### 3. 性能优化建议

#### 批量更新优于单个更新
```dart
// ❌ 不推荐：逐个更新
for (final point in points) {
  await locusApi.updatePoint(point);
}

// ✅ 推荐：批量更新
await locusApi.updatePoints(points);
```

#### 合理的更新频率
```dart
// ✅ 推荐的更新频率
const updateInterval = Duration(seconds: 3); // 3-10秒间隔
const maxPointsPerUpdate = 50; // 每次最多50个点位
```

#### 错误处理
```dart
Future<void> safeUpdatePoints(List<LocusPoint> points) async {
  try {
    await locusApi.updatePoints(points);
  } catch (e) {
    // 记录错误但不中断应用
    print('位置更新失败: $e');
    
    // 可选：重试机制
    await Future.delayed(Duration(seconds: 2));
    try {
      await locusApi.updatePoints(points);
    } catch (retryError) {
      print('重试失败: $retryError');
    }
  }
}
```

## 技术实现细节

### Android 端实现
- 使用不同的 PackPoints 名称来区分不同类型的点位
- `updatePoint()` 使用 `"RealTime_${pointName}"` 作为包名
- `updatePoints()` 使用 `"RealTime_Batch"` 作为包名
- 使用 `ExtraAction.NONE` 避免地图自动居中

### 点位包命名规则
- 单个点位: `"RealTime_${pointName}"`
- 批量点位: `"RealTime_Batch"`
- 普通显示: `"Multiple Points"`
- 导航点位: `"Navigation"`

### 清除策略
- `clearPoints()` 清除 `"Multiple Points"` 和 `"RealTime_Batch"`
- `clearPointsWithName()` 清除指定名称的包
- 单个实时点位需要使用 `clearPointsWithName("RealTime_${pointName}")` 清除

## 示例应用

示例应用中包含了实时更新功能的演示：
- **实时更新多个点位**: 模拟3个车辆的位置更新
- **清除所有点位**: 清除地图上的所有标记

运行示例应用可以看到实时更新的效果。

## 注意事项

1. **权限要求**: 确保应用有访问 Locus Map 的权限
2. **性能考虑**: 避免过于频繁的更新（建议3-10秒间隔）
3. **错误处理**: 实现适当的错误处理和重试机制
4. **内存管理**: 及时清理不需要的点位以避免内存泄漏
5. **网络优化**: 在网络不稳定时适当降低更新频率

## 兼容性

- ✅ Android 平台完全支持
- ✅ Java 8+ 兼容
- ✅ Locus Map 4.0+ 支持
- ✅ Flutter 3.0+ 支持